Config config  = null;
BlockingMgr bM = null;
SimuMgr sM     = null;
App app        = null;
CommsMgr cm    = null;

boolean isSimulation =  true; //false;

boolean testing = false;//true;

String portName = "/dev/ttyACM0";

void setup(){
  if (this.args != null){
    if (this.args.length>1){
        isSimulation = true;
    }
    else{
    portName = args[0];
    print("Communication on port: " + portName);
    }
  }
  size(1800,300); // config.windowWidth, config.windowHeight MUST be the same numbers !!!!
  background(0);

  config = new Config();
  initApp();
  if (isSimulation){
    frameRate(config.speed);
  }
  else{ // full speed!
    frameRate(1000);// config.speed);  // nb frames or steps per second
  }
}

void initApp(){
  if (isSimulation){
    bM     = new BlockingMgr(config);
  }
  else{  // not sim so create the comms manager
    cm = new CommsMgr(portName);
  }
  sM     = new SimuMgr(bM,config);
  app    = new App(config, bM, sM, cm);
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
  
  // check the serial port
  if (!isSimulation){
    cm.readIncoming();
  }
}


void keyPressed(){
  sM.keyPressed();
}