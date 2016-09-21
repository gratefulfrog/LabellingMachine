/*

labellingMachine Code!
 */
#include "sticker.h"
#include "stickerDequeue.h"
#include "detector.h"

#define LABEL_DELAY (220)
#define TAG_DELAY  (120)
#define KILL_DELAY (750)

Detector *lDetector,
         *tDetector,
         *bDetector;
StickerDequeue *lDeq,
               *tDeq;

Detector *makeDetector(unsigned long nbSteps, bool reset){
  return new Detector(*(new SimulatedPhysicalDetector(nbSteps, reset)));
}

void setup() {
  lDeq = new StickerDequeue(new Label());
  tDeq = new StickerDequeue(new Tag());
  lDetector = makeDetector(LABEL_DELAY, true);
  tDetector = makeDetector(TAG_DELAY, true);
  bDetector = makeDetector(KILL_DELAY, false);
  //Serial.begin(9600);
  Serial.begin(115200);
  while (!Serial) {;}
  establishContact();
  
}

void stepAll(){
  StickerDequeue * qs[] = {lDeq,tDeq};
  for (int i=0;i<2;i++){
    StickerDequeue *sd = qs[i]; 
    for (dNode* s = sd->getHead(); s != NULL; s = s->nxtptr){
      s->data->step();
    }
  }
}

unsigned long counter = 0,
              killCounter = 0;

byte outgoing = B00110000;

void loop() {
  if (bDetector->stickerDetected(lDeq->getHead()->data->getNbSteps())){    
    delete lDeq->pop();
    delete tDeq->pop();
    outgoing |=  (1<<3);
  }
  if(lDetector->stickerDetected(counter)){
    outgoing |= (1<<4);
    lDeq->push(new Label());
  //}
  //if (tDetector->stickerDetected(counter)){
     outgoing |= (1<<5) ;
     tDeq->push(new Tag());
  }
 
  outgoing |= (counter && !(counter % 1219)) ? (1<<6) : 0;
  outgoing |= (counter && !(counter % 2797)) ? (1<<7) : 0;
  Serial.write(outgoing);
  stepAll();
  outgoing = B111;
  /*
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
  */
  //Serial.write(B111);
  counter++;
  killCounter++;
  delay(10);

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

