final int windowWidth  = 1800,
            windowHeight = 300;
final float mm2Pixels = windowWidth/900.0;

final int mm2Steps  = 2;
final float steps2Pixels =  mm2Pixels/mm2Steps;  
 
  // Platform Dimensions in pixels
  final int baseLength          = round(810 * mm2Pixels),
            baseHeight          = 50,
            rampHeight          = round(2 * mm2Pixels),
            rampBaseLength      = round(106 * mm2Pixels),
            rampSlopeLength     = round(150 * mm2Pixels),
            tagBaseLeftOffset   = round(50 * mm2Pixels),
            labelBaseLeftOffset = round(350 * mm2Pixels),
            baseX               = round((windowWidth - baseLength)/2.0),
            baseY               = windowHeight - baseHeight;

final color tagMarkerColor     = #FFFF00,
              labelMarkerColor = #FF0000,
              bgColor          = #000000,
              platformColor    = #FFFFFF; 
 
int spaceWidth= 20;              
              
void settings(){
  size(windowWidth,windowHeight);
}

int x= 100,
    y = 100;

SteppingLine sl;

void setup(){
  frameRate(10);
  sl =new SteppingLine(baseLength,platformColor,bgColor);
}

void draw(){
  background(bgColor);
  pushMatrix();
  translate(x,y);
  rotate(21*PI/180.0);
  sl.draw();
  popMatrix();
  sl.step();
}