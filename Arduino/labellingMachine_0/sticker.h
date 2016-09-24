#ifndef STICKER_H
#define STICKER_H

#include "Arduino.h"


class Sticker{
  protected:
    //unsigned int nbSteps;
    long nbSteps;
    const unsigned int type; 
    unsigned int support;

  public:
     Sticker(int t);
     void step();
     //unsigned int getNbSteps() const;
     long getNbSteps() const;
     unsigned int getType() const;
     unsigned int getSupport() const;
     void setSupport(unsigned int);
};

class Tag : public Sticker{
  public:
    //Tag();
    Tag(int steps);
};
class Label : public Sticker{
  public:
    //Label();
    Label(int steps);
};

#endif
