class SimuMgr{
  /****************** SIMULATION VARIABLES **********************/
  Platform platform ;
  Config config;
  BlockingMgr bM;
  SyncLock s;  
  
  Sticker tVec[];
  Sticker lVec[];

  Boolean CALLOUTtags   = false,
          CALLOUTlabels = false,
          showSync      = false,
          showBlocking  = false,
          stopAtMessage = false;
  
  Boolean lop         =  true,  // loop control
          blockAtRamp =  true;  // sticker block point control
  
  // to control spacing of stickers 
  int tagDelay,
      labelDelay;
  
  final int nbTags           = 12,
            nbTagsOnBacker   = 8,
            tagEndStep,
            nbLabels         = 9,
            nbLabelsOnBacker = 5,
            labelEndStep; 
  
  // to control recycling of stickers
  int minTSteps,  
      minLSteps;
  
  SimuMgr(BlockingMgr b, Config c, SyncLock sy){
    bM = b;
    config = c;
    s = sy;
    platform = new Platform(config);
    
    tagDelay   = config.ITsteps; 
    labelDelay = config.ILLsteps;
    
    tagEndStep   = nbTagsOnBacker*config.BITsteps; 
    labelEndStep = nbLabelsOnBacker*config.BITsteps;
    
    tVec = new Sticker[nbTags];
    for (int i = 0; i< nbTags;i++){
      tVec[i] =  new Sticker(config,1,s,true);
      tVec[i].nbSteps = -(tagDelay +config.Tsteps)*(i+1) + ( i==0 ? 0 : -1)*round(random(-config.ITesteps,config.ITesteps)); //+ round(random(-config.ITesteps,config.ITesteps));
    }
    
    lVec = new Sticker[nbLabels];
    for (int i = 0; i< nbLabels;i++){
      lVec[i] =  new Sticker(config,2,s,false); 
      lVec[i].nbSteps = -(labelDelay+config.Lsteps) *(i+1) + ( i==0 ? 0 : -1)*round(random(-config.ILLesteps,config.ILLesteps));
    }
  }
  void recycle(){
    minTSteps = minSteps(tVec);
    minLSteps = minSteps(lVec);
  }
  void callOut(){
    if (CALLOUTtags){
      doTagCallouts();
    }
    if (CALLOUTlabels){
      doLabelCallouts();
    }
  }
  

  /****************** END SIMULATION VARIABLES **********************/
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
  
  void simuKeyPressed(){
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
}

class App{
  Driver tagger,  
       labeller,
       backer;
  
  Config config;
  BlockingMgr bM;
  SimuMgr sM;
  SyncLock sy;  
       
  App(Config c, BlockingMgr b, SimuMgr smm, SyncLock syy){
    config = c;
    bM = b;
    sM = smm;
    sy = syy;
    tagger   = new Driver(1, sy, config, bM, sM);
    labeller = new Driver(2, sy, config,  bM, sM);
    backer   = new Driver(3, sy, config, bM, sM);
    bM.setStopPoints(sM.blockAtRamp);
  }
    
  void draw(){
    labeller.canAdvance();
    tagger.canAdvance();
    backer.canAdvance();
    
    labeller.step();
    tagger.step();
    backer.step();
  }
}