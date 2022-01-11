Chorded Gamepad 
==========

This is software so you can use a gamepad as a chorded keyboard.
This is based on joy2chord. https://github.com/wirelessdreamer/joy2chord
If the software in this repository doesn't work for you, maybe try out joy2chord instead.

The buttons
=============

I use a Logitech F310 gamepad, so I will explain which buttons I use for this gamepad. You can configure it to use whatever buttons you want on your gamepad.

Uses 12 buttons in total.

It uses 6 basic buttons to encode lower case letters, numbers, and some symbols.
I use A, B, right bumper, down on D-pad, left on D-pad, and left bumper.

The combinations of buttons that encode each key can all be configured. The default configuration is based on the idea that more common letters in english should require fewer fingers to type, and that consonants are grouped into pairs based on logical relationships in their sounds. voiced/unvoiced pairs, the nasal pair, etc.

3 more buttons are for Control, Alt, and Shift. These modifiers can be combined with combinations of the 6 basic buttons to enable capital letters, CONTROL+s etc.
I use left trigger, Y button, and right trigger.

With a keyboard, if you hold a key down you can cause that letter to get repeatedly typed many times. This behaviour is contradictory with a chordal keyboard, because you need to release the chord to cause it to be typed. To enable this behaviour 1 button remembers the most recently executed letter. You can hold this button down to type that letter many times.
It remembers modifiers too, so you can hold down CONTROL+SHIFT+x for example.
I use up on the D-pad for this.

2 buttons are used for macros.
One for making macros and calling stored macros, the other is used to cancel macro creation.
I use the X button for creating and calling.
I use right on the D-pad for canceling.

Macros
=======

To make a macro, first click the macro button. Then type the letters that you want to store in this macro. Finally, make a chord using the 6 basic buttons + the macro button. Now your macro is stored in that chord with the macro button.

The 6 buttons offer 63 combinations, so it can store up to 63 macros.

There is a button for canceling macro creation, if you change your mind and don't want to create that macro.

Installing
==========

This code was written for and tested with a Logitech F310 gamepad, but it should be easy to configure for other gamepads.

This code was tested with Ubuntu Linux, but it should be easy to make it work on other systems.

You need gcc for compiling the software.
You need a gamepad to test it with.

You need permission to /dev/uinput, which is the virtual keyboard to allow this program to type. By default you do not have this permission, you need to enable it.
To gain permission, first make a new group for the users that have permission to access the virtual keyboard:
`sudo groupadd -f uinput`

Next add yourself to the new group:
`sudo gpasswd -a username uinput`
Use your own username instead of the word "username".

Next create the file /etc/udev/rules.d/99-input.rules
Write this in the file:
`KERNEL=="uinput", GROUP="uinput", MODE:="0660"`

To activate the new settings, either reboot, or do this:
```
sudo udevadm control --reload
sudo udevadm trigger --type=devices --sysname-match=uinput
```
and reload your account to have access to your new permissions: `su username`
Use your own username instead of the word "username".

To verify that you now have permission for uinput `ls -l /dev/uinput` should print out something like: `crw-rw---- 1 root uinput 10, 223 Nov 11 15:35 /dev/uinput` the `crw-rw---` and the `uinput` are the important parts.

To verify that your current account is a member of the uinput group do `groups`, which prints a list of groups that you are a member of. "uinput" should be in this list.

Plug in your gamepad, and run `sh start.sh`

CONFIGURATION
==========

The top of the chorded_gamepad.c file has a commented region explaining what can be customized.

The configuration includes some notes about how the keys are organized onto chords, and a cheatsheet to help you memorize the chords.



Erlang Version
==========

As of January 2022 the erlang version of the program is working pretty well.
It works similarly, but only the minimal part of the code is written in C, the rest is in erlang. So it is much faster to edit and try out changes.

The erlang version does not currently support macros.

It uses 7 buttons. 6 for making chords, and the repeaters button.
To fit everything into only 6 buttons instead of 8, I needed to give it several pages.
The A button is like "shift" it capitalizes the next letter.
the B button is like "control" for the next letter.
Down on the D pad is so that the next chord will access a number or symbol instead of a letter.

to run the erlang version, go to the "erlang_version" directory, and do `sh start.sh`
If you want to customize this code, you probably want to do that in the gamepad.erl file. Specifically the chord2key function, which maps the chords on each page to their corresponding key.