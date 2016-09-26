
class ReaderThread  implements Runnable {
  LinkedBlockingQueue<Integer> q;
  int readCount = 0;
  
  ReaderThread(LinkedBlockingQueue<Integer> queue) {
    q = queue;
  }
  
  void run() {
    try {
      println("reader running...");
      Thread.sleep(1000);    
      while (true){
         int r = q.take();
         println("\n\t\t\tRead:\t",readCount++,"\t",r);
      }
    }
    catch (InterruptedException e) {
      println("Exception: " + e);
    }
  }
}