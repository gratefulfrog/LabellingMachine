#ifndef BLOCKINGMGR_H
#define BLOCKINGMGR_H

#include "Arduino.h"
#include "config.h"


class BlockingMgr{
  public: 
  static const int   labellerStopPoint,
                     taggerStopPoint,
                     backerTagWaitTagPoint,
                     backerTagWaitLabelPoint,
                     backerLabelReleasePoint;
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
