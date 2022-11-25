%%%-------------------------------------------------------------------
%%% @author Mathias Green <flmath@fedora>
%%% @copyright (C) 2022, Mathias Green
%%% @doc
%%%
%%% @end
%%% Created : 24 Nov 2022 by Mathias Green <flmath@fedora>
%%%-------------------------------------------------------------------
-module(fibonacci).

-export([fib_inefficient/1,
	 fib_inefficient_spawn/1,
	 fib_td/1,
	 fib_bu/1,
	 fib_bu_spawn/1]).

-export([fib_inefficient_spawn/2,
	 fib_bu_spawn/4]).


fib_inefficient(0) -> 1;
fib_inefficient(1) -> 1;
fib_inefficient(N) when N>1 -> 
    fib_inefficient(N-1) + fib_inefficient(N-2).

fib_inefficient_spawn(N) -> 
    spawn(?MODULE, fib_inefficient_spawn, [N, self()]),
    receive
	Int -> Int
    after 
	infinity -> ok	
    end.

fib_inefficient_spawn(0, From) -> From ! 1;
fib_inefficient_spawn(1, From) -> From ! 1;
fib_inefficient_spawn(N, From) when N > 1 -> 
    spawn(?MODULE, fib_inefficient_spawn, [N-1, self()]),
    F2 = fib_inefficient_spawn(N-2),
    F1 = receive
	     Int -> Int
	 after 
	     infinity -> ok	
	 end,
    
    From ! (F1 + F2).

fib_bu(N) -> fib_bu(N,1,1).

fib_bu(1, F1, _F2) -> F1;
fib_bu(N, F1, F2) when N>0 -> 
    fib_bu(N-1, F1 + F2, F1).

fib_bu_spawn(N) -> 
    spawn(?MODULE, fib_bu_spawn, [N,1,1, self()]),
    receive
	Result -> Result
    after 
	infinity -> ok
    end.

fib_bu_spawn(1, F1, _F2, Pid) -> Pid ! F1;
fib_bu_spawn(N, F1, F2, Pid) when N>0 -> 
    fib_bu_spawn(N-1, F1 + F2, F1, Pid).


fib_td(N) when N > -1 ->
    element(1, fib_td_h(N)).

fib_td_h(1) -> {1,1};
fib_td_h(N) -> 
    {F1, F2} = fib_td_h(N-1),
    {F2+F1, F1}.

