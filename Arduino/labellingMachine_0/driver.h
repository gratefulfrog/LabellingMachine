#ifndef DRIVER_H
#define DRIVER_H

#include "Arduino.h"
#include "stickerDequeue.h"

class Driver;
typedef  boolean (Driver::*aFuncPtr)() const;

class Driver{
  protected:
    const int supportID;
    boolean stepOK = false;
    
    boolean taggerCanAdvance() const;
    boolean labellerCanAdvance() const;
    boolean backerCanAdvance() const;
    static aFuncPtr fa[];
    static StickerDequeue *lDeq,
                          *tDeq;

     /*** blocking rules ****/
  
     /*** end blocking rules ****/
    
  public:
    static void staticInit(StickerDequeue *lq, StickerDequeue *tq);
    
    Driver(int i); // 0: tagger, 1, labeller, 2 backer
    int getSupportID() const; 
    boolean getStepOK() const;
    void canAdvance(); // sets stepOK
    void step();      // checks stepOk and steps the driver motor!
    
};
#endif
