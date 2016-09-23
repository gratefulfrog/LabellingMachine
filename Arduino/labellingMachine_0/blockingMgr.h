#ifndef BLOCKINGMGR_H
#define BLOCKINGMGR_H

#include "Arduino.h"
#include "config.h"


class BlockingMgr{
  public: 
    static const int labellerStopPoint       , // = Config::LB0steps - Config::DAsteps,
                     taggerStopPoint         , // = Config::TB0steps - Config::DAsteps,
                     backerTagWaitTagPoint   , // = Config::T2steps  - Config::DAsteps,
                     backerTagWaitLabelPoint , // = Config::TNsteps  - Config::DAsteps,
                     backerLabelReleasePoint ; // = Config::LBsteps  - Config::DAsteps;
  /*
    if !blockAtRampEnd):
      labellerStopPoint       = Config::LB0steps;
      taggerStopPoint         = Config::TB0steps;
      backerTagWaitTagPoint   = Config::T2steps;    
      backerTagWaitLabelPoint = Config::TNsteps;
      backerLabelReleasePoint = Config::LBsteps;
    */
};
#endif
