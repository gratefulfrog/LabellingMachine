#ifndef CONFIG_H
#define CONFIG_H
#include "Arduino.h"


// this class is entirely static,
// reference the members by Config::T  etc.
class Config{
  public:
    // conversion factors
    static const int mm2Steps  = 2;
   
    // Physical dimensions in mm
    static const int  T   = 25,  // tag length
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
                      
    static const float  RAdegrees, // = 21,  // ramp angle is a user configurable value
                        RA, //        = PI*(180-RAdegrees)/180.0, // not a user variable
                        sinRA, //    = sin(RA),               // not a user variable 
                        cosRA, //    = cos(RA),               // not a user variable
                        tanRA, //    = tan(RA),               // not a user variable
                        DA,   //     = RH/sinRA,              // not a user variable
                        RX; //        = RH/tanRA;              // not a user variable
  
     /**************   END OF USER CONFIGRABLE VALUES *******************/          
  
    // derived values not user variables!
    static const int  BIT    , // = IL +L,
                      TLS    , // = round((L-T)/2.0),
                      BTL    , // = (DS-TLS),
                      T0     , // = 0,
                      T1     , // = DPT,
                      TB0, //    = round(DPT + DA),
                      TB     , // = TB0 + T,
                      T2     , // = TB0 + BIT,
                      TN     , // = TB0 + BTL,
                      TClear , // = TN + BIT,
                      L0     , // = 0,
                      L1     , // = DPL,
                      LB0, //    = round(DPL + DA),
                      LB     , // = LB0 + L,
                      LClear ; // = LB0 + BIT;
          
    // dimensions in steps
    static const int  Tsteps   , // = (T    * mm2Steps),
                      ITsteps  , // = (IT   * mm2Steps), 
                      ITesteps , // = (ITe  * mm2Steps),
                      Lsteps   , // = (L    * mm2Steps),
                      ILLsteps , // = (ILL  * mm2Steps),
                      ILLesteps , // =(ILLe * mm2Steps),
                      DPTsteps , // = (DPT  * mm2Steps),
                      DPLsteps , // = (DPL  * mm2Steps),
                      DSsteps  , // = (DS   * mm2Steps),
                      DAsteps  , // = round(DA   * mm2Steps),
                      RHsteps  , // = (RH   * mm2Steps),
                      RXsteps  , // = round(RX   * mm2Steps),
                      ILsteps; //  = (IL   * mm2Steps);
              
              
    // derived values
    static const int  BITsteps    , // = (BIT    * mm2Steps),
                      TLSsteps    , // = (TLS    * mm2Steps),
                      BTLsteps    , // = (BTL    * mm2Steps),
                      T0steps     , // = (T0     * mm2Steps),
                      T1steps     , // = (T1     * mm2Steps),
                      TB0steps    , // = (TB0    * mm2Steps),
                      TBsteps     , // = (TB     * mm2Steps),
                      T2steps     , // = (T2     * mm2Steps),
                      TNsteps     , // = (TN     * mm2Steps),
                      TClearsteps , // = (TClear * mm2Steps),
                      L0steps     , // = (L0     * mm2Steps),
                      L1steps     , // = (L1     * mm2Steps),
                      LB0steps    , // = (LB0    * mm2Steps),
                      LBsteps     , // = (LB     * mm2Steps),
                      LClearsteps ; //= (LClear * mm2Steps) ;
};

#endif
