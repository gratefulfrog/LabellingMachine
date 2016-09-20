Config config  = null;
BlockingMgr bM = null;
SimuMgr sM     = null;
SyncLock sy    = null;  
App app        = null;
CommsMgr cm    = null;

boolean isSimulation = false;

boolean testing = false;//true;

String portName = "/dev/ttyACM0";

void setup(){
  size(1800,300); // config.windowWidth, config.windowHeight MUST be the same numbers !!!!
  background(0);
  config = new Config();
  initApp();
  frameRate(200);// config.speed);  // nb frames or steps per second
  //println(config.Tsteps + config.ITsteps);
  //exit();
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
  else{  // not sim so create the comms manager
    cm = new CommsMgr(portName);
  }
  app    = new App(config, bM, sM, sy, cm);
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