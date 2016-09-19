class Driver{
  int supportID;
  SyncLock syn;
  boolean stepOK = true;
  Sticker tVec[],  // may be null
          lVec[];  // may be null
  
  Driver(int iDD, SyncLock s, Sticker[] tags, Sticker[] labels){
    supportID = iDD;
    syn = s;
    tVec = tags;
    lVec = labels;
  }
  
  boolean canStep(){
    return stepOK;
  }
    
  void step(){
    if (lVec != null){
      for (int i = 0; i< lVec.length; i++){
        if (lVec[i].support == supportID){
          lVec[i].doStep(stepOK);
          lVec[i] = updateLabel(lVec[i]);
        }
      }
    }
    if (tVec != null){
      for (int i = 0; i< tVec.length;i++){
        if (tVec[i].support == supportID){
          tVec[i].doStep(stepOK);
          tVec[i] = updateTag(tVec[i]);
        }
      }
    }
  }
}
  
  