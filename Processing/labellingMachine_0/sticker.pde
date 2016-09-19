class SyncLock{
  int masks[] = {1,2};
      
  int syncBits;
  SyncLock(){
    syncBits = 0;
  }
  
  void sync(int bit,boolean onOff){
    if (onOff){
      syncBits |= masks[bit];
    }
    else{
      syncBits &= masks[bit^1];
    }
  }
  void show(){
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
  color col;
  float h,w;  // in pixels
  Config conf;
  
  SimuSticker(float ww, float hh, color cc, Config c){
    h=hh;
    w=ww;
    col = cc;
    conf = c;
    
    //println(h);
    //println(w);
  }
  void doDraw (int nbSteps, int sup){
    stroke(col);
    fill(col);
    float x = nbSteps *conf.steps2Pixels;
    if (sup  !=3){
      rotate(PI-conf.RA); // 45*3.14159/180.0);
    }
    rect(x,0,w,-h);
  }

  void doDrawTransition (int nbSteps, int sup){
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
  
  Sticker_(int supp, float ww,float hh, color cc,int iDD, SyncLock syn, Config c){
    super(ww,hh,cc,c);
    id = iDD;
    support = supp;
    nbSteps = 0;
    sy = syn;
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
      
  Sticker(Config c, int sup, SyncLock syn, boolean isTag){
    super(sup, 
          isTag ? c.Tpixels        :c.Lpixels, 
          isTag ? c.THpixels       : c.LHpixels, 
          isTag ? c.tagMarkerColor : c.labelMarkerColor,
          isTag ? 1                : 0,
          syn,
          c);
  }
  void updateSXSY(){
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
      
  void doStep(boolean doAStep){
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