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

final int tagDelay = config.ITsteps,
          labelDelay = config.ILLsteps;
/*
Tag   tag1           = new Tag(config,3,s),
      tag2           = new Tag(config,3,s),
      tag3           = new Tag(config,3,s);


Label label1         = new Label(config,3,s),
      label2         = new Label(config,3,s),
      label3         = new Label(config,3,s);
*/

//*/
final int nbTags =20;
//Tag tVec[];
Sticker tVec[];
final int nbLabels =8;
//Label lVec[];
Sticker lVec[];

Driver tagger,  
       labeller,
       backer;

boolean blocked[] = {false,false,false};

/*
void settings() {
   size(config.windowWidth,config.windowHeight);
}
*/
public void setup(){
  
  frameRate(config.frameRate);  // nb steps per second
  background(0);
  //tVec = new Tag[nbTags];
  tVec = new Sticker[nbTags];
  for (int i = 0; i< nbTags;i++){
    tVec[i] =  new Sticker(config,1,s,true);  //Tag(config,1,s);
    tVec[i].nbSteps = -(tagDelay +config.Tsteps)*(i+1);
  }
  int lbaseSteps =  config.LB0steps-1;
  lVec = new Sticker[nbLabels];//Label[nbLabels];
  for (int i = 0; i< nbLabels;i++){
    lVec[i] =  new Sticker(config,2,s,false); //Label(config,2,s);
    lVec[i].nbSteps = -(labelDelay+config.Lsteps) *(i+1);// + lbaseSteps;
  }
  tagger   = new Driver(1, s, tVec, null);
  labeller = new Driver(2, s, null, lVec);
  backer   = new Driver(3,s,tVec,lVec);
  setStopPoints();
}

//Tag updateTag(Tag t){
public Sticker updateTag(Sticker t){
  int nbTagsOnBacker = 7;
   if (t.support == 3 && t.nbSteps>(15*tagDelay+config.TClearsteps)){ //*(nbTagsOnBacker)){
    t = new Sticker(config,1,s,true); //Tag(config,1,s);
    t.nbSteps = -(tagDelay+config.Tsteps)*(nbTags-nbTagsOnBacker);
  }
  return t;
}
//Label updateLabel(Label l){
public Sticker updateLabel(Sticker l){
  int nbLabelsOnBacker = 5;
   if (l.support == 3 && l.nbSteps>(labelDelay+config.Lsteps)*(nbLabelsOnBacker)){
    l = new Sticker(config,2,s,false); // Label(config,2,s);
    l.nbSteps = -(labelDelay+config.Lsteps)*(nbLabels-nbLabelsOnBacker);
  }
  return l;
}

Boolean good2Label = false;

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

/*
Blocking rules:

if we set to blockAtRampEnd, then we use 
* T0 instead of TB0 in 1st condition tagger rule,
* still use TB0 in second condition of tagger rule.
* L0 instead of LB0 in labeller rule
* TN-DAsteps instead of TN
* T2-DAsteps instead of T2


The following conditions may lead to Inter blocking!!!
The labeller cannot advance if there is a label at LB0 and (there is not tag that at TN  OR  if the backer cannot advance). wait on backer
The tagger   cannot advance if there is a tag at TB0  and (there is a tag having stepped s such that TB0 < s < T2  OR  if the backer cannot advance)! wait on backer 
The backer   cannot advance if a tag is at T2 and no TAG is at TB0 ! wait on tagger
The backer   cannot advance if a tag is at TN and no label is at LB0 ! wait on labeller
*/

int labellerStopPoint = config.LB0steps,
    taggerStopPoint   = config.TB0steps,
    backerTagWaitTagPoint = config.T2steps,    
    backerTagWaitLabelPoint = config.TNsteps;

public void  setStopPoints(){
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
    if (tVec[i].nbSteps == backerTagWaitLabelPoint){
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
public boolean backerCanAdvance(){
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


public void draw(){
  background(0);
  platform.draw();
  labeller.stepOK = labellerCanAdvance();
  tagger.stepOK = taggerCanAdvance();
  backer.stepOK = backerCanAdvance();
  
  //good2Label = good2Label || (tVec[0].support == 3 && tVec[0].nbSteps > (config.TNsteps- labelDelay -config.Lsteps -20)); //- config.LB0steps));
  //if (good2Label){
    //labeller.step();
    /*
  for (int i = 0; i< nbLabels;i++){
    lVec[i].doStep();
    lVec[i] = updateLabel(lVec[i]);
  }
  */
  //}
  labeller.step();
  tagger.step();
  backer.step();
  /*
   for (int i = 0; i< nbTags;i++){
    tVec[i].doStep();
    tVec[i] = updateTag(tVec[i]);
  }
  */
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

public void keyPressed(){
  /*
        CALLOUTtags   = false,
        CALLOUTlabels = false,
        showSync      = false,
        showBlocking  = false,
        stopAtMessage = false;
        */
  if ((key == 'B') || (key == 'b')){
    showBlocking = !showBlocking;
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
  
  final int frameRate =50;

  // conversion factors
  final float mm2Pixels = windowWidth/900.0f;  // 2.0 so 10mm = 20 pixels
            
  /******** END Simulation Variables part 1**************/
  
  /***** physical constants *****/
  // conversion factors
  final int mm2Steps  = 2;
  
  // dimensions in mm
  final int T   = 25,
            IT  = 35,
            ITe = 0,  // no error yet!
            L   = 100,
            ILL = 5,
            ILLe = 0, // no error yet!
            DPT = 5,
            DPL = 3,
            DS  = 300,
            RH  = 2,
            IL  = 5;
  final float RA    = PI*(180-21)/180.0f, //PI- QUARTER_PI,
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
            ILLesteps =(ILL  * mm2Steps),
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
            rampHeight          = round(2 * mm2Pixels),
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
            ILLepixels =(ILL  * mm2Pixels),
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
   /* if (!canStep()){
      return;
    }*/
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
          offsetY = markerLength * sin(conf.RA-PI/2.0f); //(3.14159*45/180);
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
          x1 = x1 + conf.cosRA*(DPpixels + Spixels); //cos(45*3.14159/180.0)*(DPpixels + Spixels);
          y1 =  -conf.sinRA*(DPpixels + Spixels); //-sin(45*3.14159/180.0)*(DPpixels + Spixels);
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
    float T2x = TB0x + conf.BITpixels; //conf.rampBaseLength + conf.tagBaseLeftOffset + conf.T2pixels-conf.DPTpixels;
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
    float TClearx =TNx + conf.BITpixels;// conf.rampBaseLength + conf.tagBaseLeftOffset + conf.TClearpixels-conf.DPTpixels;
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
    float LBx = LB0x + conf.Lpixels; // conf.rampBaseLength + conf.labelBaseLeftOffset + conf.LBpixels-conf.DPLpixels;
    line (LBx,
          0,
          LBx,
          conf.markerLength);
    text("LB",LBx, conf.markerLength);
    //println(LBx);
    // LClear
    textAlign(LEFT,TOP);
    float LClearx = LB0x + conf.BITpixels; // conf.rampBaseLength + conf.labelBaseLeftOffset + conf.LClearpixels-conf.DPLpixels;
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
  public void show(){
    if (!showSync){
      return;
    }
    //String ss = String.format("%2s", Integer.toBinaryString(syncBits)).replace(' ', '0'); //binary(syncBits)
    //String ss = binary(syncBits);
    //int ll = ss.length();
    
    print("Sync:\t");
    print((syncBits >> 1 )& 1);
    print("--");
    println(syncBits & 1);
    doStop();
    //println(ss);
    //println(ss.substring(ll-2,ll));
  }
}

class SimuSticker{
  int col;
  float h,w;  // in pixels
  Config conf;
  
  SimuSticker(float ww, float hh, int cc, Config c){
    h=hh;
    w=ww;
    col = cc;
    conf = c;
    
    //println(h);
    //println(w);
  }
  public void doDraw (int nbSteps, int sup){
    stroke(col);
    fill(col);
    float x = nbSteps *conf.steps2Pixels;
    if (sup  !=3){
      rotate(PI-conf.RA); // 45*3.14159/180.0);
    }
    rect(x,0,w,-h);
  }

  public void doDrawTransition (int nbSteps, int sup){
      stroke(col);
      fill(col);
      float x = nbSteps *conf.steps2Pixels;
      if (sup  !=3){
        rotate(PI-conf.RA); // 45*3.14159/180.0);
      }
      rect(x,0,w,-h);
    }
}

class Sticker_ extends SimuSticker{
  int nbSteps, id;
  int support;  // 1 is tag, 2 is label, 3 is base
  boolean transitioning = false;
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
        startX = conf.baseX - conf.Tpixels + conf.tagBaseLeftOffset + conf.rampBaseLength + conf.RXpixels;// conf.TB0pixels *conf.cosRA;
        startY = conf.baseY;
      }
    }
    else{  // it's a label
      if (support !=3){
        startX = conf.baseX + conf.labelBaseLeftOffset + conf.rampBaseLength + (conf.Lpixels +conf.DPLpixels)*conf.rampSlopeCos;
        startY = conf.baseY -conf.rampHeight - (conf.Lpixels +conf.DPLpixels)*conf.rampSlopeSin;
      }
      else{
        startX = conf.baseX  + conf.labelBaseLeftOffset + conf.rampBaseLength - conf.Lpixels -conf.LB0pixels - conf.rampHeight/conf.tanRA; 
        startY = conf.baseY;
      }
    }
  }
      
  public void doStep(boolean doAStep){
    // check to see if it's time to flop down!
    if (support == 1 && nbSteps>conf.TB0steps){
      support = 3;
      transitioning = true;
      sy.sync(id,true); 
      sy.show();
      //println("Start of Tag transition: Tagger and Backer synched!");
    }
    else if (support == 2 && nbSteps>conf.LB0steps){
      support = 3;
      transitioning = true;
      sy.sync(id,true);
      sy.show();
     // println("Start of Label transition: Labeller and Backer synched!");
    }
    updateSXSY();
    if ((support ==3) && 
       ((id == 1 && transitioning && nbSteps > conf.TBsteps) || 
          (id == 0 && transitioning && nbSteps > conf.LBsteps))) {
          transitioning = false;
          sy.sync(id,false); 
          sy.show();
          //sy.show();
         // println("End of Tag/label transition: TaggerLabeller and Backer synch released");
          }
    
    pushMatrix();
    translate(startX,startY);
    step(doAStep);
    popMatrix();
  }
}
/*
class Tag extends Sticker_{
 float startX,
       startY;
      
  Tag(Config c, int sup, SyncLock syn){
    super(sup, c.Tpixels, c.THpixels, c.tagMarkerColor,c.steps2Pixels,1,syn,c);
  }
  void doStep(){
    // check to see if it's time to flop down!
    if (support == 1 && nbSteps>conf.TB0steps){
      support = 3;
      transitioning = true;
      sy.sync(id,true); 
      sy.show();
      //println("Start of Tag transition: Tagger and Backer synched!");
    }
    if (support !=3){
      startX = conf.baseX  + conf.tagBaseLeftOffset + conf.rampBaseLength + (conf.Tpixels +conf.DPTpixels)*conf.rampSlopeCos;
      startY = conf.baseY -conf.rampHeight - (conf.Tpixels +conf.DPTpixels)*conf.rampSlopeSin;
    }
    else{
      if (transitioning && nbSteps > conf.TBsteps){
        transitioning = false;
        sy.sync(id,false); 
        sy.show();
        //sy.show();
       // println("End of Tag transition: Tagger and Backer synch released");
      }
      startX = conf.baseX - conf.Tpixels + conf.tagBaseLeftOffset + conf.rampBaseLength + conf.RXpixels;// conf.TB0pixels *conf.cosRA;
      startY = conf.baseY;
    }
    pushMatrix();
    translate(startX,startY);
    step();
    popMatrix();
  }
}  

class Label extends Sticker_{
  float startX,
        startY;
 
  Label(Config c,int supp,SyncLock syn){
    super(supp, c.Lpixels, c.LHpixels, c.labelMarkerColor,c.steps2Pixels,0,syn,c);
  }
  void doStep(){
    // check to see if it's time to flop down!
    if (support == 2 && nbSteps>conf.LB0steps){
      support = 3;
      transitioning = true;
      sy.sync(id,true);
      sy.show();
     // println("Start of Label transition: Labeller and Backer synched!");
    }
    if (support !=3){
      startX = conf.baseX + conf.labelBaseLeftOffset + conf.rampBaseLength + (conf.Lpixels +conf.DPLpixels)*conf.rampSlopeCos;
      startY = conf.baseY -conf.rampHeight - (conf.Lpixels +conf.DPLpixels)*conf.rampSlopeSin;
  }
    else{
      if (transitioning && nbSteps > conf.LBsteps){
        //support = 3;
        transitioning = false;
        sy.sync(id,false); 
        sy.show();
        //  println("End of Label transition: Labeller and Backer synch released");
      }
      startX = conf.baseX  + conf.labelBaseLeftOffset + conf.rampBaseLength - conf.Lpixels -conf.LB0pixels - conf.rampHeight/conf.tanRA; //conf.baseX - conf.Lpixels + conf.labelBaseLeftOffset + conf.rampBaseLength + conf.LB0pixels *conf.cosRA;; // conf.baseX - conf.Lpixels + conf.labelBaseLeftOffset + conf.rampBaseLength + conf.LB0pixels *conf.cosRA; 
      startY = conf.baseY;
    }
    pushMatrix();
    translate(startX,startY);
    step();
    popMatrix();
  }
}
*/
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
