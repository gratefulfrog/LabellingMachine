
final Config config = new Config();
BlockingMgr bM = new BlockingMgr(config);

SyncLock s = new SyncLock();  
Sticker tVec[];
Sticker lVec[];

Driver tagger,  
       labeller,
       backer;

/****************** SIMULATION VARIABLES **********************/
final Platform platform   = new Platform(config);

Boolean CALLOUTtags   = false,
        CALLOUTlabels = false,
        showSync      = false,
        showBlocking  = false,
        stopAtMessage = false;

Boolean lop         =  true,  // loop control
        blockAtRamp =  true;  // sticker block point control

// to control spacing of stickers 
final int tagDelay   = config.ITsteps, 
          labelDelay = config.ILLsteps;

final int nbTags           = 12,
          nbTagsOnBacker   = 8,
          tagEndStep       = nbTagsOnBacker*config.BITsteps, 
          nbLabels         = 9,
          nbLabelsOnBacker = 5,
          labelEndStep     = nbLabelsOnBacker*config.BITsteps;

// to control recycling of stickers
int minTSteps,  
    minLSteps;

/****************** END SIMULATION VARIABLES **********************/

/*
void settings() {  // not available in javascript !!
   size(config.windowWidth,config.windowHeight);
}
*/
void setup(){
  size(1800,300);
  frameRate(config.speed);  // nb frames or steps per second
  background(0);
  
  tVec = new Sticker[nbTags];
  for (int i = 0; i< nbTags;i++){
    tVec[i] =  new Sticker(config,1,s,true);
    tVec[i].nbSteps = -(tagDelay +config.Tsteps)*(i+1) +( i==0 ? 0 : -1)*round(random(-config.ITesteps,config.ITesteps)); //+ round(random(-config.ITesteps,config.ITesteps));
  }
  
  lVec = new Sticker[nbLabels];
  for (int i = 0; i< nbLabels;i++){
    lVec[i] =  new Sticker(config,2,s,false); 
    lVec[i].nbSteps = -(labelDelay+config.Lsteps) *(i+1) + ( i==0 ? 0 : -1)*round(random(-config.ILLesteps,config.ILLesteps));
  }
  
  // For sticker recycling (simulation only)
  minTSteps = minSteps(tVec);
  minLSteps = minSteps(lVec);
  
  tagger   = new Driver(1, s, config, bM, tVec, lVec);
  labeller = new Driver(2, s, config,  bM, tVec, lVec);
  backer   = new Driver(3,s, config, bM, tVec,lVec);
  bM.setStopPoints(blockAtRamp);
}

void draw(){
  background(0);
  platform.draw();
  
  // For sticker recycling (simulation only)
  minTSteps = minSteps(tVec);
  minLSteps = minSteps(lVec);
  
  labeller.canAdvance();
  tagger.canAdvance();
  backer.canAdvance();
  
  labeller.step();
  tagger.step();
  backer.step();
  
  // For sticker recycling (simulation only)  
  if (CALLOUTtags){
    doTagCallouts();
  }
  if (CALLOUTlabels){
    doLabelCallouts();
  }
}

/****************************   SIMULATION CONTROL ***************************/

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
    t.nbSteps = minTSteps - (tagDelay+config.Tsteps) - round(random(-config.ITesteps,config.ITesteps));
  }
  return t;
}

Sticker updateLabel(Sticker l){
   if ((l.support == 3) && (l.nbSteps > labelEndStep)) { 
    l = new Sticker(config,2,s,false);
    l.nbSteps = minLSteps- (labelDelay+config.Lsteps) - round(random(-config.ILLesteps,config.ILLesteps)); //+round(random(-config.ILLesteps,config.ILLesteps)));
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
        stopAtMessage = false,
        blockAtRamp   = true,
        speed = config.frameRate;
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
    blockAtRamp = !blockAtRamp;
    bM.setStopPoints(blockAtRamp);   
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