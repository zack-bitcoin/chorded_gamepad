-module(gamepad).
-export([doit/0]).
-export([start/1, init/1]).
%-on_load(start/0).

doit() ->
    %P = open_port({spawn_executable, "gamepad"}, [use_stdio]),
    start("gamepad").

start(ExtPrg) ->
  spawn(?MODULE, init, [ExtPrg]).

init(ExtPrg) ->
  register(gamepad, self()),
  process_flag(trap_exit, true),
  %Port = open_port({spawn, ExtPrg}, [{packet, 2}]),
  Port = open_port({spawn_executable, ExtPrg}, 
                   [{packet, 2}, in
                    ]),
  loop(Port).
   
loop(Port) -> 
    receive
        {_, {data, B}} ->%B is a list of integers, each encoding a byte.
            S = ""
                ++ (integer_to_list(hd(B)))
                ++ (" ")
                ++ (integer_to_list(hd(tl(B))))
                ++ (" ")
                ++ (integer_to_list(hd(tl(tl(B)))))
                ++("\n"),
            io:fwrite(S),
            loop(Port);
        {'EXIT', _, normal} ->
            io:fwrite("c program halted\n");
        X -> 
            io:fwrite("unexpected case "),
            io:fwrite(X),
            loop(Port)
    end.
