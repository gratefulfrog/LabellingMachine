import java.util.concurrent.*;  // for the sync queue
import processing.serial.*;

Config config  = null;
BlockingMgr bM = null;
SimuMgr sM     = null;
App app        = null;
CommsMgr cm    = null;

LinkedBlockingQueue<Integer> q;
boolean firstContact =false;

boolean isSimulation =  false;

boolean testing = false;//true;

String portName = "/dev/ttyACM0";
Serial machinePort;

void setup(){
  if (args != null){
    if (args.length>1){
        isSimulation = true;
    }
    else{
    portName = args[0];
    }
  }
  if (isSimulation){
    println("Simulation!");
  }
  else{
    println("Communication on port: " + portName);
    machinePort = new Serial(this, portName, 115200);
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
    q = new LinkedBlockingQueue<Integer>();
    cm = new CommsMgr(q);
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
}

void keyPressed(){
  sM.keyPressed();
}

void serialEvent(Serial p) { 
  try{
    int inByte = p.read();
    if (firstContact == false) {
      if (inByte == 255) {
        p.clear();          
        firstContact = true; 
        p.write('A');       
        println("\nCommunication Established!");
        Thread.sleep(1000);
      }
    }
    else if (inByte == 255){
       firstContact = false;
       println("Communication reset!");
    }
    else {
      if (inByte !=0){
        q.put(inByte);
      }
    }
  }
  catch (InterruptedException e) {
      println("Exception: " + e);
    }
  }