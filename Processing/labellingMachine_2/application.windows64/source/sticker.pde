
class SimuSticker{
  color col;
  float h,w;  // in pixels
  Config  conf;
  int transitionStartSteps, backerStartSteps;
  boolean transitioning = false;  
  
  SimuSticker(float ww, float hh, color cc, Config  c){
    h=hh;
    w=ww;
    col = cc;
    conf = c;
  }
  void doDraw (int nbSteps, int sup){
    stroke(col);
    fill(col);
    float x = nbSteps *conf.steps2Pixels;
    if (sup  !=3){
      rotate(PI-conf.RA); 
    }
    rect(x,0,w,-h);
  }

  void doDrawTransition (int nbSteps, int sup){
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
  
  Sticker_(int supp, float ww,float hh, color cc,int iDD, Config  c){
    super(ww,hh,cc,c);
    id = iDD;
    support = supp;
    nbSteps = 0;
  }
   Sticker_(int supp, float ww,float hh, color cc,int iDD, Config  c, int steps){
    super(ww,hh,cc,c);
    id = iDD;
    support = supp;
    nbSteps = steps;
  }
  
  void step(boolean doAStep){
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
  
   Sticker(Config  c, int sup, boolean isTag, int steps){
    super(sup, 
          isTag ? c.Tpixels        :c.Lpixels, 
          isTag ? c.THpixels       : c.LHpixels, 
          isTag ? c.tagMarkerColor : c.labelMarkerColor,
          isTag ? 1                : 0,
          c,
          steps);
  }
  void updateSXSY(){
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
  
      
  void doStep(boolean doAStep){
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