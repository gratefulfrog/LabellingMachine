 #include "config.h"
 
 //static 
 const float  Config::RAdegrees = 21,  // ramp angle is a user configurable value
              Config::RA        = PI*(180-RAdegrees)/180.0, // not a user variable
              Config::sinRA     = sin(RA),               // not a user variable 
              Config::cosRA     = cos(RA),               // not a user variable
              Config::tanRA     = tan(RA),               // not a user variable
              Config::DA        = RH/sinRA,              // not a user variable
              Config::RX        = RH/tanRA;              // not a user variable

  
 // derived values not user variables!
    //static 
    const int  Config::BIT     = Config::IL +Config::L,
                Config::TLS    = round((Config::L-Config::T)/2.0),
                Config::BTL    = (Config::DS-Config::TLS),
                Config::T0     = 0,
                Config::T1     = Config::DPT,
                Config::TB0    = round(Config::DPT + Config::DA),
                Config::TB     = Config::TB0 + Config::T,
                Config::T2     = Config::TB0 + Config::BIT,
                Config::TN     = Config::TB0 + Config::BTL,
                Config::TClear = Config::TN + Config::BIT,
                Config::L0     = 0,
                Config::L1     = Config::DPL,
                Config::LB0    = round(Config::DPL + Config::DA),
                Config::LB     = Config::LB0 + Config::L,
                Config::LClear = Config::LB0 + Config::BIT;
          
    // dimensions in steps
    //static 
    const int  Config::Tsteps     = (Config::T    * Config::mm2Steps),
                Config::ITsteps   = (Config::IT   * Config::mm2Steps), 
                Config::ITesteps  = (Config::ITe  * Config::mm2Steps),
                Config::Lsteps    = (Config::L    * Config::mm2Steps),
                Config::ILLsteps  = (Config::ILL  * Config::mm2Steps),
                Config::ILLesteps = (Config::ILLe * Config::mm2Steps),
                Config::DPTsteps  = (Config::DPT  * Config::mm2Steps),
                Config::DPLsteps  = (Config::DPL  * Config::mm2Steps),
                Config::DSsteps   = (Config::DS   * Config::mm2Steps),
                Config::DAsteps   = round(Config::DA   * Config::mm2Steps),
                Config::RHsteps   = (Config::RH   * Config::mm2Steps),
                Config::RXsteps   = round(Config::RX   * Config::mm2Steps),
                Config::ILsteps   = (Config::IL   * Config::mm2Steps);
              
              
    // derived values
    //static 
    const int   Config::BITsteps    = (Config::BIT    * Config::mm2Steps),
                Config::TLSsteps    = (Config::TLS    * Config::mm2Steps),
                Config::BTLsteps    = (Config::BTL    * Config::mm2Steps),
                Config::T0steps     = (Config::T0     * Config::mm2Steps),
                Config::T1steps     = (Config::T1     * Config::mm2Steps),
                Config::TB0steps    = (Config::TB0    * Config::mm2Steps),
                Config::TBsteps     = (Config::TB     * Config::mm2Steps),
                Config::T2steps     = (Config::T2     * Config::mm2Steps),
                Config::TNsteps     = (Config::TN     * Config::mm2Steps),
                Config::TClearsteps = (Config::TClear * Config::mm2Steps),
                Config::L0steps     = (Config::L0     * Config::mm2Steps),
                Config::L1steps     = (Config::L1     * Config::mm2Steps),
                Config::LB0steps    = (Config::LB0    * Config::mm2Steps),
                Config::LBsteps     = (Config::LB     * Config::mm2Steps),
                Config::LClearsteps = (Config::LClear * Config::mm2Steps) ;
                
