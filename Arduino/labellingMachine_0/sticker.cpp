#include "sticker.h"


Sticker::Sticker(int t) : type(t), nbSteps(0), support(t){}

void Sticker::step(){
  nbSteps++;
}
//unsigned int Sticker::getNbSteps() const{
long Sticker::getNbSteps() const{
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

Tag::Tag(int steps) : Sticker(0){
 nbSteps = steps;
 }

Label::Label(int steps) : Sticker(1){
 nbSteps = steps;
 }

