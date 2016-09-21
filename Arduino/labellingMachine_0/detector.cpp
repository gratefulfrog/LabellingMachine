#include "detector.h"

PhysicalDetector::PhysicalDetector() : lastDetectionSteps(0){
}

SimulatedPhysicalDetector::SimulatedPhysicalDetector(unsigned long limit,bool resetOnDetection) : stepLimit(limit), reset(resetOnDetection){}

bool SimulatedPhysicalDetector::stickerDetected(unsigned long nbSteps){
  if (nbSteps-lastDetectionSteps>=stepLimit){
    lastDetectionSteps = reset ? nbSteps : 0;
    return true;
  }
  return false;
}

Detector::Detector(PhysicalDetector &pDD) : pD(pDD){}

bool Detector::stickerDetected(unsigned long nbSteps) const{
  return pD.stickerDetected(nbSteps);
}

