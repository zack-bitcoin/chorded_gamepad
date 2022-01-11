-module(gamepad).
-export([doit/0]).
-export([start/1, init/1]).
%-on_load(start/0).

%buttons 0 1 5 7 6 4
%extras 2 3 6 7

%6 and 7 have 2 directions. 1 and 255. 0 is neutral.

-record(chord, {
          a = false, %0
          b = false, %1
          r = false, %5
          dd = false, %7, 255
          dl = false, %6, 1
          l = false %4
         }).
-record(db, {
          buttons = #chord{},
          accumulated = #chord{},
          recent = #chord{},
          page = 0,
          repeating = false
         }).


-record(controller, {
          a = false, %0
          b = false, %1
          r = false, %5
          dd = false, %7, 255
          dl = false, %6, 1
          l = false, %4
          x = false, %2
          y = false, %3
          dr = false, %6, 255
          du = false %7, 1
         }).
chord_event(0, 0, C) -> C#chord{a = false};
chord_event(0, 1, C) -> C#chord{a = true};
chord_event(1, 0, C) -> C#chord{b = false};
chord_event(1, 1, C) -> C#chord{b = true};
chord_event(5, 0, C) -> C#chord{r = false};
chord_event(5, 1, C) -> C#chord{r = true};
chord_event(7, 0, C) -> C#chord{dd = false};
chord_event(7, 255, C) -> C#chord{dd = true};
chord_event(6, 0, C) -> C#chord{dl = false};
chord_event(6, 1, C) -> C#chord{dl = true};
chord_event(4, 0, C) -> C#chord{l = false};
chord_event(4, 1, C) -> C#chord{l = true};
chord_event(_, _, C) -> C.

accumulate_chord(0, 1, C) -> C#chord{a = true};
accumulate_chord(1, 1, C) -> C#chord{b = true};
accumulate_chord(5, 1, C) -> C#chord{r = true};
accumulate_chord(7, 255, C) -> C#chord{dd = true};
accumulate_chord(6, 1, C) -> C#chord{dl = true};
accumulate_chord(4, 1, C) -> C#chord{l = true};
accumulate_chord(_, _, C) -> C.

all_zeros_chord(C = #chord{a = A, b = B, r = R, 
                  dd = DD, dl = DL, l = L}) ->
    not(A) and
        not(B) and
        not(R) and
        not(DD) and
        not(DL) and
        not(L).

db_event(D = #db{buttons = B, accumulated = A, 
              page = P}) ->
    Bool = all_zeros_chord(B),
    if
        Bool ->
            P2 = do_chord(A, P),
            D#db{accumulated = #chord{}, 
                 recent = A,
                 page = P2};
        true -> D
    end.

chord2num(#chord{a = A, b = B, r = C, 
                 dd = D, dl = E, l = F}) ->
    X1 = if
             A -> 1;
             true -> 0
         end,
    X2 = if
             B -> 2;
             true -> 0
         end,
    X3 = if
             C -> 4;
             true -> 0
         end,
    X4 = if
             D -> 8;
             true -> 0
         end,
    X5 = if
             E -> 16;
             true -> 0
         end,
    X6 = if
             F -> 32;
             true -> 0
         end,
    X1 + X2 + X3 + X4 + X5 + X6.
    

    %possibly emits a key press.
    %possibly changes pages.
do_chord(A = #chord{}, P) ->
    B = chord2num(A),
    do_chord2(B, P).
%todo. need pages 2, 3, and 4.
do_chord2(1, 0) -> %page1
    1;
do_chord2(1, 1) -> %enter
    keyboard:key(2, 0, 0, 0),
    0;
do_chord2(2, 0) -> %page2
    2;
do_chord2(2, 1) -> %right parenthasis
    keyboard:key(36, 1, 0, 0),
    0;
do_chord2(3, 0) -> %enter
    keyboard:key(2, 0, 0, 0),
    0;
do_chord2(4, 0) -> %space
    keyboard:key(69, 0, 0, 0),
    0;
do_chord2(4, 1) -> %right bracket
    keyboard:key(62, 0, 0, 0),
    0;
do_chord2(5, 0) -> %L
    keyboard:key(21, 0, 0, 0),
    0;
do_chord2(5, 1) -> %L
    keyboard:key(21, 1, 0, 0),
    0;
do_chord2(6, 0) -> %T
    keyboard:key(29, 0, 0, 0),
    0;
do_chord2(6, 1) -> %T
    keyboard:key(29, 1, 0, 0),
    0;
do_chord2(7, 0) -> %right
    keyboard:key(7, 0, 0, 0),
    0;
do_chord2(7, 1) -> %right carrot
    keyboard:key(60, 1, 0, 0),
    0;
do_chord2(8, 0) -> %page3
    3;
do_chord2(8, 1) -> %left brace
    keyboard:key(63, 1, 0, 0),
    0;
do_chord2(9, 0) -> %S
    keyboard:key(28, 0, 0, 0),
    0;
do_chord2(9, 1) -> %S
    keyboard:key(28, 1, 0, 0),
    0;
do_chord2(10, 0) -> %E
    keyboard:key(14, 0, 0, 0),
    0;
do_chord2(10, 1) -> %E
    keyboard:key(14, 1, 0, 0),
    0;
do_chord2(12, 0) -> %U
    keyboard:key(30, 0, 0, 0),
    0;
do_chord2(12, 1) -> %U
    keyboard:key(30, 1, 0, 0),
    0;
do_chord2(13, 0) -> %J
    keyboard:key(19, 0, 0, 0),
    0;
do_chord2(13, 1) -> %J
    keyboard:key(19, 1, 0, 0),
    0;
do_chord2(14, 0) -> %W
    keyboard:key(32, 0, 0, 0),
    0;
do_chord2(14, 1) -> %W
    keyboard:key(32, 1, 0, 0),
    0;
do_chord2(16, 0) -> %page4
    4;
do_chord2(16, 1) -> %left parenthasis 
    keyboard:key(45, 1, 0, 0),
    0;
do_chord2(17, 0) -> %A
    keyboard:key(10, 0, 0, 0),
    0;
do_chord2(17, 1) -> %A
    keyboard:key(10, 1, 0, 0),
    0;
do_chord2(18, 0) -> %H
    keyboard:key(17, 0, 0, 0),
    0;
do_chord2(18, 1) -> %H
    keyboard:key(17, 1, 0, 0),
    0;
do_chord2(20, 0) -> %M
    keyboard:key(22, 0, 0, 0),
    0;
do_chord2(20, 1) -> %M
    keyboard:key(22, 1, 0, 0),
    0;
do_chord2(21, 0) -> %K
    keyboard:key(20, 0, 0, 0),
    0;
do_chord2(21, 1) -> %K
    keyboard:key(20, 1, 0, 0),
    0;
do_chord2(22, 0) -> %X
    keyboard:key(33, 0, 0, 0),
    0;
do_chord2(22, 1) -> %X
    keyboard:key(33, 1, 0, 0),
    0;
do_chord2(27, 0) -> %down
    keyboard:key(9, 0, 0, 0),
    0;
do_chord2(32, 0) -> %backspace
    keyboard:key(3, 0, 0, 0),
    0;
do_chord2(32, 1) -> %left bracket
    keyboard:key(63, 0, 0, 0),
    0;
do_chord2(33, 0) -> %O
    keyboard:key(24, 0, 0, 0),
    0;
do_chord2(33, 1) -> %O
    keyboard:key(24, 1, 0, 0),
    0;
do_chord2(34, 0) -> %N
    keyboard:key(23, 0, 0, 0),
    0;
do_chord2(34, 1) -> %N
    keyboard:key(23, 1, 0, 0),
    0;
do_chord2(36, 0) -> %I
    keyboard:key(18, 0, 0, 0),
    0;
do_chord2(36, 1) -> %I
    keyboard:key(18, 1, 0, 0),
    0;
do_chord2(37, 0) -> %B
    keyboard:key(11, 0, 0, 0),
    0;
do_chord2(37, 1) -> %B
    keyboard:key(11, 1, 0, 0),
    0;
do_chord2(38, 0) -> %Q
    keyboard:key(26, 0, 0, 0),
    0;
do_chord2(38, 1) -> %Q
    keyboard:key(26, 1, 0, 0),
    0;
do_chord2(40, 0) -> %R
    keyboard:key(27, 0, 0, 0),
    0;
do_chord2(40, 1) -> %R
    keyboard:key(27, 1, 0, 0),
    0;
do_chord2(41, 0) -> %Z
    keyboard:key(35, 0, 0, 0),
    0;
do_chord2(41, 1) -> %Z
    keyboard:key(35, 1, 0, 0),
    0;
do_chord2(42, 0) -> %C
    keyboard:key(12, 0, 0, 0),
    0;
do_chord2(42, 1) -> %C
    keyboard:key(12, 1, 0, 0),
    0;
do_chord2(44, 0) -> %G
    keyboard:key(16, 0, 0, 0),
    0;
do_chord2(44, 1) -> %G
    keyboard:key(16, 1, 0, 0),
    0;
do_chord2(45, 0) -> %F
    keyboard:key(15, 0, 0, 0),
    0;
do_chord2(45, 1) -> %F
    keyboard:key(15, 1, 0, 0),
    0;
do_chord2(46, 1) -> %right brace
    keyboard:key(62, 1, 0, 0),
    0;
do_chord2(48, 0) -> %D
    keyboard:key(13, 0, 0, 0),
    0;
do_chord2(48, 1) -> %D
    keyboard:key(13, 1, 0, 0),
    0;
do_chord2(49, 0) -> %V
    keyboard:key(31, 0, 0, 0),
    0;
do_chord2(49, 1) -> %V
    keyboard:key(31, 1, 0, 0),
    0;
do_chord2(52, 0) -> %P
    keyboard:key(25, 0, 0, 0),
    0;
do_chord2(52, 1) -> %P
    keyboard:key(25, 1, 0, 0),
    0;
do_chord2(54, 0) -> %up
    keyboard:key(8, 0, 0, 0),
    0;
do_chord2(56, 0) -> %left
    keyboard:key(6, 0, 0, 0),
    0;
do_chord2(56, 1) -> %left carrot
    keyboard:key(59, 1, 0, 0),
    0;
do_chord2(_, P) -> 0.



doit() ->
    %P = open_port({spawn_executable, "gamepad"}, [use_stdio]),
    start("./ebin/gamepad").

start(ExtPrg) ->
  spawn(?MODULE, init, [ExtPrg]).

init(ExtPrg) ->
  register(gamepad, self()),
  process_flag(trap_exit, true),
  %Port = open_port({spawn, ExtPrg}, [{packet, 2}]),
  Port = open_port({spawn_executable, ExtPrg}, 
                   [{packet, 2}, in
                    ]),
  loop(Port, #db{}).
   
loop(Port, DB = #db{buttons = Buttons, 
                    accumulated = Acc, 
                    page = Page,
                    repeater = R}) -> 
    receive
        {_, {data, [Button, _Type, Status]}} ->
            S = ""
                ++ (integer_to_list(Button))
                ++ (" ")
                ++ (integer_to_list(Status))
                ++("\n"),
            %io:fwrite(S),
            %todo. add the repeater here. if du is pressed, then hold down the most recent key until it is unpressed. 
            case {Button, Status, R} of
                {7, 1, false} -> %start repeater
                    %press the button down and hold it.
                    %todo. do_chord needs to be split into 2 parts. we need a function to calculate the button/shift/ctrl/alt combo, and a different function to click it on the keyboard.
                    %set a flag to ignore everything else until the button gets lifted.
                    ok;
                {7, 0, true} -> %end repeater
                    %unpress the button
                    %turn off the repeater flag.
                {_, _, false} ->
            DB2 = DB#db{buttons = 
                         chord_event(
                           Button, Status, 
                           Buttons),
                     accumulated = 
                         accumulate_chord(
                           Button, Status,
                           Acc)},
            DB3 = db_event(DB2),
            loop(Port, DB3)
            end;
        {'EXIT', _, normal} ->
            io:fwrite("c program halted\n");
        X -> 
            io:fwrite("unexpected case "),
            io:fwrite(X),
            loop(Port, DB)
    end.
