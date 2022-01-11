-module(gamepad).
-export([doit/0]).
-export([start/1, init/1]).

%some gamepad code needs to be in C, so this is working as a port.

%-on_load(start/0).

%buttons 0 1 5 7 6 4
%extras 2 3 6 7

%6 and 7 have 2 directions. 1 and 255. 0 is neutral.

-record(chord, {
          a = false, %0 button number
          b = false, %1
          r = false, %5
          dd = false, %7, 255
          dl = false, %6, 1
          l = false, %4
          page = 0
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

all_zeros_chord(
  #chord{a = A, b = B, r = R, 
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
            P2 = tap_key(A, P),
            D#db{accumulated = #chord{}, 
                 recent = A#chord{page = P},
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
tap_key(A = #chord{}, P) ->
    B = chord2num(A),
    %do_chord2(B, P).
    [Key, Shift, Ctrl, Alt, P2] = 
        chord2key(B, P),
    keyboard:key(Key, Shift, Ctrl, Alt),
    P2.


%todo. need pages 2, 3, and 4.

%chord2key(chord, page) ->
%  [key, shift, control, alt, page2]
chord2key(1, 0) -> [0,0,0,0,1];%page1
chord2key(1, 1) -> [36,1,0,0,0];%right paren
chord2key(2, 0) -> [0,0,0,0,3];%page 3
chord2key(2, 1) -> [62,1,0,0,0];%right brace
chord2key(2, 3) -> [5,0,0,0,0];%esc
chord2key(3, 0) -> [2,0,0,0,0];%enter
chord2key(4, 0) -> [69,0,0,0,0];%space
chord2key(4, 1) -> [62,0,0,0,0];%right bracket
chord2key(5, 0) -> [21,0,0,0,0];%L
chord2key(5, 1) -> [21,1,0,0,0];
chord2key(5, 3) -> [21,0,1,0,0];
chord2key(6, 0) -> [29,0,0,0,0];%T
chord2key(6, 1) -> [29,1,0,0,0];
chord2key(6, 3) -> [29,0,1,0,0];
chord2key(7, 0) -> [7,0,0,0,0];%right
chord2key(7, 1) -> [7,1,0,0,0];%right carrot
chord2key(8, 0) -> [0,0,0,0,2];%page2
chord2key(8, 2) -> [1,0,0,0,0];%tab
chord2key(8, 1) -> [45,1,0,0,0];%left paren
chord2key(9, 0) -> [28,0,0,0,0];%S
chord2key(9, 1) -> [28,1,0,0,0];
chord2key(9, 3) -> [28,0,1,0,0];
chord2key(10, 0) -> [14,0,0,0,0];%E
chord2key(10, 1) -> [14,1,0,0,0];
chord2key(10, 3) -> [14,0,1,0,0];
chord2key(12, 0) -> [30,0,0,0,0];%U
chord2key(12, 1) -> [30,1,0,0,0];
chord2key(12, 3) -> [30,0,1,0,0];
chord2key(13, 0) -> [19,0,0,0,0];%J
chord2key(13, 1) -> [19,1,0,0,0];
chord2key(13, 3) -> [19,0,1,0,0];
chord2key(14, 0) -> [32,0,0,0,0];%W
chord2key(14, 1) -> [32,1,0,0,0];
chord2key(14, 3) -> [32,0,1,0,0];

chord2key(16, 0) -> [4,0,0,0,0];%delete
%chord2key(16, 0) -> [0,0,0,0,4];%page4

chord2key(16, 1) -> [63,1,0,0,0];%left brace
chord2key(17, 0) -> [10,0,0,0,0];%A
chord2key(17, 1) -> [10,1,0,0,0];
chord2key(17, 3) -> [10,0,1,0,0];
chord2key(18, 0) -> [17,0,0,0,0];%H
chord2key(18, 1) -> [17,1,0,0,0];
chord2key(18, 3) -> [17,0,1,0,0];
chord2key(20, 0) -> [22,0,0,0,0];%M
chord2key(20, 1) -> [22,1,0,0,0];
chord2key(20, 3) -> [22,3,0,0,0];
chord2key(21, 0) -> [20,0,0,0,0];%K
chord2key(21, 1) -> [20,1,0,0,0];
chord2key(21, 3) -> [20,0,1,0,0];
chord2key(22, 0) -> [34,0,0,0,0];%Y
chord2key(22, 1) -> [34,1,0,0,0];
chord2key(22, 3) -> [34,0,1,0,0];
chord2key(27, 0) -> [9,0,0,0,0];%down
chord2key(32, 0) -> [3,0,0,0,0];%backspace
chord2key(32, 1) -> [63,0,0,0,0];%left bracket
chord2key(33, 0) -> [24,0,0,0,0];%O
chord2key(33, 1) -> [24,1,0,0,0];
chord2key(33, 3) -> [24,0,1,0,0];
chord2key(34, 0) -> [23,0,0,0,0];%N
chord2key(34, 1) -> [23,1,0,0,0];
chord2key(34, 3) -> [23,0,1,0,0];
chord2key(36, 0) -> [18,0,0,0,0];%I
chord2key(36, 1) -> [18,1,0,0,0];
chord2key(36, 3) -> [18,0,1,0,0];
chord2key(37, 0) -> [11,0,0,0,0];%B
chord2key(37, 1) -> [11,1,0,0,0];
chord2key(37, 3) -> [11,0,1,0,0];
chord2key(38, 0) -> [26,0,0,0,0];%Q
chord2key(38, 1) -> [26,1,0,0,0];
chord2key(38, 3) -> [26,0,1,0,0];
chord2key(40, 0) -> [27,0,0,0,0];%R
chord2key(40, 1) -> [27,1,0,0,0];
chord2key(40, 3) -> [27,0,1,0,0];
chord2key(41, 0) -> [35,0,0,0,0];%Z
chord2key(41, 1) -> [35,1,0,0,0];
chord2key(41, 3) -> [35,0,1,0,0];
chord2key(42, 0) -> [12,0,0,0,0];%C
chord2key(42, 1) -> [12,1,0,0,0];
chord2key(41, 3) -> [35,0,1,0,0];
chord2key(44, 0) -> [16,0,0,0,0];%G
chord2key(44, 1) -> [16,1,0,0,0];
chord2key(44, 3) -> [16,0,1,0,0];
chord2key(45, 0) -> [15,0,0,0,0];%F
chord2key(45, 1) -> [15,1,0,0,0];
chord2key(45, 3) -> [15,0,1,0,0];
chord2key(46, 1) -> [62,1,0,0,0];%right brace
chord2key(48, 0) -> [13,0,0,0,0];%D
chord2key(48, 1) -> [13,1,0,0,0];
chord2key(48, 3) -> [13,0,1,0,0];
chord2key(49, 0) -> [31,0,0,0,0];%V
chord2key(49, 1) -> [31,1,0,0,0];
chord2key(49, 3) -> [31,0,1,0,0];
chord2key(50, 0) -> [33,0,0,0,0];%X
chord2key(50, 1) -> [33,1,0,0,0];
chord2key(50, 3) -> [33,0,1,0,0];
chord2key(52, 0) -> [25,0,0,0,0];%P
chord2key(52, 1) -> [25,1,0,0,0];
chord2key(52, 3) -> [25,0,1,0,0];
chord2key(54, 0) -> [8,0,0,0,0];%up
chord2key(56, 0) -> [6,0,0,0,0];%left
chord2key(56, 1) -> [59,1,0,0,0];%left carrot

chord2key(16, 4) -> [4,0,0,0,0];%delete
chord2key(1, 2) -> [59,0,0,0,0];%,
chord2key(1, 4) -> [59,0,1,0,0];
chord2key(2, 2) -> [60,0,0,0,0];%.
chord2key(2, 4) -> [60,0,1,0,0];
chord2key(4, 2) -> [61,0,0,0,0];%;
chord2key(4, 4) -> [61,0,1,0,0];%;
chord2key(5, 2) -> [38,0,0,0,0];%2
chord2key(5, 4) -> [38,0,1,0,0];
chord2key(6, 2) -> [39,0,0,0,0];%3
chord2key(6, 4) -> [39,0,1,0,0];
chord2key(8, 4) -> [67,0,1,0,0];%=
chord2key(9, 2) -> [68,1,0,0,0];%_
chord2key(9, 4) -> [68,1,1,0,0];
chord2key(10, 2) -> [45,0,0,0,0];%9
chord2key(10, 4) -> [45,0,1,0,0];
chord2key(12, 2) -> [42,0,0,0,0];%6
chord2key(12, 4) -> [42,0,1,0,0];
chord2key(13, 2) -> [32,1,0,0,0];%@ 
chord2key(13, 4) -> [32,1,1,0,0];
chord2key(14, 2) -> [65,0,0,0,0];%/
chord2key(14, 4) -> [65,0,1,0,0];
chord2key(16, 2) -> [67,0,0,0,0];%=
chord2key(17, 2) -> [44,0,0,0,0];%8
chord2key(17, 4) -> [44,0,1,0,0];
chord2key(18, 2) -> [68,0,0,0,0];%-
chord2key(18, 4) -> [68,0,1,0,0];
chord2key(20, 2) -> [43,0,0,0,0];%7
chord2key(20, 4) -> [43,0,1,0,0];
chord2key(21, 2) -> [67,1,0,0,0];%+
chord2key(21, 4) -> [67,1,1,0,0];
chord2key(22, 2) -> [40,1,0,0,0];%$
chord2key(22, 4) -> [40,1,1,0,0];
chord2key(32, 2) -> [61,1,0,0,0];%: 
chord2key(32, 4) -> [61,1,1,0,0]; 
chord2key(33, 2) -> [40,0,0,0,0];%4
chord2key(33, 4) -> [40,0,1,0,0];
chord2key(34, 2) -> [41,0,0,0,0];%5
chord2key(34, 4) -> [41,0,1,0,0];
chord2key(36, 2) -> [58,1,0,0,0];%"
chord2key(36, 4) -> [58,1,1,0,0];
chord2key(37, 2) -> [65,1,0,0,0];%?
chord2key(37, 4) -> [65,1,1,0,0];
chord2key(38, 2) -> [64,0,0,0,0];%`
chord2key(38, 4) -> [64,0,1,0,0];
chord2key(40, 2) -> [36,0,0,0,0];%0
chord2key(40, 4) -> [36,0,1,0,0];
chord2key(41, 2) -> [43,1,0,0,0];%&
chord2key(41, 4) -> [43,1,1,0,0];
chord2key(42, 2) -> [44,1,0,0,0];%*
chord2key(42, 4) -> [44,1,1,0,0];
chord2key(44, 2) -> [39,1,0,0,0];%#
chord2key(44, 4) -> [39,1,1,0,0];
chord2key(45, 2) -> [64,1,0,0,0];%~
chord2key(45, 4) -> [64,1,1,0,0];
chord2key(46, 2) -> [66,1,0,0,0];%|
chord2key(46, 4) -> [66,1,1,0,0];
chord2key(48, 2) -> [37,0,0,0,0];%1
chord2key(48, 4) -> [37,0,1,0,0];
chord2key(49, 2) -> [65,0,0,0,0];%/
chord2key(49, 4) -> [65,0,1,0,0];
chord2key(50, 2) -> [41,1,0,0,0];%%
chord2key(50, 4) -> [41,1,1,0,0];
chord2key(52, 2) -> [58,0,0,0,0];%'
chord2key(52, 4) -> [58,0,1,0,0];
chord2key(53, 2) -> [37,1,0,0,0];%!
chord2key(53, 4) -> [37,1,1,0,0];
chord2key(54, 2) -> [42,1,0,0,0];%^
chord2key(54, 4) -> [42,1,1,0,0];
chord2key(_, 0) -> 
    %undefined chord on page 0.
    [0,0,0,0,0];
chord2key(K, _) -> 
    %if chord is undefined on that page, use the version from page 0 instead.
    chord2key(K, 0).
                  

    



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
                   [{packet, 2}, %length of the packet is written in the first 2 bytes.
                    in %we only receive info from the controller, we do not send.
                    ]),
  loop(Port, #db{}).
   
loop(Port, DB = #db{buttons = Buttons, 
                    accumulated = Acc, 
                    recent = Recent,
                    repeating = R}) -> 
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
                    [Key, Shift, Ctrl, Alt, _] = 
                        chord2key(
                          chord2num(Recent), 
                          Recent#chord.page),
                    keyboard:press(Key, Shift, Ctrl, Alt),
                    %set a flag to ignore everything else until the button gets lifted.
                    loop(Port, DB#db{repeating = true});
                {7, 0, true} -> %end repeater
                    %unpress the button
                    [Key, Shift, Ctrl, Alt, _] = 
                        chord2key(
                          chord2num(Recent), 
                          Recent#chord.page),
                    keyboard:unpress(Key, Shift, Ctrl, Alt),
                    loop(Port, DB#db{repeating = false});
                {_, _, true} ->
                    %block other commands until the repeater finishes.
                    loop(Port, DB);
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
