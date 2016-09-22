// labellingMachine Code!

#include "app.h"

#define BAUDRATE (115200)

App *app;

void setup(){
  Serial.begin(BAUDRATE);
  while (!Serial) {;}
  
  // get the Serial working!
  establishContact();
  
  // create the app!
  app = new App();
}

// loop the loop, asshole!
void loop(){
  app->loop();
}

void establishContact() {
  int inByte;
  
  while (Serial.available() <= 0) {
    Serial.print('A');   // send a capital A
    delay(300);
  }
  while (Serial.available() <0) {;}
    inByte = Serial.read();
}

 
