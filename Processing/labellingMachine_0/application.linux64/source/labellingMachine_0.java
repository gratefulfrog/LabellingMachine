import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class labellingMachine_0 extends PApplet {


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
public void setup(){
  
  frameRate(config.speed);  // nb steps per second
  background(0);
  tVec = new Sticker[nbTags];
  for (int i = 0; i< nbTags;i++){
    tVec[i] =  new Sticker(config,1,s,true);
    tVec[i].nbSteps = -(tagDelay +config.Tsteps)*(i+1) +( i==0 ? 0 : -1)*round(random(-config.ITesteps,config.ITesteps)); //+ round(random(-config.ITesteps,config.ITesteps));
  }
  int lbaseSteps =  config.LB0steps-1;
  lVec = new Sticker[nbLabels];
  for (int i = 0; i< nbLabels;i++){
    lVec[i] =  new Sticker(config,2,s,false); 
    lVec[i].nbSteps = -(labelDelay+config.Lsteps) *(i+1) + ( i==0 ? 0 : -1)*round(random(-config.ILLesteps,config.ILLesteps));
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

The labeller cannot advance if there is a label at LB0 and (there is not tag that at TN  OR there is a lable l such that LB0 < l < LB OR  if the backer cannot advance). wait on backer
The tagger   cannot advance if there is a tag at TB0  and (there is a tag having stepped s such that TB0 < s < T2  OR  if the backer cannot advance)! wait on backer 
The backer   cannot advance if a tag is at T2 and (no TAG is at TB0 ) wait on tagger
The backer   cannot advance if a tag is at TN and (no label is at LB0)  wait on labeller
*/

int labellerStopPoint = config.LB0steps,
    taggerStopPoint   = config.TB0steps,
    backerTagWaitTagPoint = config.T2steps,    
    backerTagWaitLabelPoint = config.TNsteps,
    backerLabelReleasePoint = config.LBsteps;

public void  setStopPoints(){
  if(!blockAtRampEnd){
    labellerStopPoint       = config.LB0steps;
    taggerStopPoint         = config.TB0steps;
    backerTagWaitTagPoint   = config.T2steps;    
    backerTagWaitLabelPoint = config.TNsteps;
    backerLabelReleasePoint = config.LBsteps;
  }
  else {
    labellerStopPoint       = config.LB0steps - config.DAsteps;
    taggerStopPoint         = config.TB0steps - config.DAsteps;
    backerTagWaitTagPoint   = config.T2steps  - config.DAsteps;
    backerTagWaitLabelPoint = config.TNsteps  - config.DAsteps;
    backerLabelReleasePoint = config.LBsteps  - config.DAsteps;
  }
}

public boolean tagAtTB0(){
  for (int i=0;i<tVec.length;i++){
    //if (tVec[i].nbSteps == config.TB0steps){
    if (tVec[i].nbSteps == taggerStopPoint){
      return true;
    }
  }
  return false;
}
public boolean tagAtT2(){
  for (int i=0;i<tVec.length;i++){
    //if (tVec[i].nbSteps == config.T2steps){
    if (tVec[i].nbSteps == backerTagWaitTagPoint){
      return true;
    }
  }
  return false;
}
public boolean tagAtTN(){
  for (int i=0;i<tVec.length;i++){
    //if (tVec[i].nbSteps == config.TNsteps){
    if (tVec[i].nbSteps == backerTagWaitLabelPoint-1){
      return true;
    }
  }
  return false;
}
public boolean tagbetweenTB0andT2(){
  for (int i=0;i<tVec.length;i++){
    //if ((tVec[i].nbSteps > config.TB0steps) && (tVec[i].nbSteps < config.T2steps)){
    if ((tVec[i].nbSteps > config.TB0steps) && (tVec[i].nbSteps < backerTagWaitTagPoint)){
      return true;
    }
  }
  return false;
}
public boolean labebetweenLB0andLB(){
  for (int i=0;i<lVec.length;i++){
    //if ((tVec[i].nbSteps > config.TB0steps) && (tVec[i].nbSteps < config.T2steps)){
    if ((lVec[i].nbSteps > labellerStopPoint) && (lVec[i].nbSteps < backerLabelReleasePoint)){
      return true;
    }
  }
  return false;
}
public boolean labelAtLB0(){
  for (int i=0;i<lVec.length;i++){
    //if (lVec[i].nbSteps == config.LB0steps){
    if (lVec[i].nbSteps == labellerStopPoint){
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

public boolean labellerCanAdvance(){
  //The labeller cannot advance if 
  // there is a label at LB0 and (there is not tag that at TN)  OR there is a lable l with steps s such that LB0 < s < LB OR  if the backer cannot advance). wait on backer

  boolean resNot = (labelAtLB0() && (!tagAtTN() || labebetweenLB0andLB() || !backerCanAdvance()));
  if (!showBlocking){
    return !resNot;
  }
  if (resNot && !blocked[1]){
    blocked[1] = resNot;
    printSpace(20);
    println("Labeller blocked!");
    doStop();
  }
  else if (!resNot &&  blocked[1]){
    blocked[1] = resNot;
    printSpace(20);
    println("Labeller released.");
    doStop();
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

public void draw(){
  background(0);
  platform.draw();
  
  minTSteps = minSteps(tVec);
  minLSteps = minSteps(lVec);
  
  labeller.stepOK = labellerCanAdvance();
  tagger.stepOK   = taggerCanAdvance();
  backer.stepOK   = backerCanAdvance();
  
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

public int minSteps (Sticker v[]){
  int res = 0,
       nb = v.length;
       
  for (int i=0;i<nb;i++){
    res = min(res,v[i].nbSteps);
  }
  return res;
}

public Sticker updateTag(Sticker t){
  if ((t.support == 3) && (t.nbSteps > tagEndStep)) { 
    t = new Sticker(config,1,s,true); 
    t.nbSteps = minTSteps - (tagDelay+config.Tsteps) - round(random(-config.ITesteps,config.ITesteps));
  }
  return t;
}

public Sticker updateLabel(Sticker l){
   if ((l.support == 3) && (l.nbSteps > labelEndStep)) { 
    l = new Sticker(config,2,s,false);
    l.nbSteps = minLSteps- (labelDelay+config.Lsteps) - round(random(-config.ILLesteps,config.ILLesteps)); //+round(random(-config.ILLesteps,config.ILLesteps)));
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
public void doLabelCallouts(){
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


public void keyPressed(){
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
  // conversion factors
  final int mm2Steps  = 2;
  
  // dimensions in mm
  final int T   = 25,
            IT  = 35,
            ITe = 17,  // max 17 not tested!
            L   = 100,
            ILL = 5,
            ILLe = 2, // MAX is 2 !!
            DPT = 5,
            DPL = 3,
            DS  = 300,
            RH  = 2,
            IL  = 5;
  final float RAdegrees = 21,
              RA = PI*(180-RAdegrees)/180.0f, //PI- QUARTER_PI,
              sinRA = sin(RA),
              cosRA = cos(RA),
              tanRA = tan(RA),
              DA    = RH/sinRA,
              RX    = RH/tanRA;
            
  // derived values
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


  Config(){};
  
  public void setSpeed(boolean faster){
    speed = round(faster ? speed*1.5f : speed * 0.5f);
    frameRate(speed);
  }
}
class Driver{
  int supportID;
  SyncLock syn;
  boolean stepOK = true;
  Sticker tVec[],  // may be null
          lVec[];  // may be null
  
  Driver(int iDD, SyncLock s, Sticker[] tags, Sticker[] labels){
    supportID = iDD;
    syn = s;
    tVec = tags;
    lVec = labels;
  }
  
  public boolean canStep(){
    return stepOK;
  }
    
  public void step(){
    if (lVec != null){
      for (int i = 0; i< lVec.length; i++){
        if (lVec[i].support == supportID){
          lVec[i].doStep(stepOK);
          lVec[i] = updateLabel(lVec[i]);
        }
      }
    }
    if (tVec != null){
      for (int i = 0; i< tVec.length;i++){
        if (tVec[i].support == supportID){
          tVec[i].doStep(stepOK);
          tVec[i] = updateTag(tVec[i]);
        }
      }
    }
  }
}
  
  
class Platform {
  Config conf;
  Platform(Config c){
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
class SyncLock{
  int masks[] = {1,2};
      
  int syncBits;
  SyncLock(){
    syncBits = 0;
  }
  
  public void sync(int bit,boolean onOff){
    if (onOff){
      syncBits |= masks[bit];
    }
    else{
      syncBits &= masks[bit^1];
    }
  }
  public boolean isSynched(int bit){
    // return true if the bit, i.e. the ID, is sync locked
    return PApplet.parseBoolean(syncBits & masks[bit]);
  }
  
  public void show(){
    if (!showSync){
      return;
    }
    
    print("Sync:\t");
    print((syncBits >> 1 )& 1);
    print("--");
    println(syncBits & 1);
    doStop();
  }
}

class SimuSticker{
  int col;
  float h,w;  // in pixels
  Config conf;
  int transitionStartSteps, backerStartSteps;
  boolean transitioning = false;  
  
  SimuSticker(float ww, float hh, int cc, Config c){
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
  SyncLock sy;
  
  Sticker_(int supp, float ww,float hh, int cc,int iDD, SyncLock syn, Config c){
    super(ww,hh,cc,c);
    id = iDD;
    support = supp;
    nbSteps = 0;
    sy = syn;
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
      
  Sticker(Config c, int sup, SyncLock syn, boolean isTag){
    super(sup, 
          isTag ? c.Tpixels        :c.Lpixels, 
          isTag ? c.THpixels       : c.LHpixels, 
          isTag ? c.tagMarkerColor : c.labelMarkerColor,
          isTag ? 1                : 0,
          syn,
          c);
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
      if (!sy.isSynched(id)){
        sy.sync(id,true); 
        sy.show();
      }
    }
    else if (!transitioning && (support == 2) && (nbSteps>=conf.LB0steps)){
      support = 2;
      transitioning = true;
      transitionStartSteps = nbSteps;
      backerStartSteps = conf.LB0steps;
      if (!sy.isSynched(id)){
        sy.sync(id,true); 
        sy.show();
      }
    }
    else if ((id == 1 && transitioning && nbSteps > conf.TBsteps - conf.DAsteps) || 
             (id == 0 && transitioning && nbSteps > conf.LBsteps - conf.DAsteps)) {
        transitioning = false;
        support = 3;
        if (sy.isSynched(id)){
          sy.sync(id,false); 
          sy.show();
        }
     }
     /*
     else if  ((id == 1 && transitioning && nbSteps > conf.TBsteps - conf.DAsteps) || 
               (id == 0 && transitioning && nbSteps > conf.LBsteps - conf.DAsteps)) {
        // it's hanging in the air! force the step!
        forceStep = true;
      }
       */ 
    updateSXSY();
    pushMatrix();
    translate(startX,startY);
    step(forceStep);
    popMatrix();
  }
}
  public void settings() {  size(1800,300); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "labellingMachine_0" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
