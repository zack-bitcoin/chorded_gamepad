Emacs version of chorded gamepad.
==================

The emacs version is written in a way so that it is easier to edit and customize.

This version uses 4 pages. So, there are some chords that require tapping a button to change modes, and then using a chord. Testing has showed that a tap and a combo is faster than trying to press 4 or 5 buttons at once like in the C version.

It has no macro system.

Buttons and chords
=========

There are 6 buttons that can make up a chord.
2 controlled with each thumb, and 1 with each pointer finger.
Each button has a value:
The lower right thumb button has value 1.
The upper right thumb button has value 2.
the right pointer button has value of 4.
the lower left thumb button has value 8.
the upper left thumb button has value 16.
the left pointer button has value of 32.

A chord is made of 3 buttons or fewer.

The value of a chord is the sum of it's buttons.
for example:
If you press the 2 buttons with your right thumb, that has a value of 1+2 = 3.
If you press with both your pointer fingers, that has a value of 32 + 4 = 36.

The 2 left thumb buttons are never used together in a chord.
So, these chords are not used, even though they have less than 4 buttons.: 24, 25, 26, 28, 56

Pages
=========

page 0 is the default page you return to after every command. From page 0 you can go to the other pages.

page 1: 1.

page 3: 2.

page 2: 8.

From any page, you can get back to page 0 by making a chord that has more than 3 buttons.
     
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

0 5, 1 17, 2 33, 3 6, 4 10, 5 34, 6 12, 7 20, 8 40, 9 48

all digits are a chord of only 2 buttons.
Never combine 2 buttons horizontally 1+8, 2+16, or 4+32.
Never combine 1+2, or 8+16.

Emacs tools
==============

on page 0:

35- alt-p (previous command in edit of evil mode)

19- alt-n (next command in edit of evil mode)

on page 2:

9- alt-slash (guess the word)

on page 3:

1 - control pagedown (change tab in terminal)

8- control pageup (change tab in terminal)

4- control alt right arrow (changing desktop in ubuntu)

32- control alt left arrow (changing desktop in ubuntu)

7- alt-right_carrot

35- alt-left_carrot

16- save

on page 4:


3- alt-shift-5 (search and replace)

4- open a file in the other window

6- alt-x

8- open a shell

9- C-x 1 (expand current window)

16- C-x o (go to other window)

32- duplicate this window



syntax keys
===========

del page 4, chord 48. (same chord as 'd')


backspace 32, esc 2-double, enter 3, space 4, tab 7

paren-brace-bracket-carrot
==========

all on page 1.

paren 8 1,
brace 16 2,
bracket 32 4,
carrot 35 7.

arrow keys
========

all on page 4

up 2, left 40, right 5, down 1.

symbols
============

on page 1.
| 3


on page 2.

comma 1, . 2, / 3, ; 4, ! 7,_ 9, ~ 11, @ 13, = 16, - 18, + 21, $ 22, \ 24, : 32, " 36, ? 37, ` 38, & 41, * 42, # 44, ^ 49, % 50, ' 52


page 0
===========

lower case letters, the ability to go to other pages, and some tools we want fast access to.

one button

page 1, page 3, space, page 2, page 4, backspace

two buttons

3 enter, 5 l, 6 t, 9 s, 10 e, 12 u, 17 a, 18 h, 20 m, 33 o, 34 n, 36 i, 40 r, 48 d

three buttons

7 tab, 11 f, 13 j, 14 w, 19, 21 k, 22 y, 25 alt-p, 35 a-p, 37 b, 38 q, 41 z, 42 c, 44 g, 49 v, 50 y, 52 p 


page 1
===========

upper case letters, and all the parenthesis

one button

paren 8 1, brace 16 2, bracket 32 4.

two and three buttons: upper case.

three buttons
%carrot 56 7.
carrot 26 28.

commands on 3 7 11 19 24 25 56

unused 3s
35

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

control + alt + left: 32

control + alt + right: 4

control + pageup: 8

control + pagedown: 1


2 button combos
===========

3 5 6 9 10 12 17 18 20 24 33 34 36 40 48

3 button combos
===========

7 11 13 14 19 21 22 25 26 28 35 37 38 41 42 44 49 50 52 56
