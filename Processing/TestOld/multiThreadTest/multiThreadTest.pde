import java.util.concurrent.*;  // for the sync queue
import processing.serial.*;

String portName = "/dev/ttyACM0";

LinkedBlockingQueue<Integer> q;
ReaderThread reader;

Serial machinePort;                // The serial port
boolean firstContact =false;
int putCounter = 0;

void setup(){
  machinePort = new Serial(this, portName, 115200);
  // create queue & worker
  q = new LinkedBlockingQueue<Integer>();
  reader = new ReaderThread(q);
  reader.run(); 
}

void draw(){  
}


void serialEvent(Serial p) { 
  try{
    int inByte = p.read();
    if (firstContact == false) {
      if (inByte == 255) {
        p.clear();          
        firstContact = true; 
        p.write('A');       
        println("\nCommunication Established!");
        Thread.sleep(1000);
      }
    }
    else if (inByte == 255){
       firstContact = false;
       println("Communication reset!");
    }
    else {
      if (inByte !=0){
        q.put(inByte);
        println("\nEnqueue:\t",putCounter++,"\t",inByte);
      }
    }
  }
  catch (InterruptedException e) {
      println("Exception: " + e);
    }
  }