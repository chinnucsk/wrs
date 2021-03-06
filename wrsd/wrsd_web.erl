%% Copyright (c) 2008 Nick Gerakines <nick@gerakines.net>
%% 
%% Permission is hereby granted, free of charge, to any person
%% obtaining a copy of this software and associated documentation
%% files (the "Software"), to deal in the Software without
%% restriction, including without limitation the rights to use,
%% copy, modify, merge, publish, distribute, sublicense, and/or sell
%% copies of the Software, and to permit persons to whom the
%% Software is furnished to do so, subject to the following
%% conditions:
%% 
%% The above copyright notice and this permission notice shall be
%% included in all copies or substantial portions of the Software.
%% 
%% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
%% EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
%% OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
%% NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
%% HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
%% WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
%% FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
%% OTHER DEALINGS IN THE SOFTWARE.
-module(wrsd_web).
-export([start/1, stop/0, handle_request/3]).

start(_) ->
    Dispatcher = fun(Req) ->
        ?MODULE:handle_request(Req:get(method), Req:get(path), Req)
    end,
    Options = [
        {ip, "0.0.0.0"},
        {port, 5040}
    ],
    mochiweb_http:start([{name, ?MODULE}, {loop, Dispatcher} | Options]).

stop() ->
    mochiweb_http:stop(?MODULE).

handle_request('GET', "/realms/us/", Req) ->
    case wrsd_usrealmserver:realms() of
        {ok, Realms} ->
	        XmlBody = mochijson2:encode(Realms),
            make_response(Req, 200, XmlBody);
        _ -> make_response(Req, 404, "<error>No data for that realm.</error>")
    end;

handle_request('GET', "/realms/eu/", Req) ->
    case wrsd_eurealmserver:realms() of
        {ok, Realms} ->
	        XmlBody = mochijson2:encode(Realms),
            make_response(Req, 200, XmlBody);
        _ -> make_response(Req, 404, "<error>No data for that realm.</error>")
    end;

handle_request('GET', "/realm/us/" ++ Realm, Req) ->
    case wrsd_usrealmserver:lookup(Realm) of
        {ok, Record} ->
            XmlBody = wrsd_realm:record_to_json(Record),
            make_response(Req, 200, XmlBody);
        _ -> make_response(Req, 404, "<error>No data for that realm.</error>")
    end;

handle_request('GET', "/realm/eu/" ++ Realm, Req) ->
    case wrsd_eurealmserver:lookup(Realm) of
        {ok, Record} ->
            XmlBody = wrsd_realm:record_to_json(Record),
            make_response(Req, 200, XmlBody);
        _ -> make_response(Req, 404, "<error>No data for that realm.</error>")
    end;

handle_request('GET', "/realm/" ++ Realm, Req) ->
    case wrsd_usrealmserver:lookup(Realm) of
        {ok, Record} ->
            XmlBody = wrsd_realm:record_to_json(Record),
            make_response(Req, 200, XmlBody);
        _ -> make_response(Req, 404, "<error>No data for that realm.</error>")
    end;

handle_request(_, _, Req) ->
    make_response(Req, 501, "<error>Action not implemented.</error>").

make_response(Req, Status, Body) ->
    Req:respond({
        Status,
        [{"Content-Type", "application/xml"}],
        Body
    }).
