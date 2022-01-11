
gcc -flto -fPIC -shared -o ebin/keyboard.so keyboard.c -I $ERL_ROOT/user/include/

gcc gamepad.c -o ./ebin/gamepad

erlc keyboard.erl
erlc gamepad.erl

erl -s gamepad doit
