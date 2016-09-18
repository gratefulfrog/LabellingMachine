class Config{
  
  /******** Simulation Variables part 1 **************/
  // main window dimensions:
  final int windowWidth  = 1800,
            windowHeight = 300;
  
  final int frameRate = 200;

  // conversion factors
  final float mm2Pixels = windowWidth/900.0;  // 2.0 so 10mm = 20 pixels
            
  /******** END Simulation Variables part 1**************/
  
  /***** physical constants *****/
  // conversion factors
  final float mm2Steps  = 2.0;
  
  // dimensions in mm
  final int T   = 25,
            IT  = 25,
            ITe = 0,  // no error yet!
            L   = 100,
            ILL = 15,
            ILLe = 0, // no error yet!
            DPT = 5,
            DPL = 8,
            DS  = 300,
            RH  = 2,
            IL  = 5;
  final float RA    = PI- QUARTER_PI,
              sinRA = sin(RA),
              cosRA = cos(RA),
              tanRA = tan(RA),
              DA    = RH/sinRA;
            
  // derived values
  final int BIT    = IL +L,
            TLS    = round((L-T)/2.0),
            BTL    = (DS-TLS),
            T0     = 0,
            T1     = DPT,
            TB0    = round(DPT + DA),
            TB     = DPT + T,
            T2     = TB0 + BIT,
            TN     = TB0 + BTL,
            TClear = TN + BIT,
            L0     = 0,
            L1     = DPL,
            LB0    = round(DPL + DA),
            LB     = LB0 + L,
            LClear = LB0 + BIT;

  // dimensions in steps
  final int Tsteps   = round(T    * mm2Steps),
            ITsteps  = round(IT   * mm2Steps), 
            ITesteps = round(ITe  * mm2Steps),
            Lsteps   = round(L    * mm2Steps),
            ILLsteps = round(ILL  * mm2Steps),
            ILLesteps =round(ILL  * mm2Steps),
            DPTsteps = round(DPT  * mm2Steps),
            DPLsteps = round(DPL  * mm2Steps),
            DSsteps  = round(DS   * mm2Steps),
            RHsteps  = round(RH   * mm2Steps),
            ILsteps  = round(IL   * mm2Steps);
  
            
  // derived values
  final int BITsteps    = round(BIT    * mm2Steps),
            TLSsteps    = round(TLS    * mm2Steps),
            BTLsteps    = round(BTL    * mm2Steps),
            T0steps     = round(T0     * mm2Steps),
            T1steps     = round(T1     * mm2Steps),
            TB0steps    = round(TB0    * mm2Steps),
            TBsteps     = round(TB     * mm2Steps),
            T2steps     = round(T2     * mm2Steps),
            TNsteps     = round(TN     * mm2Steps),
            TClearsteps = round(TClear * mm2Steps),
            L0steps     = round(L0     * mm2Steps),
            L1steps     = round(L1     * mm2Steps),
            LB0steps    = round(LB0    * mm2Steps),
            LBsteps     = round(LB     * mm2Steps),
            LClearsteps = round(LClear * mm2Steps) ;
 
                        
  /******** Simulation Variables part 2 **************/
  //  conversion factors
  final float steps2Pixels =  mm2Pixels/mm2Steps;  

  // Platform Dimensions in pixels
  final int baseLength          = round(810 * mm2Pixels),
            baseHeight          = 50,
            rampHeight          = round(2 * mm2Pixels),
            rampBaseLength      = round(106 * mm2Pixels),
            rampSlopeLength     = round(150 * mm2Pixels),
            tagBaseLeftOffset   = round(50 * mm2Pixels),
            labelBaseLeftOffset = round(350 * mm2Pixels),
            baseX               = round((windowWidth - baseLength)/2.0),
            baseY               = windowHeight - baseHeight;

  final float rampSlopeAngle = RA, //135 * 3.14159/180.0;
              rampSlopeSin   = sin(rampSlopeAngle),
              rampSlopeCos   = cos(rampSlopeAngle),
              rampSlopeTan   = tan(rampSlopeAngle);
  
  final color platformColor = #FFFFFF;

  // Sticker heights
  // mm & pixels
  final int TH = 1,
            THpixels = round(TH * mm2Pixels),
            LH = 2,
            LHpixels = round(LH * mm2Pixels);

// dimensions in pixels
  final int Tpixels   = round(T    * mm2Pixels),
            ITpixels  = round(IT   * mm2Pixels), 
            ITepixels = round(ITe  * mm2Pixels),
            Lpixels   = round(L    * mm2Pixels),
            ILLpixels = round(ILL  * mm2Pixels),
            ILLepixels =round(ILL  * mm2Pixels),
            DPTpixels = round(DPT  * mm2Pixels),
            DPLpixels = round(DPL  * mm2Pixels),
            DSpixels  = round(DS   * mm2Pixels),
            RHpixels  = round(RH   * mm2Pixels),
            ILpixels  = round(IL   * mm2Pixels);
  
  // derived values
  final int BITpixels    = round(BIT    * mm2Pixels),
            TLSpixels    = round(TLS    * mm2Pixels),
            BTLpixels    = round(BTL    * mm2Pixels),
            T0pixels     = round(T0     * mm2Pixels),
            T1pixels     = round(T1     * mm2Pixels),
            TB0pixels    = round(TB0    * mm2Pixels),
            TBpixels     = round(TB     * mm2Pixels),
            T2pixels     = round(T2     * mm2Pixels),
            TNpixels     = round(TN     * mm2Pixels),
            TClearpixels = round(TClear * mm2Pixels),
            L0pixels     = round(L0     * mm2Pixels),
            L1pixels     = round(L1     * mm2Pixels),
            LB0pixels    = round(LB0    * mm2Pixels),
            LBpixels     = round(LB     * mm2Pixels),
            LClearpixels = round(LClear * mm2Pixels) ;
  
  
  // markers:  
  final color tagMarkerColor = #FFFF00,
              labelMarkerColor = #FF0000;
  
  final int markerLength =  10,
            markerTextSize = 20;
            
  /******** END Simulation Variables part 1**************/


  Config(){};
}