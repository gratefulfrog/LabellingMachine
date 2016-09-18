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
    String ss = binary(syncBits);
    int ll = ss.length();
    print("Sync:\t");
    println(ss.substring(ll-2,ll));
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

class Sticker extends SimuSticker{
  int nbSteps, id;
  int support;  // 0 is tag, 1 is label, 3 is base
  boolean transitioning = false;
  SyncLock sy;
  
  Sticker(int supp, float ww,float hh, color cc, float ss2PP, int iDD, SyncLock syn, Config c){
    super(ww,hh,cc,c);
    id = iDD;
    support = supp;
    nbSteps = 0;
    sy = syn;
  }
  
  void step(){
    nbSteps++;
    if (!transitioning){
      doDraw(nbSteps,support);
    }
    else {
      doDrawTransition(nbSteps,support);
    }
  }
}


class Tag extends Sticker{
 float startX,
       startY;
 Config conf;
      
  Tag(Config c, int sup, SyncLock syn){
    super(sup, c.Tpixels, c.THpixels, c.tagMarkerColor,c.steps2Pixels,1,syn,c);
    conf = c;
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

class Label extends Sticker{
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