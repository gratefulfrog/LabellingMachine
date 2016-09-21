#include "sticker.h"


Sticker::Sticker(int t) : type(t), nbSteps(0){}

void Sticker::step(){
  nbSteps++;
}
unsigned int Sticker::getNbSteps() const{
  return nbSteps;
}
unsigned int Sticker::getType() const{
  return type;
}

Tag::Tag() : Sticker(1){}

Label::Label() : Sticker(2){}

