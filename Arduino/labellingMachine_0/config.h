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
                      
    static const float  RAdegrees,
                        RA, 
                        sinRA, 
                        cosRA,
                        tanRA, 
                        DA,   
                        RX;
  
     /**************   END OF USER CONFIGRABLE VALUES *******************/          
  
    // derived values not user variables!
    static const int  BIT,
                      TLS,
                      BTL,
                      T0,
                      T1,
                      TB0,
                      TB,
                      T2,
                      TN,
                      TClear,
                      L0,
                      L1,
                      LB0,
                      LB,
                      LClear;
          
    // dimensions in steps
    static const int  Tsteps,
                      ITsteps,
                      ITesteps,
                      Lsteps,
                      ILLsteps,
                      ILLesteps,
                      DPTsteps,
                      DPLsteps,
                      DSsteps,
                      DAsteps,
                      RHsteps,
                      RXsteps,
                      ILsteps;
              
              
    // derived values
    static const int  BITsteps,
                      TLSsteps,
                      BTLsteps,
                      T0steps,
                      T1steps,
                      TB0steps,
                      TBsteps,
                      T2steps,
                      TNsteps,
                      TClearsteps,
                      L0steps,
                      L1steps,
                      LB0steps,
                      LBsteps,
                      LClearsteps;
};

#endif
