Chorded Gamepad
==========

This is software so you can use a gamepad as a chorded keyboard.

The buttons
=============

I use a Logitech F310 gamepad, so I will explain which buttons I use for this gamepad. You can configure it to use whatever buttons you want on your gamepad.

Uses 11 buttons in total.

It uses 6 basic buttons to encode lower case letters, numbers, and some symbols.
I use A, B, right bumper, down on D-pad, left on D-pad, and left bumper.

3 more buttons are for Control, Alt, and Shift. These modifiers can be combined with combinations of the 6 basic buttons to enable capital letters, CONTROL+s etc.
I use left trigger, Y button, and right trigger.

With a keyboard, if you hold a key down you can cause that letter to get repeatedly typed many times. This behaviour is contradictory with a chordal keyboard, because you need to release the chord to cause it to be typed. To enable this behaviour 1 button remembers the most recently executed letter. You can hold this button down to type that letter many times.
It remembers modifiers too, so you can hold down CONTROL+SHIFT+x for example.
I use right on the D-pad for this.

1 final button is used for macros.
I use the X button.

Macros
=======

To make a macro, first click the macro button. Then type the letters that you want to store in this macro. Finally, make a chord using the 6 basic buttons + the macro button. Now your macro is stored in that chord with the macro button.

The 6 buttons offer 63 combinations, so it can store up to 63 macros.

To cancel creating a macro, click the macro button again by itself.


Installing
==========

This code was written for and tested with a Logitech F310 gamepad, but it should be easy to configure for other gamepads.

This code was tested with Ubuntu Linux, but it should be easy to make it work on other systems.

You need gcc for compiling the software.
You need a gamepad to test it with.

Plug in your gamepad, and run `sh start.sh`

CONFIGURATION
==========

The top of the chorded_gamepad.c file has a commented region explaining what can be customized.

The configuratoin includes some notes about how the keys are organized onto chords, and a cheatsheet to help you memorize the chords.