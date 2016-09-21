#ifndef STICKER_H
#define STICKER_H


class Sticker{
  protected:
    unsigned int nbSteps;
    const  unsigned int type;

  public:
     Sticker(int t);
     void step();
     unsigned int getNbSteps() const;
     unsigned int getType() const;
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
