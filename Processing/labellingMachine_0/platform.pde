class Platform {
  Config conf;
  Platform(Config c){
    conf = c;
  }
  
  void drawRamp(){
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
  void drawRampMarkers(boolean isLabeller){
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
          offset = markerLength * sin(3.14159*45/180);
    // T1
    float x1 = conf.rampBaseLength,
          y1 = 0,
          x2 = x1 + offset,
          y2 = y1 - offset;
    line (x1,
          y1,
          x2,
          y2);
    text(s1,x2, y2);
    
    // T0
          x1 = x1 - cos(45*3.14159/180.0)*(DPpixels + Spixels);
          y1 = -sin(45*3.14159/180.0)*(DPpixels + Spixels);
          x2 = x1 + offset;
          y2 = y1 - offset;
    line (x1,
          y1,
          x2,
          y2);
    text(s0,x2, y2);
  }
      
  void drawBase(){
    stroke(conf.platformColor);
    line(0,0,conf.baseLength,0);
  }
  void drawBaseMarkers(){
    textAlign(CENTER,TOP);
    textSize(conf.markerTextSize);
    stroke(conf.tagMarkerColor);
    fill(conf.tagMarkerColor);
    // TB
    int TBx =conf.rampBaseLength + conf.tagBaseLeftOffset + conf.TBpixels-conf.DPTpixels;
    line (TBx,
          0,
          TBx,
          conf.markerLength);
    text("TB",TBx, conf.markerLength);
    
    // T2
    int T2x =conf.rampBaseLength + conf.tagBaseLeftOffset + conf.T2pixels-conf.DPTpixels;
    line (T2x,
          0,
          T2x,
          conf.markerLength);
    text("T2",T2x, conf.markerLength);
    
    // TN
    int TNx =conf.rampBaseLength + conf.tagBaseLeftOffset + conf.TNpixels-conf.DPTpixels;
    line (TNx,
          0,
          TNx,
          conf.markerLength);
    text("TN",TNx, conf.markerLength);
    
    // TClear
    int TClearx =conf.rampBaseLength + conf.tagBaseLeftOffset + conf.TClearpixels-conf.DPTpixels;
    line (TClearx,
          0,
          TClearx,
          conf.markerLength);
    text("TClear",TClearx, conf.markerLength);
    
    fill(conf.labelMarkerColor);
    stroke(conf.labelMarkerColor);
    // LB
    textAlign(RIGHT,TOP);
    int LBx =conf.rampBaseLength + conf.labelBaseLeftOffset + conf.LBpixels-conf.DPLpixels;
    line (LBx,
          0,
          LBx,
          conf.markerLength);
    text("LB",LBx, conf.markerLength);
    
    // LClear
    textAlign(LEFT,TOP);
    int LClearx =conf.rampBaseLength + conf.labelBaseLeftOffset + conf.LClearpixels-conf.DPLpixels;
    line (LClearx,
          0,
          LClearx,
          conf.markerLength);
    text("LClear",LClearx, conf.markerLength);
  }
  
  
  void draw(){
    pushMatrix();
    translate(conf.baseX,conf.baseY);
    drawBase();
    drawBaseMarkers();
    translate(conf.tagBaseLeftOffset,-conf.rampHeight);
    drawRamp();
    drawRampMarkers(false);
    translate(conf.labelBaseLeftOffset - conf.tagBaseLeftOffset,0);
    drawRamp();
    drawRampMarkers(true);
    popMatrix();
  }
}