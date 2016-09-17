
final Config config = new Config();
Platform platform   = new Platform(config);
Tag   tag1           = new Tag(config,1),
      tag2           = new Tag(config,3);

Label label1         = new Label(config,2),
      label2         = new Label(config,3);

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
  tag1.doStep();
  tag2.doStep();
  label1.doStep();
  label2.doStep();
}