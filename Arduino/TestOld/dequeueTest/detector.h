#ifndef DETECTOR_H
#define DETECTOR_H

#include "driver.h"

class PhysicalDetector{
  public:
    PhysicalDetector();
};

class Detector{
  protected:
    PhysicalDetector *pd;
    DriverStepFn *;
    
  public:
     Sticker(int t);
     void step();
     unsigned int getNbSteps() const;
     unsigned int getType() const;
};

#endif
