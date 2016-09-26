
public class ReaderThread  implements Runnable {
  private LinkedBlockingQueue<Integer> q;
  private int readCount = 0;
  private boolean ok = true;
  
  public ReaderThread(LinkedBlockingQueue<Integer> queue) {
    q = queue;
  }
  
  public void run() {
    try {
      println("reader running...");
      Thread.sleep(1000);    
      while (true){
         int r = q.take();
         println("\t\t\tRead:\t",readCount++,"\t",r);
      }
    }
    catch (InterruptedException e) {
      println("Exception: " + e);
    }
    println("\t\t\treader exiting...");
  }
}