
final Config config = new Config();
Platform platform   = new Platform(config);

Boolean CALLOUT = false;

final int tagDelay = 250,
          labelDelay = 350;

Tag   tag1           = new Tag(config,3),
      tag2           = new Tag(config,3),
      tag3           = new Tag(config,3);


Label label1         = new Label(config,3),
      label2         = new Label(config,3),
      label3         = new Label(config,3);


//*/
final int nbTags =7;
Tag tVec[];
final int nbLabels =7;
Label lVec[];

/*
void settings() {
   size(config.windowWidth,config.windowHeight);
}
*/
void setup(){
  size(1800,300);
  frameRate(config.frameRate);  // nb steps per second
  background(0);
  tVec = new Tag[nbTags];
  //tVec[0] = tag1;
  //tVec[1] = tag2;
  for (int i = 0; i< nbTags;i++){
    tVec[i] =  new Tag(config,1);
    tVec[i].nbSteps =-tagDelay *(i+1);
  }
  int lbaseSteps =  config.LB0steps-1;
  lVec = new Label[nbLabels];
  for (int i = 0; i< nbLabels;i++){
    lVec[i] =  new Label(config,2);
    lVec[i].nbSteps = -labelDelay *(i+1);// + lbaseSteps;
  }
  
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

Tag updateTag(Tag t){
   if (t.support == 3 && t.nbSteps>tagDelay*(nbTags-1)){
    t = new Tag(config,1);
    t.nbSteps = -250;
  }
  else if (t.support == 1 && t.nbSteps>config.TB0steps){
    t.support = 3;// = new Tag(config,1);
    //t.nbSteps = 0;
  }
  return t;
}
Label updateLabel(Label l){
   if (l.support == 3 && l.nbSteps>labelDelay*(nbLabels-1)){
    l = new Label(config,2);
    l.nbSteps = -350;
  }
  else if (l.support == 2 && l.nbSteps>config.LB0steps){
    l.support = 3;// = new Tag(config,1);
    //l.nbSteps = 0;
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

void draw(){
  background(0);
  platform.draw();
  
  good2Label = good2Label || (tVec[0].support == 3 && tVec[0].nbSteps > (config.TNsteps- labelDelay-20)); //- config.LB0steps));
  if (good2Label){
  for (int i = 0; i< nbLabels;i++){
    lVec[i].doStep();
    lVec[i] = updateLabel(lVec[i]);
  }
  }
   for (int i = 0; i< nbTags;i++){
    tVec[i].doStep();
    tVec[i] = updateTag(tVec[i]);
  }
  if (CALLOUT){
    doTagCallouts();
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