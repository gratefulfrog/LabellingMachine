#include "blockingMgr.h"


const int  BlockingMgr::labellerStopPoint       = Config::LB0steps - Config::DAsteps,
           BlockingMgr::taggerStopPoint         = Config::TB0steps - Config::DAsteps,
           BlockingMgr::backerTagWaitTagPoint   = Config::T2steps  - Config::DAsteps,
           BlockingMgr::backerTagWaitLabelPoint = Config::TNsteps  - Config::DAsteps,
           BlockingMgr::backerLabelReleasePoint = Config::LBsteps  - Config::DAsteps;

