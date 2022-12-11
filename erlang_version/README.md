Emacs version of chorded gamepad.
==================

The emacs version is written in a way so that it is easier to edit and customize.

This version uses 4 pages. So, there are some chords that require tapping a button to change modes, and then using a chord. Testing has showed that a tap and a combo is faster than trying to press 4 or 5 buttons at once like in the C version.

It has no macro system.

Pages
=========

page 0 is the default page you return to after every command. From page 0 you can go to the other pages.

page 1: 1.

page 3: 2.

page 2: 8.

From any page, you can get back to page 0 by making a chord of all 6 buttons together.

Encoding letters
============

lower case letters are on page 0. upper case is on page 1. Control + letter is on page 3.

in order of pairs of letters.
 10: e, 17: a, 33: o, 12: u, 34: n, 20: m, 
 36: i, 18: h, 9: s, 48: d, 6: t, 40: r, 5: l,
 37: b, 44: g, 41: z, 13: j, 45: f, 42: c, 21: k,
 49: v, 14: w, 50: x, 22: y, 38: q, 52: p

in alphabetical order.
% a 17, b 37, c 42, d 48, e 10, f 45, g 44, h 18, i 36, j 13, k 21, l 5, m 20, n 34, o 33, p 52, q 38, r 40, s 9, t 6, u 12, v 49, w 14, x 50, y 22, z 41

numbers
==========

numbers are all on page 2

0 40, 1 12, 2 10, 3 48, 4 20, 5 17, 6 33, 7 34, 8 5, 9 6

all digits are a chord of only 2 buttons.
Never combine 2 buttons horizontally 1+8, 2+16, or 4+32.
Never combine 1+2, or 8+16.

Emacs tools
==============

on page 0:

24- alt-slash (guess the word)

25- alt-p (previous command in edit of evil mode)

11- alt-n (next command in edit of evil mode)

35- alt-shift-5 (search and replace)
26- C-x o (go to other window)

28- open a file in the other window

on page 1:

3- open a shell

11- duplicate this window

24- alt-x

56- alt-left-carrot (beginning of document)

7- alt-right-carrot (end of document)

25- C-x 1 (expand current window)

syntax keys
===========

del 8-double, backspace 32, esc 2-double, enter 3, space 4, tab 16

paren-brace-bracket-carrot
==========

all on page 1.

paren 8 1,
brace 16 2,
bracket 32 4,
carrot 19 26.

arrow keys
========

up 54, left 56, right 7, down 27.

symbols
============

all on page 2.

number order

comma 1, . 2, ; 4, _ 9, @ 13, / 14, = 16, - 18, + 21, $ 22, : 32, " 36, ? 37, ` 38, & 41, * 42, # 44, ~ 45, | 46, \ 49, % 50, ' 52, ! 53, ^ 54


page 0
===========

lower case letters, the ability to go to other pages, and some tools we want fast access to.

one button

page 1, page 3, space, page 2, delete, backspace

two buttons

3 enter, 5 l, 6 t, 9 s, 10 e, 12 u, 17 a, 18 h, 20 m, 24 guess-word, 33 o, 34 n, 36 i, 40 r, 48 d

three buttons

7 right, 11 alt-n, 13 j, 14 w, 19, 21 k, 22 y, 25 alt-p, 26 other-window, 28 open-file, 35 search-replace, 37 b, 38 q, 41 z, 42 c, 44 g, 49 v, 50 y, 52 p, 56 left

four buttons

45 f, 54 up, 27 down

page 1
===========

upper case letters, and all the parenthesis

one button

paren 8 1, brace 16 2, bracket 32 4.

two and three buttons: upper case.

three buttons
%carrot 56 7.
carrot 26 19.

commands on 3 7 11 24 25 56

unused 3s
19 26 28 35

page 2
===========

numbers and symbols.

one button
    
comma 1, . 2, ; 4, delete 8, = 16, : 32

two buttons

numbers are made with pairs of buttons that are not horizontal pairs 1+8, 2+16 or 4+32, and not the one-finger pairs 1+2 or 8+16.

0 40, 1 12, 2 10, 3 48, 4 20, 5 17, 6 33, 7 34, 8 5, 9 6

horizontal pairs of buttons

_ 9, - 18, " 36

two buttons

/ 3, \ 24

three buttons

! 7, @ 13, ~ 19, + 21, $ 22, ? 37, ` 38, & 41, * 42, # 44, % 50, ' 52, | 56

four buttons

54 ^


unused 3s
11 14 25 26 28 35 49

page 3
===========

control + letter

control + alt + left: 56
control + alt + right: 7


2 button combos
===========

3 5 6 9 10 12 17 18 20 24 33 34 36 40 48

3 button combos
===========

7 11 13 14 19 21 22 25 26 28 35 37 38 41 42 44 49 50 52 56
