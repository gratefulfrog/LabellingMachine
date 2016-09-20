Config config;
BlockingMgr bM;
SimuMgr sM;
SyncLock sy;  
App app;
Driver tagger,  
       labeller,
       backer;

void setup(){
  size(1800,300); // config.windowWidth, config.windowHeight MUST be the same numbers !!!!
  background(0);
  config = new Config();
  initApp();
  frameRate(config.speed);  // nb frames or steps per second
}

void initApp(){
  bM     = new BlockingMgr(config);
  sy     = new SyncLock();
  sM     = new SimuMgr(bM,config,sy);
  sy.postInstanciation(sM);
  app    = new App(config, bM, sM,sy);
}

void draw(){
  background(0);
  sM.platform.draw();
  
  // For sticker recycling (simulation only)
  sM.recycle();

  // do the work!
  app.draw();
  
  // For message calling (simulation only)  
  sM.callOut();
}

void keyPressed(){
  sM.simuKeyPressed();
}