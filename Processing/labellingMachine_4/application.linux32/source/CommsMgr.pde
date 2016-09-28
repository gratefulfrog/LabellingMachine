class CommsMgr{
  LinkedBlockingQueue<Integer> q;
  CommsMgr(LinkedBlockingQueue<Integer> queue){
    q =queue;
  }
  
  int interpretIncomingByte(){
    int v =  0;
    try {
      v = q.take();
    }
    catch (InterruptedException e) {
      println("Exception: " + e);
    }
    return v;
  }
}