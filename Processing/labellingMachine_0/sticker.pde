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
  void doDraw (int nbSteps){
    stroke(col);
    fill(col);
    float x = nbSteps *s2P;
    rect(x,0,w,-h);
  }
}

class Sticker extends SimuSticker{
  int nbSteps;
  int support;  // 0 is tag, 1 is label, 3 is base
  
  Sticker(int support, int ww,int hh, color cc, float ss2PP){
    super(ww,hh,cc,ss2PP);
    support = support;
    nbSteps = 0;
  }
  
  void step(){
    nbSteps++;
    doDraw(nbSteps);
  }
}


class Tag extends Sticker{
  int startX,
      startY;
      
  Tag(Config conf){
    super(3, conf.Tpixels, conf.THpixels, conf.tagMarkerColor,conf.steps2Pixels);
    startX = conf.baseX + conf.tagBaseLeftOffset + conf.rampBaseLength;
    startY = conf.baseY;
  }
  void doStep(){
    pushMatrix();
    translate(startX,startY);
    step();
    popMatrix();
  }
}


class Label extends Sticker{
  int startX,
      startY;
      
  Label(Config conf){
    super(3, conf.Lpixels, conf.LHpixels, conf.labelMarkerColor,conf.steps2Pixels);
    startX = conf.baseX + conf.labelBaseLeftOffset + conf.rampBaseLength;
    startY = conf.baseY;
  }
  void doStep(){
    pushMatrix();
    translate(startX,startY);
    step();
    popMatrix();
  }
}