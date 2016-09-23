#ifndef STICKERDEQUEUE_H
#define STICKERDEQUEUE_H
/* enter at the tail,
 *  exit at the head
 *  
 */


#include "sticker.h"
#include "Arduino.h"

typedef struct dNode {
  Sticker *data;
  struct dNode *nxtptr;
} dNode_t;

class StickerDequeue{
  protected:
    dNode *head=NULL,
          *tail=NULL;
     dNode* newNode(Sticker*) const;
           
  public:
     StickerDequeue();
     StickerDequeue(Sticker*);
     dNode *getHead() const;
     Sticker * getHeadSticker() const;
     dNode *getTail() const;
     Sticker * geTailSticker() const;
     void push(Sticker*); // put a new elt on front of deque
     Sticker* pop();  // take last off deque, deletes the pointed node
};

#endif
