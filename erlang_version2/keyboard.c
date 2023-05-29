#include <erl_nif.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include <stdlib.h>
#include <linux/input.h>
#include <linux/uinput.h>
//#include <linux/joystick.h>
#include <fcntl.h>
#include <unistd.h>


int uinp_fd;//pointer to virtual keyboard

__u16 keys[128];

void setup_keys(){
keys[1] = KEY_TAB;
keys[2] = KEY_ENTER;
keys[3] = KEY_BACKSPACE;
keys[4] = KEY_DELETE;
keys[5] = KEY_ESC;
keys[6] = KEY_LEFT;
keys[7] = KEY_RIGHT;
keys[8] = KEY_UP;
keys[9] = KEY_DOWN;
keys[10] = KEY_A;
keys[11] = KEY_B;
keys[12] = KEY_C;
keys[13] = KEY_D;
keys[14] = KEY_E;
keys[15] = KEY_F;
keys[16] = KEY_G;
keys[17] = KEY_H;
keys[18] = KEY_I;
keys[19] = KEY_J;
keys[20] = KEY_K;
keys[21] = KEY_L;
keys[22] = KEY_M;
keys[23] = KEY_N;
keys[24] = KEY_O;
keys[25] = KEY_P;
keys[26] = KEY_Q;
keys[27] = KEY_R;
keys[28] = KEY_S;
keys[29] = KEY_T;
keys[30] = KEY_U;
keys[31] = KEY_V;
keys[32] = KEY_W;
keys[33] = KEY_X;
keys[34] = KEY_Y;
keys[35] = KEY_Z;
keys[36] = KEY_0;
keys[37] = KEY_1;
keys[38] = KEY_2;
keys[39] = KEY_3;
keys[40] = KEY_4;
keys[41] = KEY_5;
keys[42] = KEY_6;
keys[43] = KEY_7;
keys[44] = KEY_8;
keys[45] = KEY_9;
keys[46] = KEY_F1;
keys[47] = KEY_F2;
keys[48] = KEY_F3;
keys[49] = KEY_F4;
keys[50] = KEY_F5;
keys[51] = KEY_F6;
keys[52] = KEY_F7;
keys[53] = KEY_F8;
keys[54] = KEY_F9;
keys[55] = KEY_F10;
keys[56] = KEY_F11;
keys[57] = KEY_F12;
keys[58] = KEY_APOSTROPHE;
keys[59] = KEY_COMMA;
keys[60] = KEY_DOT;
keys[61] = KEY_SEMICOLON;
keys[62] = KEY_RIGHTBRACE;     
keys[63] = KEY_LEFTBRACE;
keys[64] = KEY_GRAVE;
keys[65] = KEY_SLASH;
keys[66] = KEY_BACKSLASH;
keys[67] = KEY_EQUAL;
keys[68] = KEY_MINUS;
keys[69] = KEY_SPACE;
keys[70] = KEY_PAGEUP;
keys[71] = KEY_PAGEDOWN;
//keys[68] = KEY_PRINTSCREEN;
//keys[60] = KEY_QUESTION_MARK;     
}

void emit(int fd, int type, int code, int val)
{
   struct input_event ie;
   ie.type = type;
   ie.code = code;
   ie.value = val;
   //printf("type: %i, code: %i, value: %i\n", type, code, val);
   write(fd, &ie, sizeof(ie));
}
void key_down(int fd, __u16 key){
  //printf("down %i,", key);
  emit(fd, EV_KEY, key, 1);
  emit(fd, EV_SYN, SYN_REPORT, 0);
}
void key_up(int fd, __u16 key){
  //printf("up %i,", key);
  emit(fd, EV_KEY, key, 0);
  emit(fd, EV_SYN, SYN_REPORT, 0);
}

static ERL_NIF_TERM press
(ErlNifEnv* env, int argc,
 const ERL_NIF_TERM argv[])
{
  ErlNifUInt64 Key, Shift, Control, Alt;
  enif_get_uint64(env, argv[0], &Key);
  enif_get_uint64(env, argv[1], &Shift);
  enif_get_uint64(env, argv[2], &Control);
  enif_get_uint64(env, argv[3], &Alt);
  if(Control){
    key_down(uinp_fd, KEY_LEFTCTRL);
  }
  if(Shift){
    key_down(uinp_fd, KEY_LEFTSHIFT);
  }
  if(Alt){
    key_down(uinp_fd, KEY_LEFTALT);
  }
  //key_down(uinp_fd, Key);
  //printf("%i\n", KEY_Z)
  key_down(uinp_fd, keys[Key]);
  //key_up(uinp_fd, keys[Key]);
  /*
  if(Alt){
    key_up(uinp_fd, KEY_LEFTALT);
  }
  if(Shift){
    key_up(uinp_fd, KEY_LEFTSHIFT);
  }
  if(Control){
    key_up(uinp_fd, KEY_LEFTCTRL);
  }
  */
  return argv[0];
}
static ERL_NIF_TERM unpress
(ErlNifEnv* env, int argc,
 const ERL_NIF_TERM argv[])
{
  ErlNifUInt64 Key, Shift, Control, Alt;
  enif_get_uint64(env, argv[0], &Key);
  enif_get_uint64(env, argv[1], &Shift);
  enif_get_uint64(env, argv[2], &Control);
  enif_get_uint64(env, argv[3], &Alt);
  /*
  if(Control){
    key_down(uinp_fd, KEY_LEFTCTRL);
  }
  if(Shift){
    key_down(uinp_fd, KEY_LEFTSHIFT);
  }
  if(Alt){
    key_down(uinp_fd, KEY_LEFTALT);
  }
  */
  //key_down(uinp_fd, keys[Key]);
  key_up(uinp_fd, keys[Key]);
  if(Alt){
    key_up(uinp_fd, KEY_LEFTALT);
  }
  if(Shift){
    key_up(uinp_fd, KEY_LEFTSHIFT);
  }
  if(Control){
    key_up(uinp_fd, KEY_LEFTCTRL);
  }
  return argv[0];
}
static ERL_NIF_TERM key
(ErlNifEnv* env, int argc,
 const ERL_NIF_TERM argv[])
{
  ErlNifUInt64 Key, Shift, Control, Alt;
  enif_get_uint64(env, argv[0], &Key);
  enif_get_uint64(env, argv[1], &Shift);
  enif_get_uint64(env, argv[2], &Control);
  enif_get_uint64(env, argv[3], &Alt);
  //printf("in key\n");
  //printf("shift is: %li\n", Shift);
  if(Control){
    key_down(uinp_fd, KEY_LEFTCTRL);
  }
  if(Shift){
    //printf("<S");
    key_down(uinp_fd, KEY_LEFTSHIFT);
    //key_down(uinp_fd, 42);
  }
  if(Alt){
    key_down(uinp_fd, KEY_LEFTALT);
  }
  //key_down(uinp_fd, Key);
  //printf("%i\n", KEY_Z)
  //printf("[");
  key_down(uinp_fd, keys[Key]);
  key_up(uinp_fd, keys[Key]);
  usleep(10000);
  //printf("]");
  if(Alt){
    key_up(uinp_fd, KEY_LEFTALT);
  }
  if(Shift){
    //printf("S>");
    key_up(uinp_fd, KEY_LEFTSHIFT);
    //key_up(uinp_fd, 42);
  }
  if(Control){
    key_up(uinp_fd, KEY_LEFTCTRL);
  }
  //printf("\n");
  //printf("finished in key\n");
  return argv[0];
}


int load_virtual_keyboard(){
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


static ERL_NIF_TERM setup
(ErlNifEnv* env, int argc,
 const ERL_NIF_TERM argv[])
{
  setup_keys();
  int uinp_fd = load_virtual_keyboard();
  return(argv[0]);
}


static ErlNifFunc nif_funcs[] =
  {
   {"key", 4, key},
   {"press", 4, press},
   {"unpress", 4, unpress},
   {"setup", 1, setup}
  };

ERL_NIF_INIT(keyboard,nif_funcs,NULL,NULL,NULL,NULL)
