#include "detector.h"

PhysicalDetector::PhysicalDetector() : lastDetectionSteps(0){
}

SimulatedPhysicalDetector::SimulatedPhysicalDetector(long limit, bool resetOnDetection) : stepLimit(limit), reset(resetOnDetection){}

bool SimulatedPhysicalDetector::stickerDetected(long nbSteps){
  if (nbSteps-lastDetectionSteps>=stepLimit){
    lastDetectionSteps = reset ? nbSteps : 0;
    return true;
  }
  return false;
}

SimulatedPhysicalEndDetector::SimulatedPhysicalEndDetector(long limit) : stepLimit(limit){}

bool SimulatedPhysicalEndDetector::stickerDetected(long nbSteps){
  if (nbSteps>=stepLimit){
    return true;
  }
  return false;
}

Detector::Detector(PhysicalDetector &pDD) : pD(pDD){}

bool Detector::stickerDetected(long nbSteps) const{
  return pD.stickerDetected(nbSteps);
}

ContrastDetector::ContrastDetector(int inputPin, long pauseSteps):  pin(inputPin), nbStepsPause(pauseSteps), isActive(true){
  pinMode(pin,INPUT_PULLUP);
}

bool ContrastDetector::stickerDetected(long nbSteps){
  // it's active if we just started and haven't even done the min number of steps,
  // or if number of steps since last detection is greater than the pause,
  // otherwise not active
  //bool isActive= ((nbSteps < nbStepsPause) || 
  //                (nbSteps- lastDetectionSteps>=nbStepsPause));
  //return false;
  if (isActive){
    if (!digitalRead(pin)){
      //detection!!
      lastDetectionSteps = nbSteps;
      isActive = false;
      return true;
    }
  }
  else{
    isActive=  (nbSteps- lastDetectionSteps>=nbStepsPause);
  }
  return false;
}

