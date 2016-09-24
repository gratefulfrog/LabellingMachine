#ifndef DETECTOR_H
#define DETECTOR_H

#include "Arduino.h"

class PhysicalDetector{
  protected:
    long lastDetectionSteps;
  public:
    PhysicalDetector();
    virtual bool stickerDetected(long nbSteps) =0; // must be defined in subclass with real code
};

class SimulatedPhysicalDetector : public PhysicalDetector{
  protected:
    long stepLimit;
    bool reset;
  public:
    SimulatedPhysicalDetector(long limit, bool resetOnDetection); // use reset for start deetectors, not for end backer detecor
    bool stickerDetected(long nbSteps); // must be defined in subclass with real code
};

class Detector{
  protected:
    PhysicalDetector &pD;
    
  public:
    Detector(PhysicalDetector&);
    bool stickerDetected(long nbSteps) const;
};

#endif
