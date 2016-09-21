# include "sticker.h"
# include "stickerDequeue.h"

Tag *t;
Label *l;
StickerDequeue *sd;

void setup() {
  Serial.begin(9600);
  while (!Serial){}
  
  t = new Tag();
  l = new Label();
  sd = new StickerDequeue();
  for (int i = 0;i<5;i++){
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
