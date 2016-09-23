class HWConfig{
  public:
    static const int taggerPin   = 5,
                     labellerPin = 6,
                     backerPin   = 7,
                     highDelay   = 1,
                     lowDelay    = 1;
     static const int visualizationDelay = 5 - (highDelay); // not low delay because this is not needed! + lowDelay);            
};

