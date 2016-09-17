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
      
  Tag(Config conf, int sup){
    super(sup, conf.Tpixels, conf.THpixels, conf.tagMarkerColor,conf.steps2Pixels);
    if (sup !=3){
      startX = conf.baseX + conf.tagBaseLeftOffset + conf.rampBaseLength + conf.rampSlopeLength*cos(conf.rampSlopeAngle);
      startY = conf.baseY -conf.rampHeight - conf.rampSlopeLength*sin(conf.rampSlopeAngle);
    }
    else{
      startX = conf.baseX + conf.tagBaseLeftOffset + conf.rampBaseLength;
      startY = conf.baseY;
    }
  }
  void doStep(){
    pushMatrix();
    translate(startX,startY);
    step();
    popMatrix();
  }
}


class Label extends Sticker{
  float startX,
        startY;
      
  Label(Config conf,int sup){
    super(sup, conf.Lpixels, conf.LHpixels, conf.labelMarkerColor,conf.steps2Pixels);
    if (sup !=3){
      startX = conf.baseX + conf.labelBaseLeftOffset + conf.rampBaseLength + conf.rampSlopeLength*cos(conf.rampSlopeAngle);
      startY = conf.baseY -conf.rampHeight - conf.rampSlopeLength*sin(conf.rampSlopeAngle);
    }
    else{
      startX = conf.baseX + conf.labelBaseLeftOffset + conf.rampBaseLength;
      startY = conf.baseY;
    }
  }
  void doStep(){
    pushMatrix();
    translate(startX,startY);
    step();
    popMatrix();
  }
}