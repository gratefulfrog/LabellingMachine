
final Config config = new Config();
Platform platform   = new Platform(config);

SyncLock s = new SyncLock();  

Boolean CALLOUTtags   = false,
        CALLOUTlabels = false,
        showSync      = false,
        showBlocking  = false,
        stopAtMessage = false;

Boolean lop =  true;

Boolean blockAtRampEnd =  true;

final int tagDelay   = config.ITsteps,
          labelDelay = config.ILLsteps;

final int nbTags           = 12,
          nbTagsOnBacker   = 8,
          tagEndStep       = nbTagsOnBacker*config.BITsteps, 
          nbLabels         = 9,
          nbLabelsOnBacker = 5,
          labelEndStep     = nbLabelsOnBacker*config.BITsteps;

int minTSteps,
    minLSteps;

Sticker tVec[];
Sticker lVec[];

Driver tagger,  
       labeller,
       backer;

boolean blocked[] = {false,false,false};

/*
void settings() {  // not available in javascript !!
   size(config.windowWidth,config.windowHeight);
}
*/
void setup(){
  size(1800,300);
  frameRate(config.speed);  // nb steps per second
  background(0);
  tVec = new Sticker[nbTags];
  for (int i = 0; i< nbTags;i++){
    tVec[i] =  new Sticker(config,1,s,true);
    tVec[i].nbSteps = -(tagDelay +config.Tsteps)*(i+1);
  }
  int lbaseSteps =  config.LB0steps-1;
  lVec = new Sticker[nbLabels];
  for (int i = 0; i< nbLabels;i++){
    lVec[i] =  new Sticker(config,2,s,false); 
    lVec[i].nbSteps = -(labelDelay+config.Lsteps) *(i+1);
  }
  minTSteps = minSteps(tVec);
  minLSteps = minSteps(lVec);
  
  tagger   = new Driver(1, s, tVec, null);
  labeller = new Driver(2, s, null, lVec);
  backer   = new Driver(3,s,tVec,lVec);
  setStopPoints();
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

The labeller cannot advance if there is a label at LB0 and (there is not tag that at TN  OR  if the backer cannot advance). wait on backer
The tagger   cannot advance if there is a tag at TB0  and (there is a tag having stepped s such that TB0 < s < T2  OR  if the backer cannot advance)! wait on backer 
The backer   cannot advance if a tag is at T2 and no TAG is at TB0 ! wait on tagger
The backer   cannot advance if a tag is at TN and no label is at LB0 ! wait on labeller
*/

int labellerStopPoint = config.LB0steps,
    taggerStopPoint   = config.TB0steps,
    backerTagWaitTagPoint = config.T2steps,    
    backerTagWaitLabelPoint = config.TNsteps;

void  setStopPoints(){
  if(!blockAtRampEnd){
    labellerStopPoint       = config.LB0steps;
    taggerStopPoint         = config.TB0steps;
    backerTagWaitTagPoint   = config.T2steps;    
    backerTagWaitLabelPoint = config.TNsteps;
  }
  else {
    labellerStopPoint       = config.LB0steps - config.DAsteps;
    taggerStopPoint         = config.TB0steps - config.DAsteps;
    backerTagWaitTagPoint   = config.T2steps  - config.DAsteps;
    backerTagWaitLabelPoint = config.TNsteps  - config.DAsteps;
  }
}

boolean tagAtTB0(){
  for (int i=0;i<tVec.length;i++){
    //if (tVec[i].nbSteps == config.TB0steps){
    if (tVec[i].nbSteps == taggerStopPoint){
      return true;
    }
  }
  return false;
}
boolean tagAtT2(){
  for (int i=0;i<tVec.length;i++){
    //if (tVec[i].nbSteps == config.T2steps){
    if (tVec[i].nbSteps == backerTagWaitTagPoint){
      return true;
    }
  }
  return false;
}
boolean tagAtTN(){
  for (int i=0;i<tVec.length;i++){
    //if (tVec[i].nbSteps == config.TNsteps){
    if (tVec[i].nbSteps == backerTagWaitLabelPoint){
      return true;
    }
  }
  return false;
}
boolean tagbetweenTB0andT2(){
  for (int i=0;i<tVec.length;i++){
    //if ((tVec[i].nbSteps > config.TB0steps) && (tVec[i].nbSteps < config.T2steps)){
    if ((tVec[i].nbSteps > config.TB0steps) && (tVec[i].nbSteps < backerTagWaitTagPoint)){
      return true;
    }
  }
  return false;
}
boolean labelAtLB0(){
  for (int i=0;i<lVec.length;i++){
    //if (lVec[i].nbSteps == config.LB0steps){
    if (lVec[i].nbSteps == labellerStopPoint){
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
  if (!showBlocking){
    return !resNot;
  }
  if (resNot && !blocked[0]){
    blocked[0] = resNot;
    println("Tagger blocked!");
    doStop();
  }
  else if (!resNot && blocked[0]){
     blocked[0] = resNot;
     println("Tagger released!");
     doStop();
  }
  return !resNot;
}

boolean labellerCanAdvance(){
  boolean resNot = (labelAtLB0() && (!backerCanAdvance() || ! tagAtTN()));
  if (!showBlocking){
    return !resNot;
  }
  if (resNot && !blocked[1]){
    blocked[1] = resNot;
    //println("\t\tLabeller blocked!");
    printSpace(20);
    println("Labeller blocked!");
    doStop();
  }
  else if (!resNot &&  blocked[1]){
    blocked[1] = resNot;
    //println("\t\tLabeller released.");
    printSpace(20);
    println("Labeller released.");
    doStop();
  }
  return !resNot;
}
boolean backerCanAdvance(){
  boolean resNot0 = (tagAtT2() && ! tagAtTB0()),
          resNot1 = (tagAtTN() && ! labelAtLB0()),
          resNot = resNot0 || resNot1;
  if (!showBlocking){
    return !resNot;
  }
  if (resNot0 && ! blocked[2]){
    blocked[2] = true;
    //println("\t\t\t\tBacker blocked on: TAGGER!");
    printSpace(40);
    println("Backer blocked on: TAGGER!");
    doStop();
  }
  if (resNot1  && ! blocked[2]){
    blocked[2] = true;
    //println("\t\t\t\tBacker blocked on: LABELLER!");
    printSpace(40);
    println("Backer blocked on: LABELLER!");
    doStop();
  }
  if (!resNot && blocked[2]){
    blocked[2] = resNot;
    //println("\t\t\t\tBacker released.");
    printSpace(40);
    println("Backer released.");
    doStop();
  }
  return !resNot;
} 

/***************************** END Blocking Rules *************************/

void draw(){
  background(0);
  minTSteps = minSteps(tVec);
  minLSteps = minSteps(lVec);
  platform.draw();
  labeller.stepOK = labellerCanAdvance();
  tagger.stepOK = taggerCanAdvance();
  backer.stepOK = backerCanAdvance();
  
  labeller.step();
  tagger.step();
  backer.step();
  
  if (CALLOUTtags){
    doTagCallouts();
  }
  if (CALLOUTlabels){
    doLabelCallouts();
  }
}

void pause(){
  if (lop){
    noLoop();
    lop  = false;
  }
  else {
    loop();
    lop = true;
  }
}

int minSteps (Sticker v[]){
  int res = 0,
       nb = v.length;
       
  for (int i=0;i<nb;i++){
    res = min(res,v[i].nbSteps);
  }
  return res;
}

Sticker updateTag(Sticker t){
  if ((t.support == 3) && (t.nbSteps > tagEndStep)) { 
    t = new Sticker(config,1,s,true); 
    t.nbSteps = minTSteps - (tagDelay+config.Tsteps);
  }
  return t;
}

Sticker updateLabel(Sticker l){
   if ((l.support == 3) && (l.nbSteps > labelEndStep)) { 
    l = new Sticker(config,2,s,false);
    l.nbSteps = minLSteps- (labelDelay+config.Lsteps);
  }
  return l;
}

void doStop(){
  if (!stopAtMessage){
    lop  = true;
    loop();
  }
  else{
    lop  = false;
    noLoop();
  }
}

void doTagCallouts(){
  for( int i=0;i<nbTags;i++){
    if (tVec[i].nbSteps == config.T0steps){
      println("AT T0!");
      doStop();
    }
    else if (tVec[i].nbSteps == config.T1steps){
      println("AT T1!");
      doStop();
    }
    else if (tVec[i].nbSteps == config.TB0steps){
      println("AT TB0!");
      doStop();
    }
    else if (tVec[i].nbSteps == config.TBsteps){
      println("AT TB!");
      doStop();
    }
   else if (tVec[i].nbSteps == config.T2steps){
      println("AT T2!");
      doStop();
    }
    else if (tVec[i].nbSteps == config.TNsteps){
      println("AT TN!");
      doStop();
    }
    else if (tVec[i].nbSteps == config.TClearsteps){
      println("AT TClear!");
      doStop();
    }
  }
}
void doLabelCallouts(){
  for( int i=0;i<nbLabels;i++){
    if (lVec[i].nbSteps == config.L0steps){
      println("AT L0!");
      doStop();
    }
    else if (lVec[i].nbSteps == config.L1steps){
      println("AT L1!");
      doStop();
    }
    else if (lVec[i].nbSteps == config.LB0steps){
      println("AT LB0!");
      doStop();
    }
    else if (lVec[i].nbSteps == config.LBsteps){
      println("AT LB!");
      doStop();
    }
    else if (lVec[i].nbSteps == config.LClearsteps){
      println("AT LClear!");
      doStop();
    }
  }
}


void keyPressed(){
  /*
        CALLOUTtags   = false,
        CALLOUTlabels = false,
        showSync      = false,
        showBlocking  = false,
        stopAtMessage = false;
        */
  if ((key == 'A') || (key == 'a')){
    config.setSpeed(true);
  }
  else if ((key == 'B') || (key == 'b')){
    showBlocking = !showBlocking;
  }
  else  if ((key == 'D') || (key == 'd')){
    config.setSpeed(false);
  }
  else  if ((key == 'L') || (key == 'l')){
    CALLOUTlabels = !CALLOUTlabels;
  }
  else  if ((key == 'P') || (key == 'p')){
    stopAtMessage = !stopAtMessage;
  }
  else  if ((key == 'R') || (key == 'r')){
    blockAtRampEnd = !blockAtRampEnd;
    setStopPoints();    
  }else  if ((key == 'S') || (key == 's')){
    showSync = !showSync;
  }
  else  if ((key == 'T') || (key == 't')){
    CALLOUTtags = !CALLOUTtags;
  }
  else{
    pause();
  }
}