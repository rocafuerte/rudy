%%%-------------------------------------------------------------------
%%% File    : rudy.erl
%%% Author  : Felix <felix@onceltuca.local>
%%% Description : 
%%%
%%% Created : 10 Sep 2010 by Felix <felix@onceltuca.local>
%%%-------------------------------------------------------------------
-module(rudy).

-export([start/0,stop/0,init/1]).

start() ->    
    Port=8080,
    register(rudy, spawn(fun() ->
				 rudy:init(Port) end)).
stop() ->
    exit(whereis(rudy), "time to die").

%start() ->
    %spawn(rudy, init, [self()]).


%init(From) ->
%    loop(From).

loop(From) ->
    receive
	_ ->
	    loop(From)
    end.

init(Port) ->    
    io:format("Waiting for connectins at port ~p~n",[Port]),
    Opt = [list, {active, false}, {reuseaddr, true}],
    case gen_tcp:listen(Port, Opt) of
	{ok, LSock} ->
	    handler(LSock),	    
	    ok = gen_tcp:close(LSock);
	{error, Error} ->
	     error
    end.

handler(Listen) ->
    case gen_tcp:accept(Listen) of
	{ok, Client} ->
	    %CPid = spawn(?MODULE,request,[Client]),
	    request(Client),
	    %io:format("spawned ~p~n",[CPid]),
	    handler(Listen);
	{error, Error} ->
	    error
    end.

request(Client) ->
    Recv = gen_tcp:recv(Client, 0),
    case Recv of
	{ok, Str} ->
	    Request = http:parse_request(Str), 
	    Response = reply(Request),
	    gen_tcp:send(Client, Response);
	{error, Error} ->
	    io:format("rudy: error: ~w~n", [Error])
    end,
    gen_tcp:close(Client).


reply({{get, URI, _}, _, _Body}) -> 
    timer:sleep(0),
    http:ok("flaskhals").
