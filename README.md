# Kos-Scripts
General Functions and programs to use with the Kerbal Operating System - KOS

Updated 1/23/19

## SyncLong.ks(longitude, altitude)

**Description:**  This program calculates the maneuver node required to burn from a circular orbit around any body to reach the desired altitude at a specific longitude.  The ship will reach the desired altitude at apoapsis if going to a higher altitude than the current orbit, or periapsis if going to a lower altitude.  At that same point the ship will reach the desired longitude.

This is especially useful for launching a ship to synchronous orbit directly over a particular spot.  See the comments in the file for examples on how to use it for single satellites or for a launcher with multiple satellites.  

**Required Parameters:**  
* Dersired longitude in decimal form.  + for east, - for west.  
* Altitude in meters.

**Optional Paramenters:**  
* _Verbose - suppresses printing messages to the terminal if set to false._

## RunScience.ks

**Description:**  Starts a terminal window and gives the user 3 choices:
1. Run all science experiments - Runs the GetAllScience() function in StandardLib.ks
2. Collect all science - Finds an Experiment Storage Unit and has it collect all science.
3. Clear all science experiments - Runs ClearAllScience() function and resets all experiements and crew reports.
4. End Program 

**Dependancies:**  Standard_lib.ks

## ExecuteNextNode.ks

**Description:**  Program that executes the maneuver node like Mechjeb.  Must have a planned maneuver node made and it will only use the engines in the current stage.  It will point towards the node, auto warp if there is time, burn until almost done, then throttle down to finish the burn with precision.

**Required Parameters:**  none

_**Optional Parameters:** none_


# Standard_Lib.ks Main Functions:
(This is a library of scripts that can be included in other programs)
* Function GetAllScience(_Optional SensorList, Optional Verbose_)
* Function TransmitAllScience(_Optional SensorList, Optional WarpTime, Optional Verbose, Optional ChargePerMit, Optional TransSpeed_)

## Supporting Functions:

* Function GetYorN(_Optional DisplayText_)
* Function GetUserInput()
* Function CheckCharging()
* Function CalcChargeTime(ChargeNeeded)
* Function ShipMaxCharge()
* Function GetESUlist()
* Function ClearAllScience(_Optional SensorList_)
* Function GetDeployableAntList()
* Function GetNonDeployableAntList()
* Function ExtendAllAnts(_Optional AntList_)
* Function RetractAllAnts(_Optional AntList_)
* Function GetSensorList()

### Function GetAllScience(_Optional SensorList, Optional Verbose_)

**Description:**  Runs all science experiments available on the ship, or only on a list of science parts that is passed to the function as a parameter.  If the ship (or the list) has more than 1 Goo or Science Bay, only 1 of each will be used. Returns number of science experiments conducted.

**Required functions called:**  GetSensorList()

**Required Parameters:**  none

**Optional Paramenters:**  
* _SensorList - must be a list of parts that are only science experiments._
* _Verbose - suppresses printing messages to the terminal if set to false._

### Function TransmitAllScience(_Optional SensorList, Optional WarpTime, Optional Verbose, Optional ChargePerMit_, Optional TransSpeed)

**Description:**  Transmits all science data available on the ship, or only a list of science parts that is passed to the function as a parameter.  The ship must have an external antenna part with a connection to the KSC to transmit; otherwise, the function will abort.  This will not use the data transmitter in a command module. For each science experiment it will check to see if there is enough charge.  If not, it will check to see if the ship is charging and calculate the time required to charge.  The function will warp by default unless the optional parameter WarpTime is passed in as "false."  The fuction aborts if the ship's total charge capacity isn't enough to transmit the data, or if the ship is not charging and there's not enough charge to transmit. Has a reserve charge variable set at 5%; this stops the function from dropping the total charge of the ship to below this percentage of it's total charge capacity.  Highly encouraged to use optional parameters ChargePerMit and TransSpeed to make sure the ship has just enough charge to transmit and accurate warping.

**Required functions called:**  
* GetDeployableAntList()
* ExtendAllAnts(AntList) 
* GetSensorList() 
* ShipMaxCharge() 
* CalcChargeTime(ChargeNeeded) 
* CheckCharging()

**Required Parameters:**  none

_**Optional Parameters:**_ 
* _SensorList - List, contains only science experiments._
* _WarpTime - Boolean, set to false if you_ _don't want auto-warp._ 
* _Verbose - suppresses printing messages to the terminal if set to false._
* _ChargePerMit - if you know the charge permit for the antenna, pass this for more accurate time calculations._
* _TransSpeed - The transmission speed of the antenna in Mits/Sec_


_**Known Issues:**_ Do not use this while the ship is at high velocity and in an atmosphere.  It will deploy the antennas and break them.  I do not know how to make KSP select a specific antenna to transmit, therefore I wrote thefunction to extend all the antennas and use which ever one KSP picks.  _**If you know how to specify a particular antenna for KSP to use for each transmission let me know!**_

### Function GetYorN(_Optional DisplayText_)

**Description:**  Gives the user a prompt in the terminal (default is "Y or N") and captures and returns the user's input.  Only accpets Y or N (upper or lower case).  

### Function GetUserInput(_Optional DisplayText_)

**Description:** Returns the character of a user key press

**Required Parameters:**  none

### Function CheckCharging()

**Description:**  Returns true if the ship's charge is increasing, false if not. 

**Required Parameters:**  none
_**Optional Parameters:** none_

### Function CalcChargeTime(ChargeNeeded)

**Description:**  Returns the amount of time needed to charge the ship based on the needed charge passed into the function.  Calculates by how fast the ship is charging divided by charge needed.

**Required Parameters:**  ChargeNeeded - desired addtional electrical charge of the ship

### Function ShipMaxCharge()

**Description:**  Returns the total charge capacity of the ship when all parts that have charge are at 100%.  This does not give the current charge, but the total charge capacity of the ship when at 100% charge.

**Required Parameters:**  None

_**Optional Parameters:** None_

### Function GetEsulist()

**Description:**  Searches the ship for an Experiment Storage Unit or "Science Box".  Finds the first one and returns a list with just 1 ESU - the first one it finds.  Returns a blank list if there is no ESU on the ship.

**Required Parameters:**  None

_**Optional Parameters:** None_

### Function ClearAllScience(_Optional SensorList_)

**Description:**  Resets all science experiments and crew reports.  Science is lost on the science parts (experiements)when this function is run.  Goo Canisters and Science Bays are reset, so they can be run again. This is useful when you've already collected all the science in the Experiment Storage Unit, and there are duplicate results that still remain on the science part(s).  Running this fuction WILL NOT erase science in the Experiment Storage Unit - just on the experiements themselves. Returns number of science experiments reset.

**Required Parameters:**  None

_**Optional Parameters:** Sensor list - a list of science parts the user can send to the function._

### Function GetDeployableAntList()

**Description:**  Returns a list of antenna parts that can extend or retract (fixed antennas not included).  The function checks all the parts on the ship and returns a list of parts of just antennas that can extend or retract.

**Required Parameters:**  None

_**Optional Parameters:** None_

### Function GetNonDeployableAntList()

**Description:**  Returns a list of fixed, non deployable antenna parts.  The function checks all the parts on the ship and returns a list of parts of just fixed antennas.  This does not include the transmitter in a command module

**Required Parameters:**  None

_**Optional Parameters:** None_

### Function ExtendAllAnts(_Optional AntList_)

**Description:**  Extends all deployable antennas on the ship or just the ones in a list passed to the function 

**Required Parameters:**  None

_**Optional Parameters:** AntList - a list of parts, must only be deployable antennas, that you want extended_

### Function RetractAllAnts(_Optional AntList_)

**Description:**  Retracts all deployable antennas on the ship or just the ones in a list passed to the function 

**Required Parameters:**  None

_**Optional Parameters:** AntList - a list of parts, must only be deployable antennas, that you want Retracted_

### Function GetSensorList()

**Description:**  Returns a list of parts that can perform science and save data.  The function checks all the parts on the ship and returns a list of those that can perform science.

**Required Parameters:**  None

_**Optional Parameters:** None_
