#ifndef STICKER_H
#define STICKER_H

#include "Arduino.h"


class Sticker{
  protected:
    unsigned int nbSteps;
    const unsigned int type; 
    unsigned int support;

  public:
     Sticker(int t);
     void step();
     unsigned int getNbSteps() const;
     unsigned int getType() const;
     unsigned int getSupport() const;
     void setSupport(unsigned int);
};

class Tag : public Sticker{
  public:
    Tag();
};
class Label : public Sticker{
  public:
    Label();
};

#endif
