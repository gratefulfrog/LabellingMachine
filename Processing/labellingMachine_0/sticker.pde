class SimuSticker{
  color col;
  int h,w;  // in pixels
  float s2P;
  
  SimuSticker(int ww, int hh, color cc, float ss2PP){
    h=hh;
    w=ww;
    col = cc;
    s2P = ss2PP;
  }
  void doDraw (int nbSteps, int sup){
    stroke(col);
    fill(col);
    float x = nbSteps *s2P;
    if (sup  !=3){
      rotate(45*3.14159/180.0);
    }
    rect(x,0,w,-h);
  }
}

class Sticker extends SimuSticker{
  int nbSteps;
  int support;  // 0 is tag, 1 is label, 3 is base
  
  Sticker(int supp, int ww,int hh, color cc, float ss2PP){
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
    conf = c;;
    
  }
  void doStep(){
    if (support !=3){
      startX = conf.baseX  + conf.tagBaseLeftOffset + conf.rampBaseLength + (conf.Tpixels +conf.DPTpixels)*cos(conf.rampSlopeAngle);
      startY = conf.baseY -conf.rampHeight - (conf.Tpixels +conf.DPTpixels)*sin(conf.rampSlopeAngle);
    }
    else{
      startX = conf.baseX -conf.Tpixels + conf.tagBaseLeftOffset + conf.rampBaseLength  + conf.rampHeight;
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
      /*
      startX = conf.baseX -conf.Lpixels + conf.labelBaseLeftOffset + conf.rampBaseLength + conf.rampSlopeLength*cos(conf.rampSlopeAngle);
      startY = conf.baseY -conf.Lpixels -conf.rampHeight - conf.rampSlopeLength*sin(conf.rampSlopeAngle);
      */
      startX = conf.baseX + conf.labelBaseLeftOffset + conf.rampBaseLength + (conf.Lpixels +conf.DPLpixels)*cos(conf.rampSlopeAngle);
      startY = conf.baseY -conf.rampHeight - (conf.Lpixels +conf.DPLpixels)*sin(conf.rampSlopeAngle);
  }
    else{
      startX = conf.baseX  -conf.Lpixels + conf.labelBaseLeftOffset + conf.rampBaseLength + conf.rampHeight;
      startY = conf.baseY;
    }
    pushMatrix();
    translate(startX,startY);
    step();
    popMatrix();
  }
}