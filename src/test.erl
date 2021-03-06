-module(test). 
-export([bench/3]).

bench(Host, Port, N) ->
    Start = now(),
    run(N, Host, Port),
    Finish = now(),
    Time=timer:now_diff(Finish, Start).
%file:write_file("output.txt",Time,[append]).

run(N, Host, Port) ->
    if
	N == 0 ->
	    ok;
	true ->
	    request(Host, Port),
	    run(N-1, Host, Port)
    end.

request(Host, Port) ->
    Opt = [list, {active, false}, {reuseaddr, true}],
    {ok, Server} = gen_tcp:connect(Host, Port, Opt),
    gen_tcp:send(Server, http:get("foo")),
    Recv = gen_tcp:recv(Server, 0),
    case Recv of
	{ok, _} ->
	    gen_tcp:close(Server),
	    ok;	
	 {error, Error} -> 
	    io:format("test: error: ~w~n", [Error])
    end.
