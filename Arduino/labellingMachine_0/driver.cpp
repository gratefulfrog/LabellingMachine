#include "driver.h"
#include "config.h"
#include "blockingMgr.h"
#include "hwConfig.h"

SMD42PhysicalDriver::SMD42PhysicalDriver(int p) : pin(p) {
  pinMode(pin, OUTPUT);
  digitalWrite(pin,LOW);
}

void SMD42PhysicalDriver::step(){
  digitalWrite(pin,HIGH);
  delayMicroseconds(HWConfig::highDelay);
  digitalWrite(pin,LOW);
  //delay(HWConfig::lowDelay);  // note needd sinc ethe loop has a delay already
}

Driver::Driver(int i, const StickerDequeue *td, const StickerDequeue *ld,int pin) : 
    supportID(i) , 
    tDq(td), 
    lDq(ld),
    nbSteps(0) {
  physicalDriver = new SMD42PhysicalDriver(pin);
}

int Driver::getSupportID() const{
  return supportID;
}
boolean Driver::getStepOK() const{
  return stepOK;                                     
}
long Driver::getNbSteps() const{
  return nbSteps;
}

aFuncPtr Driver::fa[] = {&Driver::taggerCanAdvance,
                         &Driver::labellerCanAdvance,
                         &Driver::backerCanAdvance};

boolean Driver::canAdvance(){
  stepOK = (this->*fa[supportID])();
  return stepOK;
}

/***************************** Blocking Rules *************************/
  /*
  Blocking rules:
  
  if we set to blockAtRampEnd, then we use 
  * T0 instead of TB0 in 1st condition tagger rule,
  * still use TB0 in second condition of tagger rule.
  * L0 instead of LB0 in labeller rule
  * TN-DAsteps instead of TN
  * T2-DAsteps instead of T2
  
  The labeller cannot advance if there is a label at LB0 and (there is not tag that at TN  OR there is a lable l such that LB0 < l < LB OR  if the backer cannot advance). wait on backer
  The tagger   cannot advance if there is a tag at TB0  and (there is a tag having stepped s such that TB0 < s < T2  OR  if the backer cannot advance)! wait on backer 
  The backer   cannot advance if a tag is at T2 and (no TAG is at TB0 ) wait on tagger
  The backer   cannot advance if a tag is at TN and (no label is at LB0)  wait on labeller
  */

boolean eltAtPoint(const StickerDequeue * const deq, int pt) {
  for (dNode* s = deq->getHead(); s != NULL; s = s->nxtptr){
      if(s->data->getNbSteps() == pt) { // then it's on the backer
        return true;
      }
  }
  return false;
}

boolean eltBetweenPoints(const StickerDequeue * const deq, int lowPoint,int highPoint){
  for (dNode* s = deq->getHead(); s != NULL; s = s->nxtptr){
      if(s->data->getNbSteps() > lowPoint && s->data->getNbSteps() < highPoint) { // then it's on the backer
        return true;
      }
  }
  return false;
}

boolean Driver::tagAtTB0() const{
  return eltAtPoint(tDq,BlockingMgr::taggerStopPoint);
}

boolean Driver::tagAtT2() const {
  return eltAtPoint(tDq,BlockingMgr::backerTagWaitTagPoint);
}

boolean Driver::tagAtTN() const{
  // is the '-1' really necessary???
  return eltAtPoint(tDq,BlockingMgr::backerTagWaitLabelPoint);
}

boolean Driver::tagbetweenTB0andT2() const{
  return eltBetweenPoints(tDq,BlockingMgr::taggerStopPoint  , BlockingMgr::backerTagWaitTagPoint);
}

boolean Driver::labebetweenLB0andLB() const{
  return eltBetweenPoints(lDq,BlockingMgr::labellerStopPoint, BlockingMgr::backerLabelReleasePoint);
}

boolean Driver::labelAtLB0() const{
  return eltAtPoint(lDq, BlockingMgr::labellerStopPoint);
}
    
boolean Driver::taggerCanAdvance() const{
  boolean resNot = (tagAtTB0() && (!backerCanAdvance() || tagbetweenTB0andT2()));
 if(HWConfig::debug){
   if (!resNot){
      digitalWrite(DBG_YELLOW,HIGH);
      delay(HWConfig::flashDelay);
      digitalWrite(DBG_YELLOW,LOW);
      delay(HWConfig::flashDelay);
    }
 }
  return !resNot;
}
    
  
boolean Driver::labellerCanAdvance() const{
  //The labeller cannot advance if 
  // (there is a label at LB0 AND there is not tag that at TN)  
  // OR 
  // (there is a lablel with steps s such that LB0 < s < LB AND  the backer cannot advance). 
  // ie. wait on backer

  boolean resNot = (labelAtLB0() && (!tagAtTN())) || (labebetweenLB0andLB() && !backerCanAdvance());
  if(HWConfig::debug){
    if (!resNot){
      digitalWrite(DBG_RED,HIGH);
      delay(HWConfig::flashDelay);
      digitalWrite(DBG_RED,LOW);
      delay(HWConfig::flashDelay);
    }
  }
  return !resNot;
}

boolean Driver::backerCanAdvance() const{
  /*
  The backer  cannot advance if a tag is at T2 and (no TAG is at TB0)! wait on tagger
  The backer  cannot advance if a tag is at TN and (no label is at LB0)  wait on labeller
  The backer  cannot advance if there are no tags active tags.
  */
  boolean resNot0 = (tagAtT2() && (!tagAtTB0())),
          resNot1 = (tagAtTN() && (!labelAtLB0())),
          resNot2 = !(tDq->getHead() == lDq->getHead() == NULL),
          resNot = resNot0 || resNot1 || resNot2;
  if(HWConfig::debug){
    if (!resNot){
      digitalWrite(DBG_GREEN,HIGH);
      delay(HWConfig::flashDelay);
      digitalWrite(DBG_GREEN,LOW);
      delay(HWConfig::flashDelay);
    }
  }
  return !resNot;
}
    
  /***************************** END Blocking Rules *************************/


void Driver::step(){      // checks stepOk and steps the driver motor!
  if (!stepOK){
    return;
  }
  const StickerDequeue * qs[] = {lDq,tDq};
  for (int i=0;i<2;i++){
    const StickerDequeue *sd = qs[i]; 
    for (dNode* s = sd->getHead(); s != NULL; s = s->nxtptr){
      if (s->data->getSupport() == supportID){
        s->data->step();
      }
    }
  }
  physicalDriver->step();
  nbSteps++;
}

