#include "sticker.h"
#include "stickerDequeue.h"
#include "detector.h"

Tag *t;
Label *l;
StickerDequeue *sd;
SimulatedPhysicalDetector *sDet;
Detector *detector;

void setup() {
  Serial.begin(9600);
  while (!Serial){}

  sDet = new SimulatedPhysicalDetector(100);
  detector = new Detector(*sDet);
  bool detection=false;
  for (int i=0; i< 200;i++){
    if (detector->stickerDetected(i)){
      detection=true;
      Serial.print("Sticker Detected at:\t");
      Serial.println(i);
      break;
    }
  }
  if (!detection){
    Serial.println("Nothing detected...");
  }
  
  t = new Tag();
  l = new Label();
  sd = new StickerDequeue(l);
  Serial.println("pushed! label!");
  for (int i = 0;i<5;i++){
    Serial.println("pushed! pair");
    sd->push(l);
    sd->push(t);
  }
  Serial.println("Dequeue Content:");
  for (dNode* s = sd->getHead(); s != NULL; s = s->nxtptr){
    Serial.println(s->data->getType());
  }
  Serial.println("Popping Dequeue:");
  Sticker *res = sd->pop();
  while(res){
    Serial.println("popped!");
    Serial.println(res->getType());
    res = sd->pop();
  }
}
void loop() {
  // put your main code here, to run repeatedly:

}
