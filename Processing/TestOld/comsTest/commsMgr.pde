import processing.serial.*;
PApplet thisSketchThis = this;

class Message{  // just an int for now
  int val;
  Message(int v){
    val = v;
  }
}

class CommsMgr{
  ArrayList <Message> mVec;
  Serial machinePort;                       // The serial port
  boolean firstContact =false;
  
  CommsMgr(String portName){
    machinePort = new Serial(thisSketchThis, portName, 115200);
    mVec= new ArrayList <Message>();
  }
  
  int next(){
    if (mVec.isEmpty()){
      return 0;
    }
    else {
      return mVec.remove(0).val;
    }
  }
}

void serialEvent(Serial port) {
  // read a byte from the serial port:
  int inByte = port.read();
  if (cm.firstContact == false) {
    if (inByte == 'A') {
      port.clear();          
      cm.firstContact = true; 
      port.write('A');       
      println("\nCommunication Established!");
    }
  }
  else {
    cm.mVec.add(new Message(inByte));
  }
}