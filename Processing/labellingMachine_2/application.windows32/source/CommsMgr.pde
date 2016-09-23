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
      if (mVec.isEmpty()){
        // this did not trigger or prevent the NullPointer exception!
        println(mVec.size());
      }
      return mVec.remove(0).val;
    }
  }
  int interpretIncomingByte(){
    int v =  next();
    if (v==65){ // a reset must have happend!
      println("Arduino Reset Detected!");
      cm.firstContact = false;
      println("\nreset!");
      return 0;
    }
    else{
      return v;
    }
  }
  void readIncoming() {
    if (machinePort.available()>0){
      // read a byte from the serial port:
      int inByte = machinePort.read();
      if (cm.firstContact == false) {
        if (inByte == 'A') {
          machinePort.clear();          
          cm.firstContact = true; 
          machinePort.write('A');       
          println("\nCommunication Established!");
        }
      }
      else {
        //if (inByte != 65){
          cm.mVec.add(new Message(inByte));
        //}
      }
    }
  }
}