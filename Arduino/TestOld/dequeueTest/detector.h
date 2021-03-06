#ifndef DETECTOR_H
#define DETECTOR_H

#include "Arduino.h"

class PhysicalDetector{
  protected:
    unsigned long lastDetectionSteps;
  public:
    PhysicalDetector();
    virtual bool stickerDetected(unsigned long nbSteps) =0; // must be defined in subclass with real code
};

class SimulatedPhysicalDetector : public PhysicalDetector{
  protected:
    unsigned long stepLimit;
  public:
    SimulatedPhysicalDetector(unsigned long limit);
    bool stickerDetected(unsigned long nbSteps); // must be defined in subclass with real code
};



class Detector{
  protected:
    PhysicalDetector &pD;
    
  public:
    Detector(PhysicalDetector&);
    bool stickerDetected(unsigned long nbSteps) const;
};

#endif
