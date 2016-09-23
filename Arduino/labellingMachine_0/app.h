#ifndef APP_H
#define APP_H

#include "Arduino.h"
#include "sticker.h"
#include "stickerDequeue.h"
#include "detector.h"
#include  "config.h"
#include  "driver.h"

// simulation variables
#define LABEL_DELAY (307)  // 207 is as tight as they can be
#define TAG_DELAY  (200)  // 61 is as tight as they can be
#define KILL_DELAY (720)  // steps before removal
#define END_DELAY (1219)   
#define JAM_DELAY (2797)   

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

    Detector *makeDetector(unsigned long nbSteps, bool reset);    
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
