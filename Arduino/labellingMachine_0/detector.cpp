#include "detector.h"

PhysicalDetector::PhysicalDetector() : lastDetectionSteps(0){
}

SimulatedPhysicalDetector::SimulatedPhysicalDetector(long limit,bool resetOnDetection) : stepLimit(limit), reset(resetOnDetection){}

bool SimulatedPhysicalDetector::stickerDetected(long nbSteps){
  if (nbSteps-lastDetectionSteps>=stepLimit){
    lastDetectionSteps = reset ? nbSteps : 0;
    return true;
  }
  return false;
}

Detector::Detector(PhysicalDetector &pDD) : pD(pDD){}

bool Detector::stickerDetected(long nbSteps) const{
  return pD.stickerDetected(nbSteps);
}

