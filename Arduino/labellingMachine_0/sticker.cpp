#include "sticker.h"


Sticker::Sticker(int t) : type(t), nbSteps(0), support(t){}

void Sticker::step(){
  nbSteps++;
}
unsigned int Sticker::getNbSteps() const{
  return nbSteps;
}
unsigned int Sticker::getType() const{
  return type;
}

unsigned int Sticker::getSupport() const{
  return support;
}
void Sticker::setSupport(unsigned int i){
  support = i;
}


Tag::Tag() : Sticker(0){}

Label::Label() : Sticker(1){}

