#include "stickerDequeue.h"

StickerDequeue::StickerDequeue(){
head = tail = NULL;
}
StickerDequeue::StickerDequeue(Sticker* nS){
  head = new dNode;
  head->nxtptr = NULL;
  head->data = nS;
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
  // put a new elt on front of deque
  dNode* newHead = new dNode;
  newHead->data = s;
  newHead->nxtptr = head;
  if (tail == NULL){  // empty Dequeue
    tail = newHead;
   }
   head = newHead;
}

Sticker* StickerDequeue::pop(){  
  // take last off deque, deletes the pointed node but not the pointe Sticker  
  if (tail == NULL){
    // empty
    return NULL;
  }
  Sticker * res = tail->data;
  if (head == tail){ // only one elt
    delete head;
    head = tail = NULL;
  }
  else { // more than one elt
    dNode *newTail = head;
    while(newTail->nxtptr !=tail){
      newTail = newTail->nxtptr;
    }
    // now we have the new tail
    delete tail;
    tail = newTail;
  }
  return res;
}

