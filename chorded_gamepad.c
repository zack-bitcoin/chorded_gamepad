#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <linux/input.h>
#include <linux/uinput.h>
#include <linux/joystick.h>
#include <fcntl.h>
#include <unistd.h>
void start_with_blank_keys();
__u16 keys[64];

//CONFIGURATION. this is the part you want to edit to customize for your gamepad.

//use jstest to identify the number for your button/trigger.
char gamepad_location[128] = "/dev/input/js0";
int chord_size = 10;
//first 6 buttons encode the chord. then the macro button, then control, shift, and finally the alt button.
int buttons[10] =
  {0,1,5,7,6,4,2,2,5,3};
int button_types[10] =
  {1,1,1,2,2,1,1,2,2,1};//2 is for triggers.
int button_threshold[10] =
  {1,1,1,32767,-32767,1,1,1,1,1};
//button number, type, value.
int repeater[3] = {7, 2, -32767};
int cancel_macro[3] = {6, 2, 32767};

void configure_keys(){
  start_with_blank_keys();
  // the 6 keys of the chord encode a binary number.
  // keys[64] links that binary number to the code for that key.
  keys[1] = KEY_SPACE;
  keys[2] = KEY_BACKSPACE;
  keys[3] = KEY_C;
  keys[4] = KEY_ENTER;
  keys[5] = KEY_L;
  keys[6] = KEY_T;
  keys[7] = KEY_RIGHTBRACE;     
  keys[8] = KEY_A;
  keys[9] = KEY_S;
  keys[10] = KEY_X;
  keys[11] = KEY_W;
  keys[12] = KEY_U;
  keys[13] = KEY_J;
  keys[14] = KEY_SEMICOLON;
  keys[15] = KEY_0;
  keys[16] = KEY_E;
  keys[17] = KEY_Y;
  keys[18] = KEY_H;
  keys[19] = KEY_DOT;//16, 2, 1
  keys[20] = KEY_M;
  keys[21] = KEY_MINUS;//16,4,1
  keys[22] = KEY_GRAVE;//16, 4, 2
  keys[23] = KEY_LEFT;//16,4,2,1
  keys[24] = KEY_K;
  keys[25] = KEY_V;
  keys[26] = KEY_COMMA;
  keys[27] = KEY_DOWN;
  keys[28] = KEY_SLASH;//16,8,4
  keys[29] = KEY_1;
  keys[30] = KEY_5;
  keys[31] = KEY_F9;//16, 8, 4, 2, 1
  keys[32] = KEY_I;
  keys[33] = KEY_O;
  keys[34] = KEY_N;
  keys[35] = KEY_BACKSLASH;//32, 2, 1
  keys[36] = KEY_F;
  keys[37] = KEY_B;
  keys[38] = KEY_Q;
  keys[39] = KEY_6;//32, 4, 2, 1
  keys[40] = KEY_R;
  keys[41] = KEY_Z;
  keys[42] = KEY_EQUAL;
  keys[43] = KEY_3;
  keys[44] = KEY_G;
  keys[45] = KEY_4;
  keys[46] = KEY_7;
  keys[47] = KEY_RESERVED;//32, 8, 4, 2, 1
  keys[48] = KEY_D;
  keys[49] = KEY_TAB;
  keys[50] = KEY_APOSTROPHE;//32, 16, 2
  keys[51] = KEY_ESC;
  keys[52] = KEY_P;
  keys[53] = KEY_9;
  keys[54] = KEY_UP;
  keys[55] = KEY_RESERVED;//32, 16, 4, 2, 1
  keys[56] = KEY_LEFTBRACE;//32, 16, 8
  keys[57] = KEY_2;
  keys[58] = KEY_RIGHT;//32, 16, 8, 2
  keys[59] = KEY_F8;
  keys[60] = KEY_8;//32, 16, 8, 4
  keys[61] = KEY_RESERVED;//32, 16, 8, 4, 1
  keys[62] = KEY_RESERVED;//32,16,8,4,2
  keys[63] = KEY_RESERVED;//32,16,8,4,2,1

  //one button
  //space backspace newline a e i

  //two buttons todo
  //fhs  more common english letters
  //xy lr ck td nm ou

  //three buttons
  //[] \/
  //tab; -=
  //'` ,.
  // gbpq
  //wv jz less common english letters

  //four buttons
  //1234567890
  //esc
  //up down right left

  //five buttons
  //f9 f8

  //six buttons
  //reserved

  //memorization cheatsheet
  // space 1; backspace 2; enter 4;
  // A 8 ; B 37; C 3; D 48 ; E 16
  // F 36; G 44; H 18; I 32; J 13
  // K 24 ; L 5 ; M 20; N 34; O 33
  // P 38; Q 52; R 40; S 9; T 6
  // U 12; V 25; W 11; X 10; Y 17
  // Z 41
  // right 58; left 23; up 54; down 27
  // ' 50; ` 22; [ 56; ] 7;
  // / 28; \ 35; ; 14; tab 49
  // - 21; = 42; . 19; , 26
  // f8 28; f9 31;
  // 0 15; 1 29; 2 57; 3 43; 4 45;
  // 5 30; 6 39; 7 46; 8 60; 9 53;
}
//END CONFIGURATION. you probably don't want to edit below this line.

int state[10] = {0,0,0,0,0,0,0,0,0,0};
int this_chord[10] = {0,0,0,0,0,0,0,0,0,0};
int making_a_macro = 0;

struct code {
  __u16 key;
  int shift;
  int alt;
  int control;
  int meta;
  struct code * next;
};

struct code last_code;
struct code repeater_code_now;
struct code macro;
struct code * macros[63];

struct code new_code(__u16 key){
  struct code x;
  x.key = key;
  x.shift = 0;
  x.alt = 0;
  x.control = 0;
  x.meta = 0;
  x.next = NULL;
  return(x);
};

void append_code(struct code * x, struct code y){
  if(x->next == NULL){
    struct code * z;
    z = (struct code*)malloc(sizeof(struct code));
    *z = y;
    x->next = z;
  } else {
    append_code(x->next, y);
  }
}

int print_code(struct code x){
  //for testing purposes.
  printf("key: %i, shift: %i, alt: %i, control: %i\n",
         x.key, x.shift, x.alt, x.control);
  if(x.next == NULL){
    printf("print null\n");
    return(0);
  } else {
    print_code(*x.next);
  }
}
void print_state_now(){
  //for testing purposes.
  printf("state now %i %i %i %i %i %i %i %i %i %i\n",
         state[0], state[1], state[2],
         state[3], state[4], state[5],
         state[6], state[7], state[8],
         state[9]);
}
void print_this_chord(){
  //for testing purposes.
  printf("chord now %i %i %i %i %i %i %i %i %i %i\n",
         this_chord[0], this_chord[1], this_chord[2],
         this_chord[3], this_chord[4], this_chord[5],
         this_chord[6], this_chord[7], this_chord[8],
         this_chord[9]);
}
void print_js(struct js_event js){
  //for testing purposes.
  printf("button- type: %i value: %i number: %i\n", js.type, js.value, js.number);
}

void emit(int fd, int type, int code, int val)
{
   struct input_event ie;
   ie.type = type;
   ie.code = code;
   ie.value = val;
   write(fd, &ie, sizeof(ie));
}
void key_down(int fd, __u16 key){
  emit(fd, EV_KEY, key, 1);
  emit(fd, EV_SYN, SYN_REPORT, 0);
}
void key_up(int fd, __u16 key){
  emit(fd, EV_KEY, key, 0);
  emit(fd, EV_SYN, SYN_REPORT, 0);
}
int code_down(struct code * x, int fd){
  if(x->control){
    key_down(fd, KEY_LEFTCTRL);
  }
  if(x->shift){
    key_down(fd, KEY_LEFTSHIFT);
  }
  if(x->alt){
    key_down(fd, KEY_LEFTALT);
  }
  if(x->meta){
    key_down(fd, KEY_LEFTMETA);
  }
  key_down(fd, x->key);
  return(0);
};
int code_up(struct code * x, int fd){
  key_up(fd, x->key);
  if(x->meta){
    key_up(fd, KEY_LEFTMETA);
  }
  if(x->alt){
    key_up(fd, KEY_LEFTALT);
  }
  if(x->shift){
    key_up(fd, KEY_LEFTSHIFT);
  }
  if(x->control){
    key_up(fd, KEY_LEFTCTRL);
  }
  return(0);
}
int type_code(struct code * x, int fd){
  code_down(x, fd);
  code_up(x, fd);
  if(x->next == NULL){
    return(0);
  } else {
    type_code(x->next, fd);
  }
}
void zero_this_chord(){
  for(int i = 0; i < chord_size; i++){
    this_chord[i] = state[i];
  };
};
int all_chordals_unpressed(){
  for(int i = 0; i < (chord_size-3); i++){
    if(state[i] == 1){
      return(0);
    }
  }
  return(1);
};
int chord_to_val(int * chord){
  int n = 0;
  for(int i = 0; i < (chord_size-3); i++){
    n += (chord[i] << i);
  }
  return(n);
};
int process_chord_buttons(int fd){
  int b = all_chordals_unpressed();
  if(b){
    int n = chord_to_val(this_chord);
    if((n == 64) && (!(making_a_macro))){
      //printf("making a new macro\n");
      making_a_macro = 1;
    } else if((n == 64) && (making_a_macro)){
    } else if((n>64) && making_a_macro){
      //printf("store macro in %i\n", n-64);
      struct code * mcopy;
      mcopy = (struct code*)malloc(sizeof(struct code));
      *mcopy = macro;
      macros[n-64] = mcopy;
      making_a_macro = 0;
      macro = new_code(KEY_RESERVED);
    } else if((n>64)&&(macros[n-64])){
      //printf("call macro %i\n", n-64);
      type_code(macros[n-64], fd);
    } else if(n){
      __u16 key = keys[n];
      // printf("key number %i\n", n);
      struct code y = new_code(key);
      y.control = this_chord[7];
      y.shift = this_chord[8];
      y.alt = this_chord[9];
      type_code(&y, fd);
      if(making_a_macro){
        append_code(&macro, y);
      };
      last_code = y;
    }
    zero_this_chord();
  }
};
int is_chord_button(struct js_event js){
  for(int i = 0; i < chord_size; i++){
    if((buttons[i] == js.number) &&
       (button_types[i] == js.type)){
      return(i);
    }
  }
  return(-1);
}
int repeat_key_pressed(){
  return(!(repeater_code_now.key == KEY_RESERVED));
}
int process_cancel_macro(struct js_event js){
  if((js.number == cancel_macro[0]) &&
     (js.type == cancel_macro[1]) &&
     (js.value == cancel_macro[2])){
    //printf("cancel making a macro\n");
    making_a_macro = 0;
    macro = new_code(KEY_RESERVED);
  };
}
int process_repeater(struct js_event js, int fd){
  if((js.number == repeater[0]) &&
     (js.type == repeater[1])){
    if(js.value == repeater[2]){
      repeater_code_now = last_code;
      code_down(&repeater_code_now, fd);
    } else {
      code_up(&repeater_code_now, fd);
      repeater_code_now = new_code(KEY_RESERVED);
    }
  }
}
int threshold_exceeded(int threshold, int value){
  if(threshold < 0){
    return(value <= threshold);
  } else {
    return(value >= threshold);
  };
};
int process_events(struct js_event js, struct input_event event, int uinp_fd){
  int type_check = js.type & ~JS_EVENT_INIT;
  if((type_check == JS_EVENT_BUTTON)||
     (type_check == JS_EVENT_AXIS)){
    process_cancel_macro(js);
    process_repeater(js, uinp_fd);
    if(repeat_key_pressed()){
      return(0);
    };
    int b = is_chord_button(js);
    if(b != -1){
      if(threshold_exceeded(button_threshold[b], js.value)){
        state[b] = 1;
        this_chord[b] = 1;
      } else {
        state[b] = 0;
      }
      process_chord_buttons(uinp_fd);
    };
  };
  return(0);
}
int main_loop(int joy_fd, int uinp_fd) {
  struct js_event js;
  struct input_event event;
  while (1){
    if (read(joy_fd, &js, sizeof(struct js_event)) != sizeof(struct js_event)){
      printf("error reading from device");
      return(-1);
    }
    process_events(js, event, uinp_fd);
  }
  return(0);
}
int load_gamepad(){
  int joy_fd = open(gamepad_location, O_RDONLY);
  char name[128];
  if(0 > joy_fd){
    printf("error opening gamepad\n");
    return(0);
  };
  if( 0 > (ioctl(joy_fd, JSIOCGNAME(128), name))){
    printf("error, gamepad cannot load\n");
  } else {
    printf("gamepad ready: %s \n", name);
  }
  return(joy_fd);
}
int load_virtual_keyboard(){
  int uinp_fd;
  uinp_fd = open("/dev/uinput", O_WRONLY | O_NONBLOCK);
  if(uinp_fd < 0){
    printf("error opening /dev/uinput to type to the virtual keyboard");
    return(0);
  };

  ioctl(uinp_fd, UI_SET_EVBIT, EV_KEY);
  __u16 i = 0;
  for(i = 0; i<256; i++){
    ioctl(uinp_fd, UI_SET_KEYBIT, i);
  }

  struct uinput_setup uinp;
  memset(&uinp, 0, sizeof(uinp));
  uinp.id.bustype = BUS_USB;
  uinp.id.vendor = 0x1234; /* sample vendor */
  uinp.id.product = 0x5678; /* sample product */
  strcpy(uinp.name, "Example device");
  
  if( 0 > ioctl(uinp_fd, UI_DEV_SETUP, &uinp)){
    printf("unable to setup UINPUT device");
    return(0);
  };

  if( 0 > (ioctl(uinp_fd, UI_DEV_CREATE))){
    printf("unable to create UINPUT device");
    close(uinp_fd);
    return(0);
  };
  return(uinp_fd);
};
void setup_repeater(){
  last_code = new_code(KEY_RESERVED);
  repeater_code_now = new_code(KEY_RESERVED);
}
void prepare_macro_system(){
  macro = new_code(KEY_RESERVED);
}
void start_with_blank_keys(){
  for(int i = 1; i < 64; i++){
    keys[i] = KEY_RESERVED;
  }
}
void cleanup(int uinp_fd){
  if(ioctl(uinp_fd, UI_DEV_DESTROY)){
    printf("unable to destroy uinput device");
  };
  close(uinp_fd);
}
int main() {
  int joy_fd = load_gamepad();
  int uinp_fd = load_virtual_keyboard();
  setup_repeater();
  prepare_macro_system();
  configure_keys();

  main_loop(joy_fd, uinp_fd);

  cleanup(uinp_fd);
  return(0);
}

