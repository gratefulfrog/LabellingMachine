import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.concurrent.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class multiThreadTest extends PApplet {

  // for the sync queue


String portName = "/dev/ttyACM0";

LinkedBlockingQueue<Integer> q;
ReaderThread reader;

Serial machinePort;                // The serial port
boolean firstContact =false;
int putCounter = 0;

public void setup(){
  machinePort = new Serial(this, portName, 115200);
  // create queue & worker
  q = new LinkedBlockingQueue<Integer>();
  reader = new ReaderThread(q);
  reader.run(); 
  
}

public void draw(){  
}


public void serialEvent(Serial p) { 
  try{
    int inByte = p.read();
    if (firstContact == false) {
      if (inByte == 255) {
        p.clear();          
        firstContact = true; 
        p.write('A');       
        println("\nCommunication Established!");
        Thread.sleep(2000);
      }
    }
    else if (inByte == 255){
       firstContact = false;
       println("Communication reset!");
    }
    else {
      q.put(inByte);
      println("Enqueue:\t",putCounter++,"\t",inByte);
      //Thread.sleep(2000);
    }
  }
  catch (InterruptedException e) {
      println("Exception: " + e);
    }
  }

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
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "multiThreadTest" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
