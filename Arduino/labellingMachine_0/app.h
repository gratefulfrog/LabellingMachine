#ifndef APP_H
#define APP_H

#include "Arduino.h"
#include "sticker.h"
#include "stickerDequeue.h"
#include "detector.h"
#include "config.h"
#include "driver.h"

class App{
  protected:

    Detector *lDetector,  // label detector
             *tDetector,  // tag detector
             *bDetector,  // backer detector
             *eDetector,  // end of roll detector
             *jDetector;  // jam detector
             
    StickerDequeue *lDeq,
                   *tDeq;
    
    Driver *tagger,
             *labeller,
             *backer;
    
    byte outgoing = 0;
    unsigned long counter =0;

    Detector *makeDetector(long nbPauseSteps, bool reset, int pin);    
    void setAlerts();  // need to implement this in real machine
    void detectNewTagsAndLabels();
    void detectedExpiredTagLabelPairs();
    void updateStickerSupport();
    void setDriversOk2Step();
    void stepAll();
 
  public:
    App();
    void loop();
};

#endif
