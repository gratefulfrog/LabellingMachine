#include  "app.h"
#include  "hwConfig.h"

App::App() {
  // create the dequeues and put a new tag and lable on the dequeues (only for simulation!) 
  lDeq = new StickerDequeue(new Label(-Config::Lsteps));
  tDeq = new StickerDequeue(new Tag(-Config::Tsteps));
  
  // inidcate that the initial label and tag are detected! (only for simulation!)
  outgoing = B110000;  
  // create the drivers
  
  tagger   = new Driver(0,tDeq,lDeq,HWConfig::taggerPin);
  labeller = new Driver(1,tDeq,lDeq,HWConfig::labellerPin);
  backer   = new Driver(2,tDeq,lDeq,HWConfig::backerPin);

  // create our pretend detectors (only for simulation!)
  lDetector = makeDetector(LABEL_DELAY,true);
  tDetector = makeDetector(TAG_DELAY,  true);
  bDetector = makeDetector(KILL_DELAY, false);
  eDetector = makeDetector(END_DELAY,  true);  // end of roll detector
  jDetector = makeDetector(JAM_DELAY,  true); // jam detector

  // send initial state
  Serial.write(outgoing);
}

Detector* App::makeDetector(long nbSteps, bool reset){
  // in the machine, use the real pPhysicalDetector class!
  return new Detector(*(new SimulatedPhysicalDetector(nbSteps, reset)));
}

void  App::setAlerts(){
  // (only for simulation!)
  if(eDetector->stickerDetected(labeller->getNbSteps())){
    outgoing |= (1<<6);
  }
  if(jDetector->stickerDetected(labeller->getNbSteps())){
    outgoing |=(1<<7);
  }
}

void App::detectNewTagsAndLabels(){
  if(lDetector->stickerDetected(labeller->getNbSteps())){
  //if(lDetector->stickerDetected(lDeq->getTail()->data->getNbSteps())){
    // create a new pair here
    outgoing |= (1<<4);
    //lDeq->push(new Label());
    lDeq->push(new Label(-Config::Lsteps));
  }
  if(tDetector->stickerDetected(tagger->getNbSteps())){
  //if(tDetector->stickerDetected(tDeq->getTail()->data->getNbSteps())){
    outgoing |= (1<<5) ;
    //tDeq->push(new Tag());
    tDeq->push(new Tag(-Config::Tsteps));
  }
}

void App::detectedExpiredTagLabelPairs(){
  if (bDetector->stickerDetected(lDeq->getHead()->data->getNbSteps())){  
    // remove labels and tags off the end  
    delete lDeq->pop();
    delete tDeq->pop();
    outgoing |=  (1<<3);
  }
}
void App::updateStickerSupport(){
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

void App::setDriversOk2Step(){
   if(backer->canAdvance()){
    outgoing |=1;
   }
   if(labeller->canAdvance()){
    outgoing |= (1<<1);
   }
   if (tagger->canAdvance()){
    outgoing |= (1<<2);
   }
}

void App::stepAll(){
  labeller->step();
  tagger->step(); 
  backer->step();
}  

void App::loop() {
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
  delay(HWConfig::visualizationDelay);  // min for processing is 3 on my PC
}
