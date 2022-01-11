-module(keyboard).
-export([key/4,
         press/4,
         unpress/4,
         test/0
        ]).
-on_load(init/0).
init() ->
    R = erlang:load_nif("./ebin/keyboard", 0),
    setup(1),
    R.

setup(_) ->
    ok.
test() ->
    ok.

key(_, _, _, _) ->
    ok.
press(_, _, _, _) ->
    ok.
unpress(_, _, _, _) ->
    ok.
