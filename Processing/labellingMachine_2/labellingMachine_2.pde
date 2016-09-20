Config config  = null;
BlockingMgr bM = null;
SimuMgr sM     = null;
SyncLock sy    = null;  
App app        = null;

boolean isSimulation = false;

void setup(){
  size(1800,300); // config.windowWidth, config.windowHeight MUST be the same numbers !!!!
  background(0);
  config = new Config();
  initApp();
  frameRate(config.speed);  // nb frames or steps per second
}

void initApp(){
  if (isSimulation){
    bM     = new BlockingMgr(config);
    sy     = new SyncLock();
  }
  sM     = new SimuMgr(bM,config,sy);
   if (isSimulation){
     sy.postInstanciation(sM);
   }
   app    = new App(config, bM, sM,sy);
}

void draw(){
  background(0);
  sM.platform.draw();
  
  // For sticker recycling (simulation only)
  sM.updateRecycleStepCount();

  // do the work!
  app.draw();
  
  // For message calling (simulation only)  
  sM.callOut();
}

void keyPressed(){
  sM.keyPressed();
}