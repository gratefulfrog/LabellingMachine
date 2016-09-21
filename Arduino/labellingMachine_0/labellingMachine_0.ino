/*

labellingMachine Code!
 */
#include "sticker.h"
#include "stickerDequeue.h"
#include "detector.h"
#include  "config.h"
#include  "driver.h"

#define LABEL_DELAY (320)
#define TAG_DELAY  (100)
#define KILL_DELAY (220)

Detector *lDetector,
         *tDetector,
         *bDetector;
         
StickerDequeue *lDeq,
               *tDeq;

Driver *tagger,
         *labeller,
         *backer;
PhyscialDriver *pd;

byte outgoing = 0;
unsigned long counter =0;

Detector *makeDetector(unsigned long nbSteps, bool reset){
  return new Detector(*(new SimulatedPhysicalDetector(nbSteps, reset)));
}

void setup() {
  pd = new PhyscialDriver();
  
  lDeq = new StickerDequeue(new Label());
  tDeq = new StickerDequeue(new Tag());
  
  tagger   = new Driver(0,tDeq,lDeq,pd);
  labeller = new Driver(1,tDeq,lDeq,pd);
  backer   = new Driver(2,tDeq,lDeq,pd);
  /* 
  Serial.begin(9600);
  while (!Serial) {}
  
  Serial.println("ah");
  tagger->canAdvance();
  labeller->canAdvance();
  backer->canAdvance();
  Serial.println(tagger->getStepOK());
  //Serial.println(tagger->getSupportID());
  Serial.println(labeller->getStepOK()); 
  //Serial.println(labeller->getSupportID());  
  Serial.println(backer->getStepOK()); 
  //Serial.println(backer->getSupportID());
  Serial.println("oops");
  */
  lDeq = new StickerDequeue(new Label());
  tDeq = new StickerDequeue(new Tag());
  lDetector = makeDetector(LABEL_DELAY, true);
  tDetector = makeDetector(TAG_DELAY, true);
  bDetector = makeDetector(KILL_DELAY, false);
  //Serial.begin(9600);
  Serial.begin(115200);
  while (!Serial) {;}
  establishContact();
  outgoing = B110000;
  Serial.write(outgoing);
  outgoing = 0;
}

void  setAlerts(){
  //outgoing |= (counter && !(counter % 1219)) ? (1<<6) : 0;
  //outgoing |= (counter && !(counter % 2797)) ? (1<<7) : 0;
}

void detectNewTagsAndLabels(){
  if(lDetector->stickerDetected(labeller->getNbSteps())){
    // create a new pair here
    outgoing |= (1<<4);
    lDeq->push(new Label());
  }
  if(tDetector->stickerDetected(tagger->getNbSteps())){
    outgoing |= (1<<5) ;
    tDeq->push(new Tag());
  }
}

void detectedExpiredTagLabelPairs(){
  if (bDetector->stickerDetected(lDeq->getHead()->data->getNbSteps())){  
    // remove labels and tags off the end  
    delete lDeq->pop();
    delete tDeq->pop();
    outgoing |=  (1<<3);
  }
}
void updateStickerSupport(){
  StickerDequeue * qs[] = {lDeq,tDeq};
  int lims[] = {Config::LB0steps,Config::TB0steps};
  
  for (int i=0;i<2;i++){
    StickerDequeue *sd = qs[i]; 
    for (dNode* s = sd->getHead(); s != NULL; s = s->nxtptr){
      if(s->data->getNbSteps() >= lims[i]) { // then it's on the backer
        s->data->setSupport(2);
      }
    }
  }
}

void setDriversOk2Step(){
   if(backer->canAdvance()){
    outgoing |=1;
   }
   if(labeller->canAdvance()){
    outgoing |= (1<<1);
   }
   if (tagger->canAdvance()){
    outgoing |= (1<<2);
   }
  
   
  //outgoing |= B111;
}
void stepAll(){
   
  labeller->step();
  tagger->step(); 
  backer->step();
  outgoing = 0;
  /*
  StickerDequeue * qs[] = {lDeq,tDeq};
  for (int i=0;i<2;i++){
    StickerDequeue *sd = qs[i]; 
    for (dNode* s = sd->getHead(); s != NULL; s = s->nxtptr){
      s->data->step();
    }
  }
  */
}  

void loop() {
  /*
   * Algo:
   * 1. DONE: reset outgoing
   * 2. DONE: detect alerts, and OR into outgoing
   * 3. DONE: detect new tag, label, end, or that to outgoing
   * 4. DONE: update the support of each sticker (DEFNITLY NEEDED!)
   * 5. DONE: for each driver, set OK2Step and OR that to the outgoing
   * 6. send outgoing
   * 7. step all as per step ok
   */
  outgoing = 0;
  setAlerts();
  detectNewTagsAndLabels();
  detectedExpiredTagLabelPairs();
  updateStickerSupport();
  setDriversOk2Step();
  Serial.write(outgoing);
  stepAll();  // resets outgoing to 0
  
  counter++;
  delay(5);  // min for processing is 3 on my PC
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

