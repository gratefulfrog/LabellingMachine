#include "hwConfig.h"

const int HWConfig::visualizationDelay = max(0,round(5-(0.001*highDelay))); // milliseconds not low delay because this is not needed! + lowDelay);            

const long HWConfig::labelDetectorPause = long(Config::Lsteps + Config::L1steps), //round(0.5*Config::ILLsteps) -2),
           HWConfig::tagDetectorPause  = long(Config::Tsteps + Config::T1steps); // round(0.5*Config::ITsteps) -2);
