#ifndef HWCONFIG_H
#define HWCONFIG_H

#include "config.h"

// debug pins !
#define DBG_RED (10)
#define DBG_GREEN (9)
#define DBG_YELLOW (8)

// simulation variables
//#define LABEL_DELAY  (307)  // 207 is as tight as they can be
//#define TAG_DELAY    (200)  // 61 is as tight as they can be
//#define END_DELAY   (1219)   
//#define JAM_DELAY   (2797)   


// steps before removal of label and tag pair
#define KILL_DELAY   (720)  // steps before removal

// output pins and sensor pins
#define B_T_PIN (5)   // bob tagger driver
#define B_L_PIN (6)   // bob labeller driver
#define B_B_PIN (7)   // bob backer driver

#define B_LD_PIN (12) // bob label detector
#define B_TD_PIN (11) // bob tag detector


#define J_T_PIN (51)  // Jyrki tagger driver
#define J_L_PIN (52)  // Jyrki labeller driver
#define J_B_PIN (53)  // Jyrki backer driver
 
#define J_LD_PIN (54) // Jyrki label detector
#define J_TD_PIN (55) // Jyrki tag detector

class HWConfig{
  public:
    // for debugging
    static const boolean debug      = true;
    static const int     flashDelay = 5;

    
    static const int taggerPin        = B_T_PIN, 
                     labellerPin      = B_L_PIN,
                     backerPin        = B_B_PIN,
                     tagDetectorPin   = B_TD_PIN,
                     labelDetectorPin = B_LD_PIN,
                     highDelay   = 50,  // microseconds
                     lowDelay    = 50;  // microseconds
    static const int visualizationDelay; // = max(0,round(5-(0.001*highDelay))); // milliseconds not low delay because this is not needed! + lowDelay);            

    static const long labelDetectorPause, // = Config::Lsteps + round(0.5*Config::ILLsteps),
                      tagDetectorPause; //  = Config::Tsteps + round(0.5*Config::ITsteps);
};
#endif
