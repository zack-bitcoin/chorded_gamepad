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
%-record(controller, {
%          dd = false, %7, 255
%          dl = false, %6, 1
%          x = false, %2
%          y = false, %3
%          dr = false, %6, 255
%          du = false %7, 1
%         }).

%this keeps track of which buttons are currently pressed.
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

%this accumulates all the pressed buttons to calculate this chord.
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

tap_if_ready(D = #db{buttons = B, accumulated = A, 
              page = P}) ->
    Bool = all_zeros_chord(B),
    if
        Bool ->
            P2 = tap_keys(A, P),
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
    
tap_keys(A = #chord{}, P) ->
    B = chord2num(A),
    L = lists:map(
          fun([Key, Shift, Ctrl, Alt, P2]) ->
                  keyboard:key(
                    Key, Shift, Ctrl, Alt),
                  P2
          end, chord2key2(B, P)),
    lists:last(L).

press_key(A, P) ->
    B = chord2num(A),
    [[Key, Shift, Ctrl, Alt, _]|_] = 
        chord2key2(chord2num(A), P),
    keyboard:press(Key, Shift, Ctrl, Alt).

unpress_key(A, P) ->
    [[Key, Shift, Ctrl, Alt, _]|_] = 
        chord2key2(chord2num(A), P),
    keyboard:unpress(Key, Shift, Ctrl, Alt).
    

%from letter to the code that C accepts.
l2n(a) -> 10;
l2n(b) -> 11;
l2n(c) -> 12;
l2n(d) -> 13;
l2n(e) -> 14;
l2n(f) -> 15;
l2n(g) -> 16;
l2n(h) -> 17;
l2n(i) -> 18;
l2n(j) -> 19;
l2n(k) -> 20;
l2n(l) -> 21;
l2n(m) -> 22;
l2n(n) -> 23;
l2n(o) -> 24;
l2n(p) -> 25;
l2n(q) -> 26;
l2n(r) -> 27;
l2n(s) -> 28;
l2n(t) -> 29;
l2n(u) -> 30;
l2n(v) -> 31;
l2n(w) -> 32;
l2n(x) -> 33;
l2n(y) -> 34;
l2n(z) -> 35;
l2n(_) -> undefined.

%memorization of letters.

% 10: e, 17: a, 33: o, 12: u, 34: n, 20: m, 
% 36: i, 18: h, 9: s, 48: d, 6: t, 40: r, 5: l,
% 37: b, 44: g, 41: z, 13: j, 42: c, 21: k,
% 49: v, 14: w, 50: y, 22: x, 38: q, 52: p

%given the chord, which letter does it encode?
c2l(10) -> e;% 8 2
c2l(17) -> a;% 16 1

c2l(33) -> o;% 32 1
c2l(12) -> u;% 8 4

c2l(34) -> n;% 32 2
c2l(20) -> m;% 16 4

c2l(36) -> i;% 32 4
c2l(18) -> h;% 16 2
c2l(9) -> s;% 8 1

c2l(48) -> d;% 32 16
c2l(6) -> t;% 4 2

c2l(40) -> r;% 32 8
c2l(5) -> l;% 4 1

c2l(37) -> b;% 32 4 1
c2l(44) -> g;% 32 8 4
c2l(41) -> z;% 32 8 1
c2l(13) -> j;% 8 4 1
c2l(45) -> f;% 32 8 4 1

c2l(42) -> c;% 32 8 2
c2l(21) -> k;% 16 4 1

c2l(49) -> v;% 32 16 1
c2l(14) -> w;% 8 4 2

c2l(50) -> y;% 32 16 2
c2l(22) -> x;% 16 4 2

c2l(38) -> q;% 32 4 2
c2l(52) -> p;% 32 16 4
c2l(_) -> undefined.


%modify this to change which chord is for which digit.
%digits are 2 buttons each.
%never combines 1 with 2.
%never combines 8 with 16.
%never combines horizontal pairs: (32, 4), (16, 2) or (8, 1).
% 0: 40, 1: 12, 2: 10,
% 3: 48, 4: 20, 5: 17,
% 6: 33, 7: 34, 8: 5, 9: 6

chord2digit(40) -> 0;
chord2digit(12) -> 1;
chord2digit(10) -> 2;
chord2digit(48) -> 3;
chord2digit(20) -> 4;
chord2digit(17) -> 5;
chord2digit(33) -> 6;
chord2digit(34) -> 7;
chord2digit(5) -> 8;
chord2digit(6) -> 9;
chord2digit(_) -> undefined.

%from a digit, to the code that C accepts.
digit2code(0) -> 36;
digit2code(1) -> 37;
digit2code(2) -> 38;
digit2code(3) -> 39;
digit2code(4) -> 40;
digit2code(5) -> 41;
digit2code(6) -> 42;
digit2code(8) -> 44;
digit2code(7) -> 43;
digit2code(9) -> 45;
digit2code(_) -> undefined.
    
   
%chord2key2(chord, page) ->
%  [[key, shift, control, alt, page2]|...]
chord2key2(C, P) ->
    LetterCode = l2n(c2l(C)),
    DigitCode = digit2code(chord2digit(C)),
    Com = command(C, P),
    case {LetterCode, DigitCode, P, Com} of
        {_, _, _, [_|_]} -> Com;
        {undefined, _, 0, _} -> [chord2key(C, P)];
        {undefined, _, 1, _} -> [chord2key(C, P)];
        {undefined, _, 3, _} -> [chord2key(C, P)];
        {_, undefined, 2, _} -> [chord2key(C, P)];
        %{_, undefined, 4, _} -> [chord2key(C, P)];
        {_, _, 0, _} -> [[LetterCode,0,0,0,0]];
        {_, _, 1, _} -> [[LetterCode,1,0,0,0]];
        {_, _, 3, _} -> [[LetterCode,0,1,0,0]];
        {_, _, 2, _} -> [[DigitCode,0,0,0,0]];
        %{_, _, 4, _} -> [[DigitCode,0,1,0,0]];
        _ -> [chord2key(C, P)]
    end.

%32 + 4 + 2 + 1
%command(39, 3) ->
%command(28, 0) ->
command(24, 3) ->
    %in emacs. for opening a shell consistently.
    [
     %close all but current window.
     [l2n(x),0,1,0,0],
     [digit2code(1),0,0,0,0],
     %create a new window
     [l2n(x),0,1,0,0],
     [digit2code(3),0,0,0,0],
     %go to the new window
     [l2n(x),0,1,0,0],
     [l2n(o),0,0,0,0], 
     %open a shell
     [l2n(x),0,0,1,0],
     [l2n(s),0,0,0,0], 
     [l2n(h),0,0,0,0], 
     [l2n(e),0,0,0,0], 
     [l2n(l),0,0,0,0], 
     [l2n(l),0,0,0,0],
     [2,0,0,0,0]%enter
    ];
command(28, 0) -> 
    [
     [l2n(x),0,1,0,0],
     [digit2code(1),0,0,0,0]
    ];
command(26, 0) -> 
    [
     [l2n(x),0,1,0,0],
     [l2n(o),0,0,0,0]
    ];
command(26, 3) -> 
    %for opening a file in the other window
    %C-x C-o C-x C-f
    [
     [l2n(x),0,1,0,0],
     [digit2code(1),0,0,0,0],
     [l2n(x),0,1,0,0],
     [digit2code(3),0,0,0,0],
     [l2n(x), 0, 1, 0, 0],
     [l2n(o), 0, 1, 0, 0],
     [l2n(x), 0, 1, 0, 0],
     [l2n(f), 0, 1, 0, 0]
    ];

%alt-p (previous command in the terminal inside of emacs) 32 + 16 + 4 + 2
%command(54, 3) -> [[l2n(p),0,0,1,0]];
command(25, 0) -> [[l2n(p),0,0,1,0]];

%alt-n (next command in the terminal inside of emacs) 4 + 2 + 1
%command(7, 3) -> [l2n(n),0,0,1,0];
command(11, 0) -> [l2n(n),0,0,1,0];

%alt-shift-5 (search and replace) 32 + 2 + 1
command(35, 0) ->  [[digit2code(5),1,0,1,0]];

%alt-slash (guess the word) 32 + 4 + 2 + 1
command(24, 0) ->  [[65,0,0,1,0]];

%alt-left carrot (beginning of document) 32+16+8
command(56, 3) -> [[59,1,0,1,0]];

%alt-right carrot (end of document) 1+2+4
command(7, 3) -> [[60,1,0,1,0]];

%alt-x, 16 + 8 + 4
command(28, 3) -> [[l2n(x),0,0,1,0]];

command(_, _) -> undefined.
%+ alt (x > < % w /) 6




chord2key(1, 0) -> [0,0,0,0,1];%page1
chord2key(2, 0) -> [0,0,0,0,3];%page 3
chord2key(8, 0) -> [0,0,0,0,2];%page2
%chord2key(16, 0) -> [0,0,0,0,4];%page4

%chord2key(16, 0) -> [4,0,0,0,0];%delete
chord2key(16, 0) -> [1,0,0,0,0];%tab 
chord2key(32, 0) -> [3,0,0,0,0];%backspace
chord2key(2, 3) -> [5,0,0,0,0];%esc (double tap)
chord2key(3, 0) -> [2,0,0,0,0];%enter
chord2key(4, 0) -> [69,0,0,0,0];%space
%chord2key(8, 2) -> [1,0,0,0,0];%tab (double tap)
chord2key(8, 2) -> [4,0,0,0,0];%delete (double tap)

chord2key(1, 1) -> [36,1,0,0,0];%right paren
chord2key(8, 1) -> [45,1,0,0,0];%left paren
chord2key(2, 1) -> [62,1,0,0,0];%right brace
chord2key(16, 1) -> [63,1,0,0,0];%left brace
chord2key(4, 1) -> [62,0,0,0,0];%right bracket
chord2key(32, 1) -> [63,0,0,0,0];%left bracket
chord2key(7, 1) -> [60,1,0,0,0];%right carrot
chord2key(56, 1) -> [59,1,0,0,0];%left carrot

chord2key(54, 0) -> [8,0,0,0,0];%up
chord2key(56, 0) -> [6,0,0,0,0];%left
chord2key(7, 0) -> [7,0,0,0,0];%right
chord2key(27, 0) -> [9,0,0,0,0];%down


%memorization guide
% one button
% 1: ,, 2: ., 4: ;, 8: tab, 16: =, 32: :

% two buttons (horizontal pairs)
% 9: _, 18: -, 36: ",


% three buttons
% 13: @, 14: /, 21: +, 22: $, 37: ?, 38: `, 
% 41: &, 42: *, 44: #, 49: \, 50: %, 52: ',

% four buttons
% 45: ~, 46: |, 53: !, 54: ^

chord2key(1, 2) -> [59,0,0,0,0];%,
chord2key(2, 2) -> [60,0,0,0,0];%.
chord2key(4, 2) -> [61,0,0,0,0];%;
chord2key(9, 2) -> [68,1,0,0,0];%_
chord2key(13, 2) -> [38,1,0,0,0];%@ 
chord2key(14, 2) -> [65,0,0,0,0];%/
chord2key(16, 2) -> [67,0,0,0,0];%=
chord2key(18, 2) -> [68,0,0,0,0];%-
chord2key(21, 2) -> [67,1,0,0,0];%+
chord2key(22, 2) -> [40,1,0,0,0];%$
chord2key(32, 2) -> [61,1,0,0,0];%: 
chord2key(36, 2) -> [58,1,0,0,0];%"
chord2key(37, 2) -> [65,1,0,0,0];%?
chord2key(38, 2) -> [64,0,0,0,0];%`
chord2key(41, 2) -> [43,1,0,0,0];%&
chord2key(42, 2) -> [44,1,0,0,0];%*
chord2key(44, 2) -> [39,1,0,0,0];%#
chord2key(45, 2) -> [64,1,0,0,0];%~
chord2key(46, 2) -> [66,1,0,0,0];%|
chord2key(49, 2) -> [66,0,0,0,0];%\
chord2key(50, 2) -> [41,1,0,0,0];%%
chord2key(52, 2) -> [58,0,0,0,0];%'
chord2key(53, 2) -> [37,1,0,0,0];%!
chord2key(54, 2) -> [42,1,0,0,0];%^
chord2key(_, 0) -> 
    %undefined chord on page 0. do nothing.
    [0,0,0,0,0];
chord2key(K, _) -> 
    %if chord is undefined on that page, use the version from page 0 instead.
    chord2key(K, 0).

doit() ->
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
            case {Button, Status, R} of
                {7, 1, false} -> %start repeater
                    %press the button down and hold it.
                    press_key(Recent, 
                              Recent#chord.page),
                    %set a flag to ignore everything else until the button gets lifted.
                    loop(Port, DB#db{repeating = true});
                {7, 0, true} -> %end repeater
                    unpress_key(Recent, 
                                Recent#chord.page),
                    loop(Port, DB#db{repeating = false});
                {_, _, true} ->
                    %block other commands until the repeater finishes.
                    loop(Port, DB);
                {_, _, false} ->
                    DB2 = DB#db{buttons = 
                                    chord_event(
                                      Button, 
                                      Status, 
                                      Buttons),
                                accumulated = 
                                    accumulate_chord(
                                      Button, 
                                      Status,
                                      Acc)},
                    DB3 = tap_if_ready(DB2),
                    loop(Port, DB3)
            end;
        {'EXIT', _, normal} ->
            io:fwrite("c program halted\n");
        X -> 
            io:fwrite("unexpected case "),
            io:fwrite(X),
            loop(Port, DB)
    end.
