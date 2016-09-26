#include  "app.h"
#include  "hwConfig.h"

App::App() {

  if (HWConfig::debug){
    pinMode(DBG_RED,OUTPUT);
    pinMode(DBG_GREEN,OUTPUT);
    pinMode(DBG_YELLOW,OUTPUT);
    
    digitalWrite(DBG_RED,LOW);
    digitalWrite(DBG_GREEN,LOW);
    digitalWrite(DBG_YELLOW,LOW);
    delay(100);
    }
  
  
  // create the dequeues and put a new tag and lable on the dequeues (only for simulation!) 
  lDeq = new StickerDequeue(); //new Label(-Config::Lsteps));
  tDeq = new StickerDequeue(); //new Tag(-Config::Tsteps));
  
  // inidcate that the initial label and tag are detected! (only for simulation!)
  //outgoing = B110000;  
  // create the drivers
  
  tagger   = new Driver(0,tDeq,lDeq,HWConfig::taggerPin);
  labeller = new Driver(1,tDeq,lDeq,HWConfig::labellerPin);
  backer   = new Driver(2,tDeq,lDeq,HWConfig::backerPin);

  // create our pretend detectors (only for simulation!)
  // lDetector = makeDetector(LABEL_DELAY,true,0);
  // tDetector = makeDetector(TAG_DELAY,  true,0);
  lDetector = makeDetector(HWConfig::labelDetectorPause, true, HWConfig::labelDetectorPin );
  tDetector = makeDetector(HWConfig::tagDetectorPause,   true, HWConfig::tagDetectorPin);
  
  bDetector = makeDetector(KILL_DELAY, false,0);
  //eDetector = makeDetector(END_DELAY,  true,0);  // end of roll detector
  //jDetector = makeDetector(JAM_DELAY,  true,0); // jam detector

  // send initial state
  Serial.write(outgoing);
}

Detector* App::makeDetector(long nbPauseSteps, bool reset, int pin){
  // in the machine, use a real PhysicalDetector class!
  if (!pin) { // simulation!
    return new Detector(*(new SimulatedPhysicalEndDetector(nbPauseSteps)));
  }
  else{ // the real thing!
    return new Detector(*(new ContrastDetector(pin,nbPauseSteps)));
  }
}

void  App::setAlerts(){
  return;
  /*  was only for simulation!)
  if(eDetector->stickerDetected(labeller->getNbSteps())){
    outgoing |= (1<<6);
  }
  if(jDetector->stickerDetected(labeller->getNbSteps())){
    outgoing |=(1<<7);
  }
  */
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
  if (!lDeq->getHead()){
    return;
  }
  if (bDetector->stickerDetected(lDeq->getHeadSticker()->getNbSteps())){  
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
   * 2. DONE: detect alerts, then  OR into outgoing
   * 3. DONE: detecte expired label/tags pairs,thne OR that into outgoing
   * 4. DONE: detect new tag, label then  OR that to outgoing
   * 5. DONE: update the support of each sticker (DEFNITLY NEEDED!)
   * 6. DONE: for each driver, set OK2Step then OR that to the outgoing
   * 7. send outgoing
   * 7. step all as per step ok
   */
  outgoing = 0;
  setAlerts();
  detectedExpiredTagLabelPairs();
  detectNewTagsAndLabels();
  updateStickerSupport();
  setDriversOk2Step();
  Serial.write(outgoing);
  stepAll();  // resets outgoing to 0  
  counter++;
  delay(HWConfig::visualizationDelay);  // min for processing is 3 on my PC
}
