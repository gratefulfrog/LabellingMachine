#ifndef DRIVER_H
#define DRIVER_H

#include "Arduino.h"
#include "stickerDequeue.h"

class  PhysicalDriver {
  // this is a placeholder for the real motor driver
  public:
    PhysicalDriver(){};
    virtual void step() =0;
};

class  SMD42PhysicalDriver : public PhysicalDriver{
  protected:
    const int pin;
  public:
    SMD42PhysicalDriver(int p);
    void step();
};

class Driver;
typedef  boolean (Driver::*aFuncPtr)() const;

class Driver{
  protected:
    const int supportID;
    boolean stepOK = false;
    
    static aFuncPtr fa[];
    const StickerDequeue *lDq,
                          *tDq;
    PhysicalDriver *physicalDriver;

    long nbSteps;

     /*** blocking rules ****/
     boolean tagAtTB0() const;
     boolean tagAtT2() const;
     boolean tagAtTN() const;
     boolean tagbetweenTB0andT2() const;
     boolean labebetweenLB0andLB() const;
     boolean labelAtLB0() const;
     boolean taggerCanAdvance() const;
     boolean labellerCanAdvance() const;
     boolean backerCanAdvance() const;
  
     /*** end blocking rules ****/
    
  public:
    static void staticInit(StickerDequeue *lq, StickerDequeue *tq);
    
    Driver(int i, const StickerDequeue *td, const StickerDequeue *ld,int p); // 0: tagger, 1, labeller, 2 backer
    int getSupportID() const; 
    boolean getStepOK() const;
    boolean canAdvance(); // sets stepOK
    void step();      // checks stepOk and steps the driver motor!
    long getNbSteps() const;
    
};
#endif
