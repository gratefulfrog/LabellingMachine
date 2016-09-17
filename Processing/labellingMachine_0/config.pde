class Config{
  
  /******** Simulation Variables part 1 **************/
  // main window dimensions:
  final int windowWidth  = 1800,
            windowHeight = 300;
  
  final int frameRate = 200;
  
  final float mm2Pixels = windowWidth/900.0;
  
  // Platform Dimensions in pixels
  final int baseLength  = round(810 * mm2Pixels),
            baseHeight  = 50,
            rampHeight  = round(9.5 * mm2Pixels),
            rampBaseLength  = round(106 * mm2Pixels),
            rampSlopeLength  = round(150 * mm2Pixels),
            tagBaseLeftOffset = round(50 * mm2Pixels),
            labelBaseLeftOffset = round(350 * mm2Pixels),
            baseX               = round((windowWidth - baseLength)/2.0),
            baseY               = windowHeight - baseHeight;

  final float rampSlopeAngle   = 135 * 3.14159/180.0;
  
  final color platformColor = #FFFFFF;
            
  /******** END Simulation Variables part 1**************/
  

  // physical constants
  final float mm2Steps  = 2.0;

    final int T   = 25,
              L   = 100,
              DPT = 5,
              DPL = 8,
              DS  = 300,
              IL  = 5;
            
  // derived values
  final int BIT    = IL +L,
            TLS    = round((L-T)/2.0),
            BTL    = (DS-TLS),
            T0     = 0,
            T1     = DPT,
            TB     = DPT + T,
            T2     = DPT + BIT,
            TN     = BTL + DPT,
            TClear = TN + BIT,
            L0     = 0,
            L1     = DPL,
            LB     = DPL + L,
            LClear = DPL + BIT;

  
                        
  /******** Simulation Variables part 2 **************/

  final float steps2Pixels =  mm2Pixels/mm2Steps;  
  // Sticker heights
  // mm
  final int TH = 2,
            THpixels = round(TH * mm2Pixels),
            LH = 4,
            LHpixels = round(LH * mm2Pixels);
      
  // positions in pixels
  final int  Tpixels   = round(T   * mm2Pixels),
             Lpixels   = round(L   * mm2Pixels),
             DPTpixels = round(DPT * mm2Pixels),
             DPLpixels = round(DPL * mm2Pixels),
             DSpixels  = round(DS  * mm2Pixels),
             ILpixels  = round(IL  * mm2Pixels);
            
  // derived values
  final int BITpixels    = ILpixels +Lpixels,
            TLSpixels    = round((Lpixels-Tpixels)/2.0),
            BTLpixels    = (DSpixels-TLSpixels),
            T0pixels     = 0,
            T1pixels     = DPTpixels,
            TBpixels     = DPTpixels + Tpixels,
            T2pixels     = DPTpixels + BITpixels,
            TNpixels     = BTLpixels + DPTpixels,
            TClearpixels = TNpixels + BITpixels,
            L0pixels     = 0,
            L1pixels     = DPLpixels,
            LBpixels     = DPLpixels + Lpixels,
            LClearpixels = DPLpixels + BITpixels;
            
  // markers:  
  final color tagMarkerColor = #FFFF00,
              labelMarkerColor = #FF0000;
  
  final int markerLength =  10,
            markerTextSize = 20;
            
  /******** END Simulation Variables part 1**************/


  Config(){};
}