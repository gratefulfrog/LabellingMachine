import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class labellingMachine_2 extends PApplet {

Config config  = null;
BlockingMgr bM = null;
SimuMgr sM     = null;
App app        = null;
CommsMgr cm    = null;

boolean isSimulation = false;

boolean testing = false;//true;

String portName = "/dev/ttyACM0";

public void setup(){
  if (args != null){
    portName = args[0];
  }
  print("Commincition on port: " + portName);
   // config.windowWidth, config.windowHeight MUST be the same numbers !!!!
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

public void initApp(){
  if (isSimulation){
    bM     = new BlockingMgr(config);
  }
  else{  // not sim so create the comms manager
    cm = new CommsMgr(portName);
  }
  sM     = new SimuMgr(bM,config);
  app    = new App(config, bM, sM, cm);
}

public void draw(){
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


public void keyPressed(){
  sM.keyPressed();
}

PApplet thisSketchThis = this;

class Message{  // just an int for now
  int val;
  Message(int v){
    val = v;
  }
}

class CommsMgr{
  ArrayList <Message> mVec;
  Serial machinePort;                       // The serial port
  boolean firstContact =false;
  
  CommsMgr(String portName){
    machinePort = new Serial(thisSketchThis, portName, 115200);
    mVec= new ArrayList <Message>();
  }
  
  public int next(){
    if (mVec.isEmpty()){
      return 0;
    }
    else {
      if (mVec.isEmpty()){
        // this did not trigger or prevent the NullPointer exception!
        println(mVec.size());
      }
      return mVec.remove(0).val;
    }
  }
  public int interpretIncomingByte(){
    int v =  next();
    //if (v==65){ // a reset must have happend!
    if (v==255){ // a reset must have happend!
      println("Arduino Reset Detected!");
      cm.firstContact = false;
      println("\nreset!");
      return 0;
    }
    else{
      return v;
    }
  }
  public void readIncoming() {
    if (machinePort.available()>0){
      // read a byte from the serial port:
      int inByte = machinePort.read();
      if (cm.firstContact == false) {
        //if (inByte == 'A') {
        if (inByte == 255) {
          machinePort.clear();          
          cm.firstContact = true; 
          machinePort.write('A');       
          println("\nCommunication Established!");
        }
      }
      else {
        cm.mVec.add(new Message(inByte));
      }
    }
  }
}
class SimuMgr{
  /****************** SIMULATION VARIABLES **********************/
  Platform platform ;
  Config config;
  BlockingMgr bM;
  
  ArrayList<Sticker> tVec;
  ArrayList<Sticker> lVec;
  
  
  
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
  
  SimuMgr(BlockingMgr b, Config c){
    bM = b;
    config = c;
    platform = new Platform(config);
    
    tagDelay   = config.ITsteps; 
    labelDelay = config.ILLsteps;
    
    tagEndStep   = nbTagsOnBacker*config.BITsteps; 
    labelEndStep = nbLabelsOnBacker*config.BITsteps;
    
    tVec = new ArrayList<Sticker>();
    lVec = new ArrayList<Sticker>();
    
    if (isSimulation){
      for (int i = 0; i< nbTags;i++){
        tVec.add(new Sticker(config,1,true));
        tVec.get(i).nbSteps = -(tagDelay +config.Tsteps)*(i+1) + ( i==0 ? 0 : -1)*round(random(-config.ITesteps,config.ITesteps));  
      }
      for (int i = 0; i< nbLabels;i++){
        lVec.add(new Sticker(config,2,false)); 
        lVec.get(i).nbSteps = -(labelDelay+config.Lsteps) *(i+1) + ( i==0 ? 0 : -1)*round(random(-config.ILLesteps,config.ILLesteps));
      }
    }
    
  }
  public void updateRecycleStepCount(){
    minTSteps = minSteps(tVec);
    minLSteps = minSteps(lVec);
  }
  public void callOut(){
    if (CALLOUTtags){
      doTagCallouts();
    }
    if (CALLOUTlabels){
      doLabelCallouts();
    }
  }
  

  /****************** END SIMULATION VARIABLES **********************/
  /****************************   SIMULATION CONTROL ***************************/
  
  public void pause(){
    if (lop){
      noLoop();
      lop  = false;
    }
    else {
      loop();
      lop = true;
    }
  }
  
  public int minSteps (ArrayList <Sticker> v){
    int res = 0,
         nb = v.size();
         
    for (int i=0;i<nb;i++){
      res = min(res,v.get(i).nbSteps);
    }
    return res;
  }
  
  public Sticker updateTag(Sticker t){  
    // only called in simulation 
    if ((t.support == 3) && (t.nbSteps > tagEndStep)) { 
      //t = new Sticker(config,1,true); 
      //t.nbSteps = minTSteps - (tagDelay+config.Tsteps) - round(random(-config.ITesteps,config.ITesteps));
      t = new Sticker(config,1,true,(minTSteps - (tagDelay+config.Tsteps) - round(random(-config.ITesteps,config.ITesteps))));
    }
    return t;
  }
  
  public Sticker updateLabel(Sticker l){
     if ((l.support == 3) && (l.nbSteps > labelEndStep)) { 
      //l = new Sticker(config,2,false);
      //l.nbSteps = minLSteps- (labelDelay+config.Lsteps) - round(random(-config.ILLesteps,config.ILLesteps)); //+round(random(-config.ILLesteps,config.ILLesteps)));
      l = new Sticker(config,2,false, (minLSteps- (labelDelay+config.Lsteps) - round(random(-config.ILLesteps,config.ILLesteps))));
     }
    return l;
  }
  
  public void doStop(){
    if (!stopAtMessage){
      lop  = true;
      loop();
    }
    else{
      lop  = false;
      noLoop();
    }
  }
  
  public void doTagCallouts(){
    for( int i=0;i<tVec.size();i++){
      if (tVec.get(i).nbSteps == config.T0steps){
        println("AT T0!");
        doStop();
      }
      else if (tVec.get(i).nbSteps == config.T1steps){
        println("AT T1!");
        doStop();
      }
      else if (tVec.get(i).nbSteps == config.TB0steps){
        println("AT TB0!");
        doStop();
      }
      else if (tVec.get(i).nbSteps == config.TBsteps){
        println("AT TB!");
        doStop();
      }
     else if (tVec.get(i).nbSteps == config.T2steps){
        println("AT T2!");
        doStop();
      }
      else if (tVec.get(i).nbSteps == config.TNsteps){
        println("AT TN!");
        doStop();
      }
      else if (tVec.get(i).nbSteps == config.TClearsteps){
        println("AT TClear!");
        doStop();
      }
    }
  }
  public void doLabelCallouts(){
    for( int i=0;i<lVec.size();i++){
      if (lVec.get(i).nbSteps == config.L0steps){
        println("AT L0!");
        doStop();
      }
      else if (lVec.get(i).nbSteps == config.L1steps){
        println("AT L1!");
        doStop();
      }
      else if (lVec.get(i).nbSteps == config.LB0steps){
        println("AT LB0!");
        doStop();
      }
      else if (lVec.get(i).nbSteps == config.LBsteps){
        println("AT LB!");
        doStop();
      }
      else if (lVec.get(i).nbSteps == config.LClearsteps){
        println("AT LClear!");
        doStop();
      }
    }
  }
  public boolean visuKeyPressed(){
    if ((key == 'L') || (key == 'l')){
      CALLOUTlabels = !CALLOUTlabels;
      return true;
    }
    else  if ((key == 'T') || (key == 't')){
      CALLOUTtags = !CALLOUTtags;
      return true;
    }
    return false;
  }
  public void simuKeyPressed(){
    /*
          CALLOUTtags   = false,
          CALLOUTlabels = false,
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
    else    if ((key == 'P') || (key == 'p')){
      stopAtMessage = !stopAtMessage;
    }
    else  if ((key == 'R') || (key == 'r')){
      blockAtRamp = !blockAtRamp;
      bM.setStopPoints(blockAtRamp);   
    }
    else{
      pause();
    }
  }
  public void keyPressed(){
    if (isSimulation){
      visuKeyPressed();
      simuKeyPressed();
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
  CommsMgr cMgr;
       
  App(Config c, BlockingMgr b, SimuMgr smm, CommsMgr cm){
    config = c;
    bM = b;
    sM = smm;
    cMgr = cm;
    tagger   = new Driver(1, config, bM, sM);
    labeller = new Driver(2, config, bM, sM);
    backer   = new Driver(3, config, bM, sM);
     if (isSimulation){
      bM.setStopPoints(sM.blockAtRamp);
     }
  }
  
  public void clearLastLTPair(){
    println("Clearing a pair");
    if (sM.lVec.size()>0){
      sM.lVec.remove(0);
    }
    if(sM.tVec.size()>0){
      sM.tVec.remove(0);
    }
  }
  
  public void endOfSpoolDetected(){
    println("End Of Spool Detected!");
  }
  
  public void jamDetected(){
    println("Jam Detected!");
  }
  
  public void updateMachineState(){
    int curr = cMgr.interpretIncomingByte();
    
    backer.stepOK   = PApplet.parseBoolean(curr & (1<<0));
    labeller.stepOK = PApplet.parseBoolean(curr & (1<<1));
    tagger.stepOK   = PApplet.parseBoolean(curr & (1<<2));
    if (PApplet.parseBoolean(curr & (1<<3))){
      clearLastLTPair();
    }
    if (PApplet.parseBoolean(curr & (1<<4))){
      //sM.lVec.add(new Sticker(config,2,false));
      sM.lVec.add(new Sticker(config,2,false,-config.Lsteps));
      print("new: LABEL!  Currently Active Labels: ");
      println(sM.lVec.size());
    }
    if (PApplet.parseBoolean(curr & (1<<5))){
       //sM.tVec.add(new Sticker(config,1,true));
       sM.tVec.add(new Sticker(config,1,true,-config.Tsteps));
       print("new: TAG!    Currently Active Tags:   ");
       println(sM.tVec.size());
    }
    if (PApplet.parseBoolean(curr & (1<<6))){
      endOfSpoolDetected();
    }
     if (PApplet.parseBoolean(curr & (1<<7))){
      jamDetected();
    }
  }
    
  public void draw(){
    if (isSimulation) {
      labeller.canAdvance();
      tagger.canAdvance();
      backer.canAdvance();
    }
    else {
      updateMachineState();
    }
    labeller.step();
    tagger.step();
    backer.step();
  }
}
class Config{
  
  /******** Simulation Variables part 1 **************/
  // main window dimensions:
  final int windowWidth  = 1800,
            windowHeight = 300;
  
 
  int speed = 100;

  // conversion factors
  final float mm2Pixels = windowWidth/900.0f;  // 2.0 so 10mm = 20 pixels
            
  /******** END Simulation Variables part 1**************/
  
  /***** physical constants *****/
  
  /**************   USER CONFIGRABLE VALUES *******************/

  // conversion factors
  final int mm2Steps  = 2;
  
  // Physical dimensions in mm
  final int T   = 25,  // tag length
            IT  = 35,  // inter tag distance on feeder roll
            ITe = 17,  // maximum intertag distance variation; max is 17!
            L   = 100, // label length
            ILL = 5,   // inter label distance on feed reel
            ILLe = 2,  // inter label distance error; MAX is 2 !!
            DPT = 5,   // distance from tag detection point to tag ramp end, must be less than IT
            DPL = 3,   // distance from label detection point to label ramp end, must be less than ILL
            DS  = 300, // horizontal distance between the ramp ends
            RH  = 2,   // ramp height above backer
            IL  = 5;   // inter label distance of output label+tag combinations
            
  final float RAdegrees = 21,  // ramp angle is a user configurable value
              RA = PI*(180-RAdegrees)/180.0f, // not a user variable
              sinRA = sin(RA),               // not a user variable 
              cosRA = cos(RA),               // not a user variable
              tanRA = tan(RA),               // not a user variable
              DA    = RH/sinRA,              // not a user variable
              RX    = RH/tanRA;              // not a user variable

   /**************   END OF USER CONFIGRABLE VALUES *******************/          

  // derived values not user variables!
  final int BIT    = IL +L,
            TLS    = round((L-T)/2.0f),
            BTL    = (DS-TLS),
            T0     = 0,
            T1     = DPT,
            TB0    = round(DPT + DA),
            TB     = TB0 + T,
            T2     = TB0 + BIT,
            TN     = TB0 + BTL,
            TClear = TN + BIT,
            L0     = 0,
            L1     = DPL,
            LB0    = round(DPL + DA),
            LB     = LB0 + L,
            LClear = LB0 + BIT;

  // dimensions in steps
  final int Tsteps   = (T    * mm2Steps),
            ITsteps  = (IT   * mm2Steps), 
            ITesteps = (ITe  * mm2Steps),
            Lsteps   = (L    * mm2Steps),
            ILLsteps = (ILL  * mm2Steps),
            ILLesteps =(ILLe * mm2Steps),
            DPTsteps = (DPT  * mm2Steps),
            DPLsteps = (DPL  * mm2Steps),
            DSsteps  = (DS   * mm2Steps),
            DAsteps  = round(DA   * mm2Steps),
            RHsteps  = (RH   * mm2Steps),
            RXsteps  = round(RX   * mm2Steps),
            ILsteps  = (IL   * mm2Steps);
            
            
  // derived values
  final int BITsteps    = (BIT    * mm2Steps),
            TLSsteps    = (TLS    * mm2Steps),
            BTLsteps    = (BTL    * mm2Steps),
            T0steps     = (T0     * mm2Steps),
            T1steps     = (T1     * mm2Steps),
            TB0steps    = (TB0    * mm2Steps),
            TBsteps     = (TB     * mm2Steps),
            T2steps     = (T2     * mm2Steps),
            TNsteps     = (TN     * mm2Steps),
            TClearsteps = (TClear * mm2Steps),
            L0steps     = (L0     * mm2Steps),
            L1steps     = (L1     * mm2Steps),
            LB0steps    = (LB0    * mm2Steps),
            LBsteps     = (LB     * mm2Steps),
            LClearsteps = (LClear * mm2Steps) ;

  /******** Simulation Variables part 2 **************/
  //  conversion factors
  final float steps2Pixels =  mm2Pixels/mm2Steps;  

  // Platform Dimensions in pixels
  final int baseLength          = round(810 * mm2Pixels),
            baseHeight          = 50,
            rampHeight          = round(RH * mm2Pixels),
            rampBaseLength      = round(106 * mm2Pixels),
            rampSlopeLength     = round(150 * mm2Pixels),
            tagBaseLeftOffset   = round(50 * mm2Pixels),
            labelBaseLeftOffset = round(350 * mm2Pixels),
            baseX               = round((windowWidth - baseLength)/2.0f),
            baseY               = windowHeight - baseHeight;

  final float rampSlopeAngle = RA, //135 * 3.14159/180.0;
              rampSlopeSin   = sin(rampSlopeAngle),
              rampSlopeCos   = cos(rampSlopeAngle),
              rampSlopeTan   = tan(rampSlopeAngle);
  
  final int platformColor = 0xffFFFFFF;

  // Sticker heights
  // mm & pixels
  final int TH = 1,
            THpixels = round(TH * mm2Pixels),
            LH = 2,
            LHpixels = round(LH * mm2Pixels);

// dimensions in pixels
  final float Tpixels   = (T    * mm2Pixels),
            ITpixels  = (IT   * mm2Pixels), 
            ITepixels = (ITe  * mm2Pixels),
            Lpixels   = (L    * mm2Pixels),
            ILLpixels = (ILL  * mm2Pixels),
            ILLepixels =(ILLe  * mm2Pixels),
            DPTpixels = (DPT  * mm2Pixels),
            DPLpixels = (DPL  * mm2Pixels),
            DSpixels  = (DS   * mm2Pixels),
            RHpixels  = (RH   * mm2Pixels),
            RXpixels  = (RX   * mm2Pixels),
            ILpixels  = (IL   * mm2Pixels);
            
  final float DApixels = DA * mm2Pixels;
  
  // derived values
  final float BITpixels    = (BIT    * mm2Pixels),
            TLSpixels    = (TLS    * mm2Pixels),
            BTLpixels    = (BTL    * mm2Pixels),
            T0pixels     = (T0     * mm2Pixels),
            T1pixels     = (T1     * mm2Pixels),
            TB0pixels    = (TB0    * mm2Pixels),
            TBpixels     = (TB     * mm2Pixels),
            T2pixels     = (T2     * mm2Pixels),
            TNpixels     = (TN     * mm2Pixels),
            TClearpixels = (TClear * mm2Pixels),
            L0pixels     = (L0     * mm2Pixels),
            L1pixels     = (L1     * mm2Pixels),
            LB0pixels    = (LB0    * mm2Pixels),
            LBpixels     = (LB     * mm2Pixels),
            LClearpixels = (LClear * mm2Pixels) ;
  
  
  // markers:  
  final int tagMarkerColor = 0xffFFFF00,
              labelMarkerColor = 0xffFF0000;
  
  final int markerLength =  10,
            markerTextSize = 20;
            
  /******** END Simulation Variables part 1**************/


  Config(){
  
  };
  
  public void setSpeed(boolean faster){
    speed = round(faster ? speed*1.5f : speed * 0.5f);
    frameRate(speed);
  }
}
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
  
  public void  setStopPoints(boolean blockAtRampEnd){
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
  
  Driver(int iDD, Config  confi, BlockingMgr b, SimuMgr smm){ //Sticker[] tags, Sticker[] labels){
    conf      = confi;
    bMgr      = b;
    sm        = smm;
    tVec      = sm.tVec;
    lVec      = sm.lVec;
    supportID = iDD;  // 1: tagger, 2: Labeller, 3 backer
  }
  
  public boolean canStep(){
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
  
  public boolean tagAtTB0(){
    for (int i=0;i<tVec.size();i++){
      if (tVec.get(i).nbSteps == bMgr.taggerStopPoint){
        return true;
      }
    }
    return false;
  }
  public boolean tagAtT2(){
    for (int i=0;i<tVec.size();i++){
      if (tVec.get(i).nbSteps == bMgr.backerTagWaitTagPoint){
        return true;
      }
    }
    return false;
  }
  public boolean tagAtTN(){
    for (int i=0;i<tVec.size();i++){
      //if (tVec[i].nbSteps == config.TNsteps){
      if (tVec.get(i).nbSteps == bMgr.backerTagWaitLabelPoint-1){
        return true;
      }
    }
    return false;
  }
  public boolean tagbetweenTB0andT2(){
    for (int i=0;i<tVec.size();i++){
      if ((tVec.get(i).nbSteps > conf.TB0steps) && (tVec.get(i).nbSteps < bMgr.backerTagWaitTagPoint)){
        return true;
      }
    }
    return false;
  }
  public boolean labebetweenLB0andLB(){
    for (int i=0;i<lVec.size();i++){
      if ((lVec.get(i).nbSteps > bMgr.labellerStopPoint) && (lVec.get(i).nbSteps < bMgr.backerLabelReleasePoint)){
        return true;
      }
    }
    return false;
  }
  public boolean labelAtLB0(){
    for (int i=0;i<lVec.size();i++){
      if (lVec.get(i).nbSteps == bMgr.labellerStopPoint){
        return true;
      }
    }
    return false;
  }
  public void printSpace(int n){
    for (int i=0;i<n;i++){
      print("-  ");
    }
  }
  
  public boolean taggerCanAdvance(){
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
  
  public boolean labellerCanAdvance(){
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
  public boolean backerCanAdvance(){
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

  public void canAdvance(){
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

  public void step(){
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
  
  
class Platform {
  Config  conf;
  Platform(Config  c){
    conf = c;
  }
  
  public void drawRamp(){
    stroke(conf.platformColor);
    // baseline
    line(0,0,
         conf.rampBaseLength,0);
    
    // slope
    line(conf.rampBaseLength,
         0,
         conf.rampBaseLength + conf.rampSlopeLength*conf.rampSlopeCos,
         -conf.rampSlopeLength*conf.rampSlopeSin);
  }
  public void drawRampMarkers(boolean isLabeller){
    textAlign(LEFT,BOTTOM);
    textSize(conf.markerTextSize);
    
    String s0 = "T0",
           s1 = "T1";
    float DPpixels = conf.DPTpixels,
          Spixels  = conf.Tpixels;
          
    if (isLabeller){
      fill(conf.labelMarkerColor);
      stroke(conf.labelMarkerColor);  
      s0 = "L0";
      s1= "L1";
      DPpixels = conf.DPLpixels;
      Spixels  = conf.Lpixels;
    }
    else{
      stroke(conf.tagMarkerColor);
      fill(conf.tagMarkerColor);
    }
    float markerLength = 2 * conf.markerLength,
          offsetX = markerLength * cos(conf.RA-PI/2.0f),
          offsetY = markerLength * sin(conf.RA-PI/2.0f); 
    // T1
    float x1 = conf.rampBaseLength,
          y1 = 0,
          x2 = x1 + offsetX,
          y2 = y1 - offsetY;
    line (x1,
          y1,
          x2,
          y2);
    text(s1,x2, y2);
    
    // T0
          x1 = x1 + conf.cosRA*(DPpixels + Spixels); 
          y1 =  -conf.sinRA*(DPpixels + Spixels); 
          x2 = x1 + offsetX;
          y2 = y1 - offsetY;
    line (x1,
          y1,
          x2,
          y2);
    text(s0,x2, y2);
  }
      
  public void drawBase(){
    stroke(conf.platformColor);
    line(0,0,conf.baseLength,0);
  }
  public void drawBaseMarkers(){
    textAlign(CENTER,TOP);
    textSize(conf.markerTextSize);
    stroke(conf.tagMarkerColor);
    fill(conf.tagMarkerColor);
    // TB0
    float TB0x = conf.rampBaseLength + conf.tagBaseLeftOffset + (-conf.RXpixels);
    line (TB0x,
          0,
          TB0x,
          conf.markerLength);
    text("TB0",TB0x, conf.markerLength);
    //println(TB0x);
    // TB
    float TBx = TB0x + conf.Tpixels; 
    line (TBx,
          0,
          TBx,
          conf.markerLength);
    text("TB",TBx, conf.markerLength);
    
    // T2
    float T2x = TB0x + conf.BITpixels;
    line (T2x,
          0,
          T2x,
          conf.markerLength);
    text("T2",T2x, conf.markerLength);
    
    // TN
    float TNx = TB0x + conf.BTLpixels;
    line (TNx,
          0,
          TNx,
          conf.markerLength);
    text("TN",TNx, conf.markerLength);
    
    // TClear
    float TClearx =TNx + conf.BITpixels;
    line (TClearx,
          0,
          TClearx,
          conf.markerLength);
    text("TClear",TClearx, conf.markerLength);
    
    fill(conf.labelMarkerColor);
    stroke(conf.labelMarkerColor);
    // LB0
    float LB0x = conf.rampBaseLength + conf.labelBaseLeftOffset - conf.RXpixels;
    line (LB0x,
          0,
          LB0x,
          conf.markerLength);
    text("LB0",LB0x, conf.markerLength);
    //println(LB0x);
    // LB
    textAlign(RIGHT,TOP);
    float LBx = LB0x + conf.Lpixels;
    line (LBx,
          0,
          LBx,
          conf.markerLength);
    text("LB",LBx, conf.markerLength);
    //println(LBx);
    // LClear
    textAlign(LEFT,TOP);
    float LClearx = LB0x + conf.BITpixels; 
    line (LClearx,
          0,
          LClearx,
          conf.markerLength);
    text("LClear",LClearx, conf.markerLength);
  }
  
  public void draw(){
    pushMatrix();
    translate(conf.baseX,conf.baseY);
    drawBase();
    drawBaseMarkers();
    popMatrix();
    pushMatrix();
    translate(conf.baseX+conf.tagBaseLeftOffset,conf.baseY-conf.rampHeight);
    drawRamp();
    drawRampMarkers(false);
    popMatrix();
    pushMatrix();
    translate(conf.baseX+conf.labelBaseLeftOffset,conf.baseY-conf.rampHeight);
    drawRamp();
    drawRampMarkers(true);
    popMatrix();
  }
}

class SimuSticker{
  int col;
  float h,w;  // in pixels
  Config  conf;
  int transitionStartSteps, backerStartSteps;
  boolean transitioning = false;  
  
  SimuSticker(float ww, float hh, int cc, Config  c){
    h=hh;
    w=ww;
    col = cc;
    conf = c;
  }
  public void doDraw (int nbSteps, int sup){
    stroke(col);
    fill(col);
    float x = nbSteps *conf.steps2Pixels;
    if (sup  !=3){
      rotate(PI-conf.RA); 
    }
    rect(x,0,w,-h);
  }

  public void doDrawTransition (int nbSteps, int sup){
    float startX = conf.baseX - conf.Tpixels + conf.tagBaseLeftOffset + conf.rampBaseLength - conf.TB0pixels - conf.rampHeight/conf.tanRA,
          startY = conf.baseY,
          horizX = backerStartSteps+conf.Tsteps;
    if(sup == 2){ // it's a label
      startX = conf.baseX  - conf.Lpixels + conf.labelBaseLeftOffset + conf.rampBaseLength  - conf.LB0pixels - conf.rampHeight/conf.tanRA; 
      startY = conf.baseY;
      horizX = backerStartSteps+conf.Lsteps;
    }
    stroke(col);
    fill(col);
    float x = nbSteps *conf.steps2Pixels;
    pushMatrix();
    rotate(PI-conf.RA);
    rect(x,0,w -(nbSteps-transitionStartSteps)*conf.steps2Pixels,-h);
    popMatrix();
    popMatrix();
    pushMatrix();
    translate(startX,startY);
    rect(horizX*conf.steps2Pixels,0,(nbSteps-transitionStartSteps)*conf.steps2Pixels,-h);
  }   
}

class Sticker_ extends SimuSticker{
  int nbSteps, id;
  int support;  // 1 is tag, 2 is label, 3 is base
  
  Sticker_(int supp, float ww,float hh, int cc,int iDD, Config  c){
    super(ww,hh,cc,c);
    id = iDD;
    support = supp;
    nbSteps = 0;
  }
   Sticker_(int supp, float ww,float hh, int cc,int iDD, Config  c, int steps){
    super(ww,hh,cc,c);
    id = iDD;
    support = supp;
    nbSteps = steps;
  }
  
  public void step(boolean doAStep){
    if (doAStep) {
      nbSteps++;
    }
    if (!transitioning){
      doDraw(nbSteps,support);
    }
    else {
      doDrawTransition(nbSteps,support);
    }
  }
}

class Sticker extends Sticker_{
 float startX,
       startY;
      
  Sticker(Config  c, int sup, boolean isTag){
    super(sup, 
          isTag ? c.Tpixels        :c.Lpixels, 
          isTag ? c.THpixels       : c.LHpixels, 
          isTag ? c.tagMarkerColor : c.labelMarkerColor,
          isTag ? 1                : 0,
          c);
  }
   Sticker(Config  c, int sup, boolean isTag, int steps){
    super(sup, 
          isTag ? c.Tpixels        :c.Lpixels, 
          isTag ? c.THpixels       : c.LHpixels, 
          isTag ? c.tagMarkerColor : c.labelMarkerColor,
          isTag ? 1                : 0,
          c,
          steps);
  }
  public void updateSXSY(){
    if (id == 1) { // it's a tag
      if (support !=3){
        startX = conf.baseX  + conf.tagBaseLeftOffset + conf.rampBaseLength + (conf.Tpixels +conf.DPTpixels)*conf.rampSlopeCos;
        startY = conf.baseY -conf.rampHeight - (conf.Tpixels +conf.DPTpixels)*conf.rampSlopeSin;
      }
      else{
        startX = conf.baseX - conf.Tpixels + conf.tagBaseLeftOffset + conf.rampBaseLength - conf.TB0pixels - conf.rampHeight/conf.tanRA; 
        startY = conf.baseY;
      }
    }
    else{  // it's a label
      if (support !=3){
        startX = conf.baseX + conf.labelBaseLeftOffset + conf.rampBaseLength + (conf.Lpixels +conf.DPLpixels)*conf.rampSlopeCos;
        startY = conf.baseY -conf.rampHeight - (conf.Lpixels +conf.DPLpixels)*conf.rampSlopeSin;
      }
      else{
        startX = conf.baseX  - conf.Lpixels + conf.labelBaseLeftOffset + conf.rampBaseLength  - conf.LB0pixels - conf.rampHeight/conf.tanRA; 
        startY = conf.baseY;
      }
    }
  }
  
      
  public void doStep(boolean doAStep){
    boolean forceStep = doAStep;
    // check to see if it's time to transfer a sticker to the backer!
    if (!transitioning && (support == 1) && (nbSteps>=conf.TB0steps)){
      support = 1;
      transitioning = true;
      transitionStartSteps = nbSteps;
      backerStartSteps = conf.TB0steps;
    }
    else if (!transitioning && (support == 2) && (nbSteps>=conf.LB0steps)){
      support = 2;
      transitioning = true;
      transitionStartSteps = nbSteps;
      backerStartSteps = conf.LB0steps;
    }
    else if ((id == 1 && transitioning && nbSteps > conf.TBsteps - conf.DAsteps) || 
             (id == 0 && transitioning && nbSteps > conf.LBsteps - conf.DAsteps)) {
        transitioning = false;
        support = 3;
     }
    updateSXSY();
    pushMatrix();
    translate(startX,startY);
    step(forceStep);
    popMatrix();
  }
}
  public void settings() {  size(1800,300); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "labellingMachine_2" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
