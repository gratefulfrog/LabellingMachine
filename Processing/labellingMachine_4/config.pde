class Config{
  
  /******** Simulation Variables part 1 **************/
  // main window dimensions:
  final int windowWidth  = 1800,
            windowHeight = 300;
  
 
  int speed = 100;

  // conversion factors
  final float mm2Pixels = windowWidth/900.0;  // 2.0 so 10mm = 20 pixels
            
  /******** END Simulation Variables part 1**************/
  
  /***** physical constants *****/
  
  /**************   USER CONFIGRABLE VALUES *******************/

  // conversion factors
  final int mm2Steps  = 2;
  
  // Physical dimensions in mm
  final int T   = 25,  // tag length
            IT  = 35,  // inter tag distance on feeder roll
            ITe = 17,  // maximum intertag distance variation; max is 17!
            L   = 100, // label length
            ILL = 5,   // inter label distance on feed reel
            ILLe = 2,  // inter label distance error; MAX is 2 !!
            DPT = 5,   // distance from tag detection point to tag ramp end, must be less than IT
            DPL = 3,   // distance from label detection point to label ramp end, must be less than ILL
            DS  = 300, // horizontal distance between the ramp ends
            RH  = 2,   // ramp height above backer
            IL  = 5;   // inter label distance of output label+tag combinations
            
  final float RAdegrees = 21,  // ramp angle is a user configurable value
              RA = PI*(180-RAdegrees)/180.0, // not a user variable
              sinRA = sin(RA),               // not a user variable 
              cosRA = cos(RA),               // not a user variable
              tanRA = tan(RA),               // not a user variable
              DA    = RH/sinRA,              // not a user variable
              RX    = RH/tanRA;              // not a user variable

   /**************   END OF USER CONFIGRABLE VALUES *******************/          

  // derived values not user variables!
  final int BIT    = IL +L,
            TLS    = round((L-T)/2.0),
            BTL    = (DS-TLS),
            T0     = 0,
            T1     = DPT,
            TB0    = round(DPT + DA),
            TB     = TB0 + T,
            T2     = TB0 + BIT,
            TN     = TB0 + BTL,
            TClear = TN + BIT,
            L0     = 0,
            L1     = DPL,
            LB0    = round(DPL + DA),
            LB     = LB0 + L,
            LClear = LB0 + BIT;

  // dimensions in steps
  final int Tsteps   = (T    * mm2Steps),
            ITsteps  = (IT   * mm2Steps), 
            ITesteps = (ITe  * mm2Steps),
            Lsteps   = (L    * mm2Steps),
            ILLsteps = (ILL  * mm2Steps),
            ILLesteps =(ILLe * mm2Steps),
            DPTsteps = (DPT  * mm2Steps),
            DPLsteps = (DPL  * mm2Steps),
            DSsteps  = (DS   * mm2Steps),
            DAsteps  = round(DA   * mm2Steps),
            RHsteps  = (RH   * mm2Steps),
            RXsteps  = round(RX   * mm2Steps),
            ILsteps  = (IL   * mm2Steps);
            
            
  // derived values
  final int BITsteps    = (BIT    * mm2Steps),
            TLSsteps    = (TLS    * mm2Steps),
            BTLsteps    = (BTL    * mm2Steps),
            T0steps     = (T0     * mm2Steps),
            T1steps     = (T1     * mm2Steps),
            TB0steps    = (TB0    * mm2Steps),
            TBsteps     = (TB     * mm2Steps),
            T2steps     = (T2     * mm2Steps),
            TNsteps     = (TN     * mm2Steps),
            TClearsteps = (TClear * mm2Steps),
            L0steps     = (L0     * mm2Steps),
            L1steps     = (L1     * mm2Steps),
            LB0steps    = (LB0    * mm2Steps),
            LBsteps     = (LB     * mm2Steps),
            LClearsteps = (LClear * mm2Steps) ;

  /******** Simulation Variables part 2 **************/
  //  conversion factors
  final float steps2Pixels =  mm2Pixels/mm2Steps;  

  // Platform Dimensions in pixels
  final int baseLength          = round(810 * mm2Pixels),
            baseHeight          = 50,
            rampHeight          = round(RH * mm2Pixels),
            rampBaseLength      = round(106 * mm2Pixels),
            rampSlopeLength     = round(210 * mm2Pixels),
            tagBaseLeftOffset   = round(50 * mm2Pixels),
            labelBaseLeftOffset = round(350 * mm2Pixels),
            baseX               = round((windowWidth - baseLength)/2.0),
            baseY               = windowHeight - baseHeight;

  final float rampSlopeAngle = RA, 
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
  final float Tpixels   = (T    * mm2Pixels),
            ITpixels  = (IT   * mm2Pixels), 
            ITepixels = (ITe  * mm2Pixels),
            Lpixels   = (L    * mm2Pixels),
            ILLpixels = (ILL  * mm2Pixels),
            ILLepixels =(ILLe  * mm2Pixels),
            DPTpixels = (DPT  * mm2Pixels),
            DPLpixels = (DPL  * mm2Pixels),
            DSpixels  = (DS   * mm2Pixels),
            RHpixels  = (RH   * mm2Pixels),
            RXpixels  = (RX   * mm2Pixels),
            ILpixels  = (IL   * mm2Pixels);
            
  final float DApixels = DA * mm2Pixels;
  
  // derived values
  final float BITpixels    = (BIT    * mm2Pixels),
            TLSpixels    = (TLS    * mm2Pixels),
            BTLpixels    = (BTL    * mm2Pixels),
            T0pixels     = (T0     * mm2Pixels),
            T1pixels     = (T1     * mm2Pixels),
            TB0pixels    = (TB0    * mm2Pixels),
            TBpixels     = (TB     * mm2Pixels),
            T2pixels     = (T2     * mm2Pixels),
            TNpixels     = (TN     * mm2Pixels),
            TClearpixels = (TClear * mm2Pixels),
            L0pixels     = (L0     * mm2Pixels),
            L1pixels     = (L1     * mm2Pixels),
            LB0pixels    = (LB0    * mm2Pixels),
            LBpixels     = (LB     * mm2Pixels),
            LClearpixels = (LClear * mm2Pixels) ;
  
  
  // markers:  
  final color tagMarkerColor = #FFFF00,
              labelMarkerColor = #FF0000;
  
  final int markerLength =  10,
            markerTextSize = 20;
            
  /******** END Simulation Variables part 1**************/


  Config(){
  
  };
  
  void setSpeed(boolean faster){
    speed = round(faster ? speed*1.5 : speed * 0.5);
    frameRate(speed);
  }
}