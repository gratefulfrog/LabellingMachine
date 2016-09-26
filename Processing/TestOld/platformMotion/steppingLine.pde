class SteppingLine{
  final float length;
  final int spaceWidth=20;
  final color col, bg;
  long steps;
  
  SteppingLine(float l, color c, color bc){
    length = l;
    col = c;
    bg = bc;
    steps = 0;
  }
  void spacedLine(){
    stroke(bg);
    for(int i= -spaceWidth; i< length ; i += 2*spaceWidth){ 
      line(i,0,i+spaceWidth,0);
  }
}
  void step(){
    steps = (steps+1)%(spaceWidth*2);
  }
  void draw(){
    stroke(col);
    line(0,0,length,0);
    stroke(bg);
    pushMatrix();
    translate(steps,0);
    spacedLine();
    popMatrix();
    
  } 
}
  