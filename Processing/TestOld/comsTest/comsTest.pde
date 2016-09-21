

class Outputer{
  String out;
  Outputer (String s){
    out = s;
  }
  void putOut(){
    println(out);
  }
}
  
String strings[] = {"Backer Step!",
                    "Labeller Step!",
                    "Tagger Step!",
                    "Label Ceared!",
                    "New Label!",
                    "New Tag!",
                    "Empty Roll Detected!",
                    "Jam Detected!"};
Outputer outPVec[];
CommsMgr cm;

void setup() {
  String portName = "/dev/ttyACM0";
  cm = new CommsMgr(portName);
  outPVec = new Outputer[strings.length];
  for (int i=0;i<strings.length;i++){
    outPVec[i] = new Outputer(strings[i]);
  }
}

void draw() {
  interpretIncomingByte(cm.next());
}


void mousePressed(){
  cm.firstContact = false;
  println("\nreset!");
}

void interpretIncomingByte(int v){
  if (v==65){ // a reset must have happend!
    println("Arduino Reset Detected!");
    mousePressed();
    return;
  }
  for (int i=0; i<8;i++){
    if(boolean(v & (1 << i))){
      outPVec[i].putOut();
    }
  }
}