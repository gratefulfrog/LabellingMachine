
#include "driver.h"
#include "config.h"


static void Driver::staticInit(StickerDequeue *lq, StickerDequeue *tq){
  lDeq = lq;
  tDeq = tq;
}

Driver::Driver(int i) :supportID(i) {}

int Driver::getSupportID() const{
  return supportID;
}
boolean Driver::getStepOK() const{
  return stepOK;                                     
}
boolean Driver::taggerCanAdvance() const{
  return true;
}
boolean Driver::labellerCanAdvance() const{
  return false;
}
boolean Driver::backerCanAdvance() const{
  return true;
}

aFuncPtr Driver::fa[] = {&taggerCanAdvance,
                         &labellerCanAdvance,
                         &backerCanAdvance};

void Driver::canAdvance(){
  stepOK = (this->*fa[supportID])();
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

boolean Driver::eltAtPoint(StickerDequeue *deq, int pt) const{
  for (dNode* s = deq->getHead(); s != NULL; s = s->nxtptr){
      if(s->data->getNbSteps() == pt) { // then it's on the backer
        return true;
      }
  }
  return false;
}

boolean eltBetweenPoints(StickerDequeue *deq,int lowPoint,int highPoint){
  for (dNode* s = deq->getHead(); s != NULL; s = s->nxtptr){
      if(s->data->getNbSteps() > lowPoint && s->data->getNbSteps() < highPoint) { // then it's on the backer
        return true;
      }
  }
  return false;
}

  boolean tagAtTB0(){
    return eltAtPoint(Driver::tDeq,Config::taggerStopPoint);
  }
/*
    for (int i=0;i<tVec.size();i++){
      if (tVec.get(i).nbSteps == bMgr.taggerStopPoint){
        return true;
      }
    }
    return false;
  }
*/

  boolean tagAtT2(){
    return eltAtPoint(tDeq,Config::backerTagWaitTagPoint);
  }
/*
    for (int i=0;i<tVec.size();i++){
      if (tVec.get(i).nbSteps == bMgr.backerTagWaitTagPoint){
        return true;
      }
    }
    return false;
  }
*/
  boolean tagAtTN(){
    // is the '-1' really necessary???
    return eltAtPoint(tDeq,Config::backerTagWaitLabelPoint-1);
  }
/*
    for (int i=0;i<tVec.size();i++){
      //if (tVec[i].nbSteps == config.TNsteps){
      if (tVec.get(i).nbSteps == bMgr.backerTagWaitLabelPoint-1){
        return true;
      }
    }
    return false;
  }
*/
  boolean tagbetweenTB0andT2(){
    return eltBetweenPoints(tDeq,Config::TB0steps, Config::backerTagWaitTagPoint);
  }
/*
    for (int i=0;i<tVec.size();i++){
      if ((tVec.get(i).nbSteps > conf.TB0steps) && (tVec.get(i).nbSteps < bMgr.backerTagWaitTagPoint)){
        return true;
      }
    }
    return false;
  }
*/
  boolean labebetweenLB0andLB(){
    return eltBetweenPoints(lDeq,Config::TB0steps, Config::backerLabelReleasePoint);
  }
/*
    for (int i=0;i<lVec.size();i++){
      if ((lVec.get(i).nbSteps > bMgr.labellerStopPoint) && (lVec.get(i).nbSteps < bMgr.backerLabelReleasePoint)){
        return true;
      }
    }
    return false;
  }
*/
  boolean labelAtLB0(){
    return eltAtPoint(lDeq,Config::labellerStopPoint);
  }
/*
    for (int i=0;i<lVec.size();i++){
      if (lVec.get(i).nbSteps == bMgr.labellerStopPoint){
        return true;
      }
    }
    return false;
  }
*/
    
  boolean taggerCanAdvance(){
    boolean resNot = (tagAtTB0() && (!backerCanAdvance() || tagbetweenTB0andT2()));
    return !resNot;
    }
    
  
  boolean labellerCanAdvance(){
    //The labeller cannot advance if 
    // there is a label at LB0 and (there is not tag that at TN)  OR there is a lable l with steps s such that LB0 < s < LB OR  if the backer cannot advance). wait on backer
  
    boolean resNot = (labelAtLB0() && (!tagAtTN() || labebetweenLB0andLB() || !backerCanAdvance()));
    return !resNot;
  }
  
  boolean backerCanAdvance(){
    /*
    The backer  cannot advance if a tag is at T2 and (no TAG is at TB0)! wait on tagger
    The backer  cannot advance if a tag is at TN and (no label is at LB0)  wait on labeller
    */
    boolean resNot0 = (tagAtT2() && (!tagAtTB0())),
            resNot1 = (tagAtTN() && (!labelAtLB0())),
            resNot = resNot0 || resNot1;
    return !resNot;
  }
    
  /***************************** END Blocking Rules *************************/


   //void step();      // checks stepOk and steps the driver motor!

