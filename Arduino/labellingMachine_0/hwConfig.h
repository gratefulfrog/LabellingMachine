#ifndef HWCONFIG_H
#define HWCONFIG_H

#define B_T_PIN (5)
#define B_L_PIN (6)
#define B_B_PIN (7)

#define J_T_PIN (51)
#define J_L_PIN (52)
#define J_B_PIN (53)

class HWConfig{
  public:
    static const int taggerPin   = J_T_PIN, 
                     labellerPin = J_L_PIN,
                     backerPin   = J_B_PIN,
                     highDelay   = 50,  // microseconds
                     lowDelay    = 50; // microseconds
     static const int visualizationDelay = max(0,round(5-(0.001*highDelay))); // milliseconds not low delay because this is not needed! + lowDelay);            
};
#endif
