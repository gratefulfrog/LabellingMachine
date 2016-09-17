
final Config config = new Config();
Platform platform   = new Platform(config);
Tag   tag           = new Tag(config);
Label label         = new Label(config);

/*
void settings() {
   size(config.windowWidth,config.windowHeight);
}
*/
void setup(){
  size(1800,300);
  frameRate(config.frameRate);  // nb steps per second
  background(0);
  /*
  println (config.mm2Steps);
  println (config.LClearsteps);
  println (config.BITsteps);
  println (config.toto);
  
  platform.draw();
  tag.doStep();
  label.doStep();
  */
}


void draw(){
  background(0);
  platform.draw();
  tag.doStep();
  label.doStep();
}