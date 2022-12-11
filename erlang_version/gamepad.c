
#include <stdio.h>
#include <unistd.h>
#include <linux/joystick.h>
#include <fcntl.h>

typedef unsigned char byte;

//for talking at erlang.
int write_exact(byte *buf, int len)
{
  int i, wrote = 0;

  do {
    if ((i = write(1, buf+wrote, len-wrote)) <= 0)
      return (i);
    wrote += i;
  } while (wrote<len);

  return (len);
}
int write_cmd(byte *buf, int len)
{
  byte li;

  li = (len >> 8) & 0xff;
  write_exact(&li, 1);
  
  li = len & 0xff;
  write_exact(&li, 1);

  return write_exact(buf, len);
}



char gamepad_location[128] = "/dev/input/js0";
byte buffer[3] = { 0 };

int process_events
(struct js_event js, struct input_event event)
{
  int type_check = js.type & ~JS_EVENT_INIT;
  if((type_check == JS_EVENT_BUTTON)||
     ((type_check == JS_EVENT_AXIS) &&
    // iNNEXT
      ((js.number == 0) ||
       (js.number == 1)//))){
    // Logitech
       ||
       (js.number == 6) ||
       (js.number == 7)))){
      //js.number is the button.
      //js.type is the type.
      //js.value is the value.
    //printf("button: %i type: %i value: %i\n",
    //       js.number, js.type, js.value);
    buffer[0] = js.number;
    buffer[1] = js.type;
    buffer[2] = js.value;
    write_cmd(buffer, 3);
  }
  return(0);
}

int main_loop(int joy_fd) {
  struct js_event js;
  struct input_event event;
  while (1){
    if (read(joy_fd, &js, sizeof(struct js_event)) != sizeof(struct js_event)){
      printf("error reading from device");
      return(-1);
    }
    process_events(js, event);
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

int main() {
  int joy_fd = load_gamepad();
  main_loop(joy_fd);
  return(0);
}

