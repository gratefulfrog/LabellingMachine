/*

labellingMachine Code!
 */


void setup() {
  //Serial.begin(9600);
  Serial.begin(115200);
  while (!Serial) {;}
  establishContact();
  
  /*byte b = 1;
  while (b){
     Serial.write(b);
     b = (b<<1);
  }
  */
}



unsigned long counter = 0,
              killCounter = 0;

void loop() {
  if (killCounter > 0 && !(killCounter % 750)){ // remove
    killCounter-=220;
    Serial.write(1<<3);
  }
  if ( !(counter % 220)){ // add label
    Serial.write(1<<4);
  }
  if ( !(counter % 220)){ // addd tag 120 is the normal sep
    Serial.write(1<<5);
  }
  if (counter && !(counter % 1219)){ // end of spool
    Serial.write(1<<6);
  }
  if (counter && !(counter % 2797)){ // end of spool
    Serial.write(1<<7);
  }
   
  Serial.write(B111);
  counter++;
  killCounter++;
  delay(1);
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

