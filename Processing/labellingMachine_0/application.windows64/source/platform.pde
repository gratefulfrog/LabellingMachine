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
          offsetX = markerLength * cos(conf.RA-PI/2.0),
          offsetY = markerLength * sin(conf.RA-PI/2.0); 
    // T1
    float x1 = conf.rampBaseLength,
          y1 = 0,
          x2 = x1 + offsetX,
          y2 = y1 - offsetY;
    line (x1,
          y1,
          x2,
          y2);
    text(s1,x2, y2);
    
    // T0
          x1 = x1 + conf.cosRA*(DPpixels + Spixels); 
          y1 =  -conf.sinRA*(DPpixels + Spixels); 
          x2 = x1 + offsetX;
          y2 = y1 - offsetY;
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
    // TB0
    float TB0x = conf.rampBaseLength + conf.tagBaseLeftOffset + (-conf.RXpixels);
    line (TB0x,
          0,
          TB0x,
          conf.markerLength);
    text("TB0",TB0x, conf.markerLength);
    //println(TB0x);
    // TB
    float TBx = TB0x + conf.Tpixels; 
    line (TBx,
          0,
          TBx,
          conf.markerLength);
    text("TB",TBx, conf.markerLength);
    
    // T2
    float T2x = TB0x + conf.BITpixels;
    line (T2x,
          0,
          T2x,
          conf.markerLength);
    text("T2",T2x, conf.markerLength);
    
    // TN
    float TNx = TB0x + conf.BTLpixels;
    line (TNx,
          0,
          TNx,
          conf.markerLength);
    text("TN",TNx, conf.markerLength);
    
    // TClear
    float TClearx =TNx + conf.BITpixels;
    line (TClearx,
          0,
          TClearx,
          conf.markerLength);
    text("TClear",TClearx, conf.markerLength);
    
    fill(conf.labelMarkerColor);
    stroke(conf.labelMarkerColor);
    // LB0
    float LB0x = conf.rampBaseLength + conf.labelBaseLeftOffset - conf.RXpixels;
    line (LB0x,
          0,
          LB0x,
          conf.markerLength);
    text("LB0",LB0x, conf.markerLength);
    //println(LB0x);
    // LB
    textAlign(RIGHT,TOP);
    float LBx = LB0x + conf.Lpixels;
    line (LBx,
          0,
          LBx,
          conf.markerLength);
    text("LB",LBx, conf.markerLength);
    //println(LBx);
    // LClear
    textAlign(LEFT,TOP);
    float LClearx = LB0x + conf.BITpixels; 
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
    popMatrix();
    pushMatrix();
    translate(conf.baseX+conf.tagBaseLeftOffset,conf.baseY-conf.rampHeight);
    drawRamp();
    drawRampMarkers(false);
    popMatrix();
    pushMatrix();
    translate(conf.baseX+conf.labelBaseLeftOffset,conf.baseY-conf.rampHeight);
    drawRamp();
    drawRampMarkers(true);
    popMatrix();
  }
}