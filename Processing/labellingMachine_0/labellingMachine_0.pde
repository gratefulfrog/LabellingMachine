
final Config config = new Config();
Platform platform   = new Platform(config);

SyncLock s = new SyncLock();  

Boolean CALLOUTtags   = false,
        CALLOUTlabels = false,
        showSync      = false,
        showBlocking  = false;

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

/*
void settings() {
   size(config.windowWidth,config.windowHeight);
}
*/
void setup(){
  size(1800,300);
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
  //tagger.stepOK = false;
  /*
  String ss = binary(s.syncBits);
  int ll = ss.length();
  println(ss.substring(ll-2,ll));
  s.sync(0,false);
  ss = binary(s.syncBits);
  println(ss.substring(ll-2,ll));
  s.sync(0,true);
  ss = binary(s.syncBits);
  println(ss.substring(ll-2,ll));
  s.sync(0,false);
  ss = binary(s.syncBits);
  println(ss.substring(ll-2,ll));
  
  s.sync(1,false);
  ss = binary(s.syncBits);
  println(ss.substring(ll-2,ll));
  s.sync(1,true);
  ss = binary(s.syncBits);
  println(ss.substring(ll-2,ll));
  s.sync(1,true);
  ss = binary(s.syncBits);
  println(ss.substring(ll-2,ll));
  s.sync(0,true);
  ss = binary(s.syncBits);
  println(ss.substring(ll-2,ll));
  */
  //println(config.TB0pixels - config.T1pixels);
  //println(config.LB0pixels - config.L1pixels);
  
  /*
//  label1.nbSteps--;
  //label1.doStep();
  label2.nbSteps = config.LB0steps;
  label2.nbSteps--;
  label2.doStep();
  
  /*
  label3.nbSteps=200;
  label3.nbSteps--;
  label3.doStep();
  
  tag1.nbSteps =config.TNsteps;
  tag1.nbSteps--;
  tag1.doStep();
  /*
  tag2.nbSteps = config.TClearsteps;
  tag2.nbSteps--;
  tag2.doStep();
  
  println(config.T1steps);
  println(tag2.nbSteps);
  */
  //tag3.nbSteps=524;
  //tag3.nbSteps--;
  //tag3.doStep();
 /* stroke(#00FF00);
  fill(#00FF00);
  println(config.tanRA);
  println(config.rampSlopeSin == config.sinRA);
  float //startX = config.baseX  + config.tagBaseLeftOffset   + config.rampBaseLength - config.Lpixels - config.rampHeight/config.tanRA, //+ (config.Lpixels+config.LB0pixels) *config.cosRA,
        startX =   config.baseX  + config.labelBaseLeftOffset + config.rampBaseLength - config.Lpixels - config.rampHeight/config.tanRA,//+ -config.Lpixels + (config.L1pixels) *config.cosRA, //- config.Lpixels - config.rampHeight/config.tanRA,// - 220*cos(QUARTER_PI), // // config.baseX - config.Lpixels + config.labelBaseLeftOffset + config.rampBaseLength + config.LB0pixels *config.cosRA; 
        startY = config.baseY -15*config.rampHeight;
  pushMatrix();
  translate(startX,startY);
  rect(0,0,200,50);
  popMatrix();
  */
  
}

//Tag updateTag(Tag t){
Sticker updateTag(Sticker t){
  int nbTagsOnBacker = 7;
   if (t.support == 3 && t.nbSteps>(15*tagDelay+config.TClearsteps)){ //*(nbTagsOnBacker)){
    t = new Sticker(config,1,s,true); //Tag(config,1,s);
    t.nbSteps = -(tagDelay+config.Tsteps)*(nbTags-nbTagsOnBacker);
  }
  return t;
}
//Label updateLabel(Label l){
Sticker updateLabel(Sticker l){
  int nbLabelsOnBacker = 5;
   if (l.support == 3 && l.nbSteps>(labelDelay+config.Lsteps)*(nbLabelsOnBacker)){
    l = new Sticker(config,2,s,false); // Label(config,2,s);
    l.nbSteps = -(labelDelay+config.Lsteps)*(nbLabels-nbLabelsOnBacker);
  }
  return l;
}

Boolean good2Label = false;

void doStop(){
  noLoop();
  lop  = false;
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

/*
The following conditions may lead to Inter blocking!!!
The labeller cannot advance if there is a label at LB0 and (there is not tag that at TN  OR  if the backer cannot advance). wait on backer
The tagger   cannot advance if there is a tag at TB0  and (there is a tag having stepped s such that TB0 < s < T2  OR  if the backer cannot advance)! wait on backer 
The backer   cannot advance if a tag is at T2 and no TAG is at TB0 ! wait on tagger
The backer   cannot advance if a tag is at TN and no label is at LB0 ! wait on labeller
*/

boolean backerCanAdvance(){
  boolean resNot0 = (tagAtT2() && ! tagAtTB0()),
          resNot1 = (tagAtTN() && ! labelAtLB0()),
          resNot = resNot0 || resNot1;
  if (!showBlocking){
    return !resNot;
  }
  if (resNot0){
    println("\t\t\t\tBacker blocked on: TAGGER!");
  }
  if (resNot1){
    println("\t\t\t\t\t\tBacker blocked on: LABELLER!");
  }
  return !resNot;
}
  

boolean labelAtLB0(){
  for (int i=0;i<lVec.length;i++){
    if (lVec[i].nbSteps == config.LB0steps){
      return true;
    }
  }
  return false;
}
 
boolean labellerCanAdvance(){
  boolean resNot = (labelAtLB0() && (!backerCanAdvance() || ! tagAtTN()));
  if (!showBlocking){
    return !resNot;
  }
  if (resNot){
    println("\t\tLabeller blocked!");
  }
  return !resNot;
}

boolean tagAtTB0(){
  for (int i=0;i<tVec.length;i++){
    if (tVec[i].nbSteps == config.TB0steps){
      return true;
    }
  }
  return false;
}
boolean tagAtT2(){
  for (int i=0;i<tVec.length;i++){
    if (tVec[i].nbSteps == config.T2steps){
      return true;
    }
  }
  return false;
}
boolean tagAtTN(){
  for (int i=0;i<tVec.length;i++){
    if (tVec[i].nbSteps == config.TNsteps){
      return true;
    }
  }
  return false;
}
boolean tagbetweenTB0andT2(){
  for (int i=0;i<tVec.length;i++){
    if ((tVec[i].nbSteps > config.TB0steps) && (tVec[i].nbSteps < config.T2steps)){
      return true;
    }
  }
  return false;
}

boolean taggerCanAdvance(){
  boolean resNot = (tagAtTB0() && (!backerCanAdvance() || tagbetweenTB0andT2()));
  if (!showBlocking){
    return !resNot;
  }
  if (resNot){
    println("Tagger blocked!");
  }
  return !resNot;
}


void draw(){
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
Boolean lop =  true;

void mouseClicked(){
  if (lop){
    noLoop();
    lop  = false;
  }
  else {
    loop();
    lop = true;
  }
}

void keyPressed(){
  mouseClicked();
}