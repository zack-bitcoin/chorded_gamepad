-module(gamepad).
-export([doit/0]).
-export([start/1, init/1]).

%some gamepad code needs to be in C, so this is working as a port.

%-on_load(start/0).

%buttons 0 1 5 7 6 4
%extras 2 3 6 7

%6 and 7 have 2 directions. 1 and 255. 0 is neutral.


-define(innext, true).
%innext
-ifdef(innext).
-define(a, 2).
-define(b, 1).
-define(r, 5).
-define(dd, 1).
-define(dl, 0).
-define(l, 4).
-define(x, 0).
-else.
%logitech
-define(a, 0).
-define(b, 1).
-define(r, 5).
-define(dd, 7).
-define(dl, 6).
-define(l, 4).
-endif.

-record(chord, {
          a = false, %0 button number
          b = false, %1
          r = false, %5
          dd = false, %7, 255
          %dl = false, %6, 1
          du = false, %6, 1
          l = false, %4
          page = 0
         }).
-record(db, {
          buttons = #chord{},%the buttons being held down at this moment.
          accumulated = #chord{},%the buttons pressed so far in creating the current cord.
          recent = #chord{},%most recent chord created.
          page = 0,%which page are we on?
          repeating = false%is the repeater being held down?
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


chord_event(?a, 1, 0, C) -> C#chord{a = false};
chord_event(?a, 1, 1, C) -> C#chord{a = true};
chord_event(?b, 1, 0, C) -> C#chord{b = false};
chord_event(?b, 1, 1, C) -> C#chord{b = true};
chord_event(?r, 1, 0, C) -> C#chord{r = false};
chord_event(?r, 1, 1, C) -> C#chord{r = true};
%chord_event(?dd, 2, 0, C) -> C#chord{dd = false};
chord_event(?dd, 2, 0, C) -> C#chord{dd = false, du = false};
chord_event(?dd, 2, 255, C) -> C#chord{dd = true};
%chord_event(?dl, 2, 0, C) -> C#chord{dl = false};
%chord_event(?dl, 2, 1, C) -> C#chord{dl = true};
%chord_event(?dd, 2, 0, C) -> C#chord{dl = false};
chord_event(?dd, 2, 1, C) -> C#chord{du = true};
chord_event(?l, 1, 0, C) -> C#chord{l = false};
chord_event(?l, 1, 1, C) -> C#chord{l = true};
chord_event(?x, 1, 0, C) -> C#chord{l = false};
chord_event(?x, 1, 1, C) -> C#chord{l = true};
chord_event(_, _, _, C) -> C.

%this accumulates all the pressed buttons to calculate this chord.
accumulate_chord(?a, 1, 1, C) -> C#chord{a = true};
accumulate_chord(?b, 1, 1, C) -> C#chord{b = true};
accumulate_chord(?r, 1, 1, C) -> C#chord{r = true};
accumulate_chord(?dd, 2, 255, C) ->C#chord{dd = true};
%accumulate_chord(?dl, 2, 1, C) -> %for inside arrow
accumulate_chord(?dd, 2, 1, C) -> %for inside arrow
    C#chord{du = true};
accumulate_chord(?l, 1, 1, C) -> C#chord{l = true};
accumulate_chord(_A, _T, _B, C) -> 
%    io:fwrite("button pressed: "),
%    io:fwrite(integer_to_list(A)),
%    io:fwrite(" "),
%    io:fwrite(integer_to_list(B)),
%    io:fwrite("\n"),
    C.

all_zeros_chord(
  #chord{a = A, b = B, r = R, 
         dd = DD, du = DL, l = L}) ->
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

num_if(A, N) ->
    if
        A -> N;
        true -> 0
    end.
chord2num(#chord{a = A, b = B, r = C, 
                 dd = D, du = E, l = F}) ->
    X1 = num_if(A, 1),
    X2 = num_if(B, 2),
    X3 = num_if(C, 4),
    X4 = num_if(D, 8),
    X5 = num_if(E, 16),
    X6 = num_if(F, 32),
    X1 + X2 + X3 + X4 + X5 + X6.

filter_bad_keys([X = [_, _, _, _, _]|T]) ->
    [X|filter_bad_keys(T)];
filter_bad_keys([X|T]) ->
    %io:fwrite(X),
    filter_bad_keys(T);
filter_bad_keys([]) -> [].

    
tap_keys(A = #chord{}, P) ->
    B = chord2num(A),
    Keys = chord2key2(B, P),
    Keys2 = filter_bad_keys(Keys),
    L = lists:map(
          fun([Key, Shift, Ctrl, Alt, P2]) ->
                  keyboard:key(
                    Key, Shift, Ctrl, Alt),
                  P2
          end, Keys2),
    lists:last(L).

press_key(A, P) ->
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
% 49: v, 14: w, 50: y, 22: x, 38: q, 52: p, 11: f


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
%c2l(45) -> f;% 32 8 4 1
c2l(11) -> f;% 32 8 4 1

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

%chord2digit(40) -> 0;
%chord2digit(12) -> 1;
%chord2digit(10) -> 2;
%chord2digit(48) -> 3;
%chord2digit(20) -> 4;
%chord2digit(17) -> 5;
%chord2digit(33) -> 7;
%chord2digit(34) -> 6;
%chord2digit(5) -> 9;
%chord2digit(6) -> 8;
chord2digit(5) -> 0;
chord2digit(17) -> 1;
chord2digit(33) -> 2;
chord2digit(6) -> 3;
chord2digit(10) -> 4;
chord2digit(34) -> 5;
chord2digit(12) -> 6;
chord2digit(20) -> 7;
chord2digit(40) -> 8;
chord2digit(48) -> 9;
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
%command(24, 3) ->
%command(chord, page)
command(8, 4) ->
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
command(9, 4) -> 
    %expand current window
    [
     [l2n(x),0,1,0,0],
     [digit2code(1),0,0,0,0]
    ];
%command(16, 4) -> 
command(7, 0) -> 
    %other window
    [
     [l2n(x),0,1,0,0],
     [l2n(o),0,0,0,0]
    ];
command(4, 4) -> 
    %for opening a file  
    %C-x o C-x C-f
    [
     %[l2n(x), 0, 1, 0, 0],
     %[l2n(o), 0, 0, 0, 0],
     [l2n(x), 0, 1, 0, 0],
     [l2n(f), 0, 1, 0, 0]
    ];
command(32, 4) -> 
    %duplicate current window
    [
     [l2n(x),0,1,0,0],
     [digit2code(1),0,0,0,0],
     [l2n(x),0,1,0,0],
     [digit2code(3),0,0,0,0]
    ];

%alt-p (previous command in the terminal inside of emacs) 32 + 16 + 4 + 2
command(35, 0) -> [[l2n(p),0,0,1,0]];

%alt-n (next command in the terminal inside of emacs) 4 + 2 + 1
command(19, 0) -> [[l2n(n),0,0,1,0]];

%alt-shift-5 (search and replace) 32 + 2 + 1
command(3, 4) ->  [[digit2code(5),1,0,1,0]];

%alt-slash (guess the word) 32 + 4 + 2 + 1
command(8, 2) ->  [[65,0,0,1,0]];

%alt-left carrot (beginning of document) 32+16+8
command(35, 3) -> [[59,1,0,1,0]];

%alt-right carrot (end of document) 1+2+4
command(7, 3) -> [[60,1,0,1,0]];

%save
command(16, 3) -> [[l2n(x),0,1,0,0],
                   [l2n(s),0,1,0,0]
                  ];

%alt-x, 16 + 8 + 4
command(6, 4) -> [[l2n(x),0,0,1,0]];

%control alt left
command(32, 3) -> [[6,0,1,1,0]];
%control alt right
command(4, 3) -> [[7,0,1,1,0]];
%control pageup
command(8, 3) -> [[70,0,1,0,0]];
%control pagedown
command(1, 3) -> [[71,0,1,0,0]];

%control + (to make text bigger)
command(41, 4) ->[[67,1,1,0,0]];
%control - (to make text smaller)
command(13, 4) ->[[68,0,1,0,0]];



%é
command(10, 4) -> [[l2n(x),0,1,0,0],
                   [digit2code(8),0,0,0,0],
                   [58,0,0,0,0],%'
                   [l2n(e),0,0,0,0]
                  ];
%ú
command(12, 4) -> [[l2n(x),0,1,0,0],
                   [digit2code(8),0,0,0,0],
                   [58,0,0,0,0],%'
                   [l2n(u),0,0,0,0]
                  ];
%án
command(17, 4) -> [[l2n(x),0,1,0,0],
                   [digit2code(8),0,0,0,0],
                   [58,0,0,0,0],%'
                   [l2n(a),0,0,0,0]
                  ];
%ó
command(33, 4) -> [[l2n(x),0,1,0,0],
                   [digit2code(8),0,0,0,0],
                   [58,0,0,0,0],%'
                   [l2n(o),0,0,0,0]
                  ];
%í
command(36, 4) -> [[l2n(x),0,1,0,0],
                   [digit2code(8),0,0,0,0],
                   [58,0,0,0,0],%'
                   [l2n(i),0,0,0,0]
                  ];
%ñ 
command(34, 4) -> [[l2n(x),0,1,0,0],
                   [digit2code(8),0,0,0,0],
                   [64,1,0,0,0],%~
                   [l2n(n),0,0,0,0]
                  ];

command(_, _) -> undefined.
%+ alt (x > < % w /) 6



%chord, page
chord2key(1, 0) -> [0,0,0,0,1];%page1
chord2key(2, 0) -> [0,0,0,0,3];%page 3
chord2key(8, 0) -> [0,0,0,0,2];%page2
chord2key(16, 0) -> [0,0,0,0,4];%page 4

%chord2key(16, 0) -> [1,0,0,0,0];%tab 
%chord2key(7, 0) -> [1,0,0,0,0];%tab
chord2key(16, 4) -> [1,0,0,0,0];%tab
chord2key(32, 0) -> [3,0,0,0,0];%backspace
chord2key(2, 3) -> [5,0,0,0,0];%esc (double tap)
chord2key(3, 0) -> [2,0,0,0,0];%enter
chord2key(4, 0) -> [69,0,0,0,0];%space
%chord2key(8, 2) -> [4,0,0,0,0];%delete (double tap)
chord2key(48, 4) -> [4,0,0,0,0];%delete (double tap)

chord2key(1, 1) -> [36,1,0,0,0];%right paren
chord2key(8, 1) -> [45,1,0,0,0];%left paren
chord2key(2, 1) -> [62,1,0,0,0];%right brace
chord2key(16, 1) -> [63,1,0,0,0];%left brace
chord2key(4, 1) -> [62,0,0,0,0];%right bracket
chord2key(32, 1) -> [63,0,0,0,0];%left bracket
%chord2key(28, 1) -> [60,1,0,0,0];%right carrot
chord2key(7, 1) -> [60,1,0,0,0];%right carrot
%chord2key(26, 1) -> [59,1,0,0,0];%left carrot
chord2key(35, 1) -> [59,1,0,0,0];%left carrot

%chord2key(54, 0) -> [8,0,0,0,0];%up
chord2key(2, 4) -> [8,0,0,0,0];%up
%chord2key(56, 0) -> [6,0,0,0,0];%left
chord2key(40, 4) -> [6,0,0,0,0];%left
%chord2key(7, 0) -> [7,0,0,0,0];%right
chord2key(5, 4) -> [7,0,0,0,0];%right
%chord2key(27, 0) -> [9,0,0,0,0];%down
chord2key(1, 4) -> [9,0,0,0,0];%down

 

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
chord2key(3, 2) -> [65,0,0,0,0];%/
chord2key(4, 2) -> [61,0,0,0,0];%;
chord2key(7, 2) -> [37,1,0,0,0];%!
chord2key(9, 2) -> [68,1,0,0,0];%_
chord2key(13, 2) -> [38,1,0,0,0];%@ 
chord2key(16, 2) -> [67,0,0,0,0];%=
chord2key(18, 2) -> [68,0,0,0,0];%-
chord2key(19, 2) -> [64,1,0,0,0];%~
chord2key(21, 2) -> [67,1,0,0,0];%+
chord2key(22, 2) -> [40,1,0,0,0];%$
%chord2key(24, 2) -> [66,0,0,0,0];%\
chord2key(3, 3) -> [66,0,0,0,0];%\
chord2key(32, 2) -> [61,1,0,0,0];%: 
chord2key(36, 2) -> [58,1,0,0,0];%"
chord2key(37, 2) -> [65,1,0,0,0];%?
chord2key(38, 2) -> [64,0,0,0,0];%`
chord2key(41, 2) -> [43,1,0,0,0];%&
chord2key(42, 2) -> [44,1,0,0,0];%*
chord2key(44, 2) -> [39,1,0,0,0];%#
chord2key(50, 2) -> [41,1,0,0,0];%%
chord2key(52, 2) -> [58,0,0,0,0];%'
chord2key(54, 2) -> [42,1,0,0,0];%^
%chord2key(56, 2) -> [66,1,0,0,0];%|
chord2key(3, 1) -> [66,1,0,0,0];%|
chord2key(_, _) -> 
    %undefined chord. go to page 0.
    [0,0,0,0,0].

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
    %io:fwrite("main loop\n"),
    receive
        {_, {data, [Button, Type, Status]}} ->
            %io:fwrite(integer_to_list(Button)),
            %io:fwrite("\n"),
            case {Button, Status, Type, R} of
                %{?dd, 1, 2, false} -> %start repeater
                {?x, 1, 1, false} -> %start repeater
                    %press the button down and hold it.
                    %io:fwrite("press repeater\n"),
                    press_key(Recent, 
                              Recent#chord.page),
                    %set a flag to ignore everything else until the button gets lifted.
                    loop(Port, DB#db{repeating = true});
                %{?dd, 0, 2, true} -> %end repeater
                {?x, 0, 1, true} -> %end repeater
                    %!io:fwrite("unpress repeater\n"),
                    unpress_key(Recent, 
                                Recent#chord.page),
                    loop(Port, DB#db{repeating = false});
                {_, _, _, true} ->
                    %block other commands until the repeater finishes.
                    io:fwrite("blocking\n"),
                    loop(Port, DB);
                {_, _, _, false} ->
                    %io:fwrite("press button\n"),
                    DB2 = DB#db{buttons = 
                                    chord_event(
                                      Button, 
                                      Type,
                                      Status, 
                                      Buttons),
                                accumulated = 
                                    accumulate_chord(
                                      Button, 
                                      Type,
                                      Status,
                                      Acc)},
                    %io:fwrite("tap if ready\n"),
                    DB3 = tap_if_ready(DB2),
                    %io:fwrite("recurse\n"),
                    loop(Port, DB3)
            end;
        {'EXIT', _, normal} ->
            io:fwrite("c program halted\n");
        X -> 
            io:fwrite("unexpected case "),
            io:fwrite(X),
            loop(Port, DB)
    end.
