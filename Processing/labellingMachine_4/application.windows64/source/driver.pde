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
  SimuMgr sm;
  boolean stepOK = true;
  ArrayList <Sticker> tVec,  // may be null
                      lVec;  // may be null
  Config  conf;  
  BlockingMgr bMgr;
  SteppingLine belt;
  
  Driver(int iDD, Config  confi, BlockingMgr b, SimuMgr smm, SteppingLine stl){ 
    conf      = confi;
    bMgr      = b;
    sm        = smm;
    tVec      = sm.tVec;
    lVec      = sm.lVec;
    supportID = iDD;  // 1: tagger, 2: Labeller, 3 backer
    belt = stl;
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
  
  boolean eltAtPoint(ArrayList <Sticker> al, int pt){
    for (int i=0;i<al.size();i++){
      if (al.get(i).nbSteps == pt){
        return true;
      }
    }
    return false;
  }
  boolean eltBetweenPoints(ArrayList <Sticker> al, int lowPoint, int highPoint){
    for (int i=0;i<al.size();i++){
      if(al.get(i).nbSteps > lowPoint && al.get(i).nbSteps < highPoint) { // then it's ok!
        return true;
      }
    }
    return false;
  }

  boolean tagAtTB0(){
    return eltAtPoint(tVec, bMgr.taggerStopPoint);
  }
  boolean tagAtT2(){
    return eltAtPoint(tVec,bMgr.backerTagWaitTagPoint);
  }
  boolean tagAtTN(){
    return eltAtPoint(tVec,bMgr.backerTagWaitLabelPoint);
  }
  boolean tagbetweenTB0andT2(){
    return eltBetweenPoints(tVec,  conf.TB0steps/*bMgr.taggerStopPoint*/ , bMgr.backerTagWaitTagPoint);
  }
  boolean labebetweenLB0andLB(){
    return eltBetweenPoints(lVec, bMgr.labellerStopPoint , bMgr.backerLabelReleasePoint);
  }
  boolean labelAtLB0(){
    return eltAtPoint(lVec,bMgr.labellerStopPoint);
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
    // This is not the same as on the Arduino code!!! Why, what is different in simulation????
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
            //resnot2 = !(tVec.size() == 0 && lVec.size() == 0),
            resNot = resNot0 || resNot1;// || resnot2;
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
        //if (i==0 & stepOK)
         // println("stepping Label: ",i, "it has stepped: ", lVec.get(i).nbSteps );
        if (isSimulation){
          lVec.set(i,sm.updateLabel(lVec.get(i)));
        }
      }
    }
  
    for (int i = 0; i< tVec.size();i++){
      if (tVec.get(i).support == supportID){
        tVec.get(i).doStep(stepOK);
        //if (i==0 & stepOK)
          //println("stepping Tag: ",i, "it has stepped: ", tVec.get(i).nbSteps );
        if (isSimulation){
          tVec.set(i,sm.updateTag(tVec.get(i)));
        }
      }
    }
    if (stepOK){
      belt.step();
    }
  }
}
  
  