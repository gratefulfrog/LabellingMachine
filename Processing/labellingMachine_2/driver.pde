class BlockingMgr{
   Config conf;
   
   int labellerStopPoint,
      taggerStopPoint,
      backerTagWaitTagPoint,   
      backerTagWaitLabelPoint,
      backerLabelReleasePoint;
 
    boolean blocked[] = {false,false,false},  // for blocking rules
          atRampEnd = true;  // for blocking point control
          
  BlockingMgr(Config c){
    conf = c;
    setStopPoints(atRampEnd);
  } 
  
  void  setStopPoints(boolean blockAtRampEnd){
    if(!blockAtRampEnd){
      labellerStopPoint       = conf.LB0steps;
      taggerStopPoint         = conf.TB0steps;
      backerTagWaitTagPoint   = conf.T2steps;    
      backerTagWaitLabelPoint = conf.TNsteps;
      backerLabelReleasePoint = conf.LBsteps;
    }
    else {
      labellerStopPoint       = conf.LB0steps - conf.DAsteps;
      taggerStopPoint         = conf.TB0steps - conf.DAsteps;
      backerTagWaitTagPoint   = conf.T2steps  - conf.DAsteps;
      backerTagWaitLabelPoint = conf.TNsteps  - conf.DAsteps;
      backerLabelReleasePoint = conf.LBsteps  - conf.DAsteps;
    }
  }
}

class Driver{
  int supportID;
  SyncLock syn;
  SimuMgr sm;
  boolean stepOK = true;
  ArrayList <Sticker> tVec,  // may be null
                      lVec;  // may be null
  Config  conf;  
  BlockingMgr bMgr;
  
  Driver(int iDD, SyncLock s, Config  confi, BlockingMgr b, SimuMgr smm){ //Sticker[] tags, Sticker[] labels){
    conf      = confi;
    syn       = s;
    bMgr      = b;
    sm        = smm;
    tVec      = sm.tVec;
    lVec      = sm.lVec;
    supportID = iDD;  // 1: tagger, 2: Labeller, 3 backer
  }
  
  boolean canStep(){
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
  
  boolean tagAtTB0(){
    for (int i=0;i<tVec.size();i++){
      if (tVec.get(i).nbSteps == bMgr.taggerStopPoint){
        return true;
      }
    }
    return false;
  }
  boolean tagAtT2(){
    for (int i=0;i<tVec.size();i++){
      if (tVec.get(i).nbSteps == bMgr.backerTagWaitTagPoint){
        return true;
      }
    }
    return false;
  }
  boolean tagAtTN(){
    for (int i=0;i<tVec.size();i++){
      //if (tVec[i].nbSteps == config.TNsteps){
      if (tVec.get(i).nbSteps == bMgr.backerTagWaitLabelPoint-1){
        return true;
      }
    }
    return false;
  }
  boolean tagbetweenTB0andT2(){
    for (int i=0;i<tVec.size();i++){
      if ((tVec.get(i).nbSteps > conf.TB0steps) && (tVec.get(i).nbSteps < bMgr.backerTagWaitTagPoint)){
        return true;
      }
    }
    return false;
  }
  boolean labebetweenLB0andLB(){
    for (int i=0;i<lVec.size();i++){
      if ((lVec.get(i).nbSteps > bMgr.labellerStopPoint) && (lVec.get(i).nbSteps < bMgr.backerLabelReleasePoint)){
        return true;
      }
    }
    return false;
  }
  boolean labelAtLB0(){
    for (int i=0;i<lVec.size();i++){
      if (lVec.get(i).nbSteps == bMgr.labellerStopPoint){
        return true;
      }
    }
    return false;
  }
  void printSpace(int n){
    for (int i=0;i<n;i++){
      print("-  ");
    }
  }
  
  boolean taggerCanAdvance(){
    boolean resNot = (tagAtTB0() && (!backerCanAdvance() || tagbetweenTB0andT2()));
    if (!sm.showBlocking){
      return !resNot;
    }
    if (resNot && !bMgr.blocked[0]){
      bMgr.blocked[0] = resNot;
      println("Tagger blocked!");
      sm.doStop();
    }
    else if (!resNot && bMgr.blocked[0]){
       bMgr.blocked[0] = resNot;
       println("Tagger released!");
       sm.doStop();
    }
    return !resNot;
  }
  
  boolean labellerCanAdvance(){
    //The labeller cannot advance if 
    // there is a label at LB0 and (there is not tag that at TN)  OR there is a lable l with steps s such that LB0 < s < LB OR  if the backer cannot advance). wait on backer
  
    boolean resNot = (labelAtLB0() && (!tagAtTN() || labebetweenLB0andLB() || !backerCanAdvance()));
    if (!sm.showBlocking){
      return !resNot;
    }
    if (resNot && !bMgr.blocked[1]){
      bMgr.blocked[1] = resNot;
      printSpace(20);
      println("Labeller blocked!");
      sm.doStop();
    }
    else if (!resNot &&  bMgr.blocked[1]){
      bMgr.blocked[1] = resNot;
      printSpace(20);
      println("Labeller released.");
      sm.doStop();
    }
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
    if (!sm.showBlocking){
      return !resNot;
    }
    if (resNot0 && ! bMgr.blocked[2]){
      bMgr.blocked[2] = true;
      //println("\t\t\t\tBacker blocked on: TAGGER!");
      printSpace(40);
      println("Backer blocked on: TAGGER!");
      sm.doStop();
    }
    if (resNot1  && ! bMgr.blocked[2]){
      bMgr.blocked[2] = true;
      //println("\t\t\t\tBacker blocked on: LABELLER!");
      printSpace(40);
      println("Backer blocked on: LABELLER!");
      sm.doStop();
    }
    if (!resNot && bMgr.blocked[2]){
      bMgr.blocked[2] = resNot;
      //println("\t\t\t\tBacker released.");
      printSpace(40);
      println("Backer released.");
      sm.doStop();
    }
    return !resNot;
  } 
  
  /***************************** END Blocking Rules *************************/

  void canAdvance(){
    if (supportID == 1){
      stepOK = taggerCanAdvance();
    }
    else if (supportID == 2){
      stepOK = labellerCanAdvance();
    }
    else if (supportID == 3){
      stepOK = backerCanAdvance();
    }
  }

  void step(){
    for (int i = 0; i< lVec.size(); i++){
      if (lVec.get(i).support == supportID){
        lVec.get(i).doStep(stepOK);
        if (isSimulation){
          lVec.set(i,sm.updateLabel(lVec.get(i)));
        }
      }
    }
  
    for (int i = 0; i< tVec.size();i++){
      if (tVec.get(i).support == supportID){
        tVec.get(i).doStep(stepOK);
        if (isSimulation){
          tVec.set(i,sm.updateTag(tVec.get(i)));
        }
      }
    }
  }
}
  
  