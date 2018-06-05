# The Great Labelling Machine

Following Microsoft's purchase of Github, this project has migrated to gitlab.

This repo contains code for:
* The GLM Simulator/Visualization:
 * The same code can either simulate the full physical machine or simply receive and 
   display the state of the physical machine.
* The GLM Machine code:
 * Arduino code to run the machine and communicate with the visualization.

Which code do you need?
* Arduino:
 * All the code in the directory `Arduino/labellingMachine_n` where *n* is the biggest number in the list
* Visualization:
 * All the code in the directory `Processing/labellingMachine_n` where *n* is the biggest number

Execution:
* Arduino:
  * `hwConfig.h` update the `HWConfig` class to correspond to your physical installation
  * `config.h`  update any values, but be very careful as to what they mean! ask if unsure
  * `config.cpp` if needed, update ONLY `Config::RAdegrees` to the actual angle of the tag/label ramps
  * compile and upload to the arduino
* PC:
  * First build the applicaiton:
    * open the `processing.org IDE` and open the file `Processing/labellingMachine_n/labellingMachine_n.pde`
    * use the `file menu - export application` to build the applciaton for the target platform(s) of interest
  * Then execute it:
    * open a terminal in the application directory corresponding to the target platform
    * execute `./labellingMachine_n PortName`  where *n* is the correct number and *PortName* is the Serial port being used by the Arduino, for example  
      `$ ./labellingMachine_4 /dev/ttyACM0`
    * NOTE: if no port is provided, the application will execute in simulation mode to demonstrate how it works, but it will not open a connection to the arduino.
  

