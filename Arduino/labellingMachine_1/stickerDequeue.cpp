#include "stickerDequeue.h"

/* enter at the tail,
 *  exit at the head
 *  
 */
 
dNode* StickerDequeue::newNode(Sticker* s) const{
  dNode * res =  new dNode();
  res->data=s;
  res->nxtptr = NULL;
  return res;
}

StickerDequeue::StickerDequeue(){
head = tail = NULL;
}
StickerDequeue::StickerDequeue(Sticker* nS){
  head = newNode(nS);
  tail = head;
}

dNode * StickerDequeue::getHead() const {
  return head;
}

Sticker * StickerDequeue::getHeadSticker() const {
  if (head){
    return head->data;
  }
    return NULL;
}

dNode * StickerDequeue::getTail() const{
  return tail;
}

Sticker * StickerDequeue::geTailSticker() const {
  if (tail){
    return tail->data;
  }
    return NULL;
}
void StickerDequeue::push(Sticker* s){
  // put a new elt on tai lof dequeue
  dNode* newTail = newNode(s);
  if (tail == NULL){  // empty Dequeue
    head = newTail;
    tail = newTail;
   }
   else{
    tail->nxtptr = newTail;
    tail= newTail; 
   }
   
}

Sticker* StickerDequeue::pop(){  
  // take head off deque, deletes the pointed node but not the pointed Sticker  
  if (head) {
    // not empty
    Sticker * res = head->data;
    dNode * tempHead = head;
    head = head->nxtptr;
    delete tempHead;
    return res;
  }
  else{
    return NULL;
  }
}

