
final Config config = new Config();
Platform platform   = new Platform(config);
/*
Tag   tag1           = new Tag(config,1),
      tag2           = new Tag(config,1);


Label label1         = new Label(config,2),
      label2         = new Label(config,2);

*/
final int nbTags =7;
Tag tVec[];
final int nbLabels =7;
Label lVec[];

/*
void settings() {
   size(config.windowWidth,config.windowHeight);
}
*/
void setup(){
  size(1800,300);
  frameRate(config.frameRate);  // nb steps per second
  background(0);
  tVec = new Tag[nbTags];
  for (int i = 0; i< nbTags;i++){
    tVec[i] =  new Tag(config,1);
    tVec[i].nbSteps = -250 *i;
  }
  lVec = new Label[nbLabels];
  for (int i = 0; i< nbLabels;i++){
    lVec[i] =  new Label(config,2);
    lVec[i].nbSteps = -350 *i;
  }
}

Tag updateTag(Tag t){
   if (t.support == 3 && t.nbSteps>1500){
    t = new Tag(config,1);
  }
  else if (t.support == 1 && t.nbSteps>350){
    t.support = 3;// = new Tag(config,1);
    t.nbSteps = 0;
  }
  return t;
}
Label updateLabel(Label l){
   if (l.support == 3 && l.nbSteps>1000){
    l = new Label(config,2);
  }
  else if (l.support == 2 && l.nbSteps>400){
    l.support = 3;// = new Tag(config,1);
    l.nbSteps = 0;
  }
  return l;
}

Boolean good2Label = false;

void draw(){
  background(0);
  platform.draw();
  good2Label = good2Label || (tVec[0].support == 3 && tVec[0].nbSteps > 100);
  if (good2Label){
  for (int i = 0; i< nbLabels;i++){
    lVec[i].doStep();
    lVec[i] = updateLabel(lVec[i]);
  }
  }
   for (int i = 0; i< nbTags;i++){
    tVec[i].doStep();
    tVec[i] = updateTag(tVec[i]);
  }
}