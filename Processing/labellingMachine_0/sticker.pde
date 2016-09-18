class SimuSticker{
  color col;
  float h,w;  // in pixels
  float s2P;
  
  SimuSticker(float ww, float hh, color cc, float ss2PP){
    h=hh;
    w=ww;
    col = cc;
    s2P = ss2PP;
    //println(h);
    //println(w);
  }
  void doDraw (int nbSteps, int sup){
    stroke(col);
    fill(col);
    float x = nbSteps *s2P;
    if (sup  !=3){
      rotate(QUARTER_PI); // 45*3.14159/180.0);
    }
    rect(x,0,w,-h);
  }
}

class Sticker extends SimuSticker{
  int nbSteps;
  int support;  // 0 is tag, 1 is label, 3 is base
  
  Sticker(int supp, float ww,float hh, color cc, float ss2PP){
    super(ww,hh,cc,ss2PP);
    support = supp;
    nbSteps = 0;
  }
  
  void step(){
    nbSteps++;
    doDraw(nbSteps,support);
  }
}


class Tag extends Sticker{
 float startX,
       startY;
 Config conf;
      
  Tag(Config c, int sup){
    super(sup, c.Tpixels, c.THpixels, c.tagMarkerColor,c.steps2Pixels);
    conf = c;
    
  }
  void doStep(){
    if (support !=3){
      startX = conf.baseX  + conf.tagBaseLeftOffset + conf.rampBaseLength + (conf.Tpixels +conf.DPTpixels)*conf.rampSlopeCos;
      startY = conf.baseY -conf.rampHeight - (conf.Tpixels +conf.DPTpixels)*conf.rampSlopeSin;
    }
    else{
      startX = conf.baseX - conf.Tpixels + conf.tagBaseLeftOffset + conf.rampBaseLength + conf.TB0pixels *conf.cosRA;
      startY = conf.baseY;
    }
    pushMatrix();
    translate(startX,startY);
    step();
    popMatrix();
  }
}


class Label extends Sticker{
  float startX,
        startY;
 Config conf;
 
  Label(Config c,int supp){
    super(supp, c.Lpixels, c.LHpixels, c.labelMarkerColor,c.steps2Pixels);
    conf = c;

  }
  void doStep(){
    if (support !=3){
      startX = conf.baseX + conf.labelBaseLeftOffset + conf.rampBaseLength + (conf.Lpixels +conf.DPLpixels)*conf.rampSlopeCos;
      startY = conf.baseY -conf.rampHeight - (conf.Lpixels +conf.DPLpixels)*conf.rampSlopeSin;
  }
    else{
      startX = conf.baseX  + conf.labelBaseLeftOffset + conf.rampBaseLength - conf.Lpixels -conf.LB0pixels - conf.rampHeight/conf.tanRA; //conf.baseX - conf.Lpixels + conf.labelBaseLeftOffset + conf.rampBaseLength + conf.LB0pixels *conf.cosRA;; // conf.baseX - conf.Lpixels + conf.labelBaseLeftOffset + conf.rampBaseLength + conf.LB0pixels *conf.cosRA; 
      startY = conf.baseY;
    }
    pushMatrix();
    translate(startX,startY);
    step();
    popMatrix();
  }
}