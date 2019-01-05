# Kos-Scripts
General Functions and programs to use with the Kerbal Operating System - KOS

Updated 1/3/19

## SyncLong.ks(longitude, altitude)

**Description:**  This program calculates the maneuver node required to burn from a circular orbit around any body to reach the desired altitude at a specific longitude.  The ship will reach the desired altitude at apoapsis if going to a higher altitude than the current orbit, or periapsis if going to a lower altitude.  At that same point the ship will reach the desired longitude.

This is especially useful for launching a ship to synchronous orbit directly over a particular spot.  See the comments in the file for examples on how to use it for single satellites or for a launcher with multiple satellites.  

**Required Parameters:**  
* Dersired longitude in decimal form.  + for east, - for west.  
* Altitude in meters.

## RunScience.ks

**Description:**  Starts a terminal window and gives the user 3 choices:
1. Run all science experiments - Runs the GetAllScience() function in StandardLib.ks
2. Collect all science - Finds an Experiment Storage Unit and has it collect all science.
3. Clear all science experiments - Runs ClearAllScience() function and resets all experiements and crew reports.
4. End Program - at this time any key besides 1, 2, or 3 ends the program

**Dependancies:**  Standard_lib.ks


## ExecuteNextNode.ks

**Description:**  Program that executes the maneuver node like Mechjeb.  Must have a planned maneuver node made and it will only use the engines in the current stage.  It will point towards the node, auto warp if there is time, burn until almost done, then throttle down to finish the burn with precision.

**Required Parameters:**  none

_**Optional Parameters:** none_


# Standard_Lib.ks Main Functions:
(This is a library of scripts that can be included in other programs)
* Function GetAllScience(_Optional SensorList, Optional Verbose_)
* Function TransmitAllScience(_Optional SensorList, Optional WarpTime, Optional Verbose, Optional ChargePerMit_)

## Supporting Functions:

* Function GetYorN(_Optional DisplayText_)
* Function GetUserInput()
* Function CheckCharging()
* Function CalcChargeTime(DataSize, _Optional ChargePerMit_)
* Function ShipMaxCharge()
* Function GetESU()
* Function ClearAllScience()
* Function GetDeployableAntList()
* Function ExtendAllAnts(_Optional AntList_)
* Function RetractAllAnts(_Optional AntList_)
* Function GetSensorList()

### Function GetAllScience(_Optional SensorList, Optional Verbose_)

**Description:**  Runs all science experiments available on the ship, or only on a list of science parts that is passed 
to the function as a parameter.  If the ship (or the list) has more than 1 Goo or Science Bay, only 1 of each will be
used.  

**Required functions called:**  GetSensorList()

**Required Parameters:**  none

**Optional Paramenters:**  
* _SensorList - must be a list of parts that are only science experiments._
* _Verbose - Toggles printing messages to the terminal_

### Function TransmitAllScience(_Optional SensorList, Optional WarpTime, Optional Verbose, Optional ChargePerMit_)

**Description:**  Transmits all science data available on the ship, or only a list of science parts that is passed to
the function as a parameter.  For each science experiment it will check to see if there is enough charge.  If not,
it will check to see if the ship is charging and calculate the time required to charge.  The function will warp by
default unless the optional parameter WarpTime is passed in as "false."  The fuction aborts if the ship's total
charge capacity isn't enough to transmit the data or if the ship is not charging and there's not enough charge to
transmit.  If all science is transmitted the function returns "Success." 

**Required functions called:**  
* GetDeployableAntList()
* ExtendAllAnts(AntList) 
* GetSensorList() 
* ShipMaxCharge() 
* CalcChargeTime(DataSize, ChargePerMit) 
* CheckCharging()

**Required Parameters:**  none

_**Optional Parameters:**_ 
* _SensorList - List, contains only science experiments._
* _WarpTime - Boolean, set to false if you_ _don't want auto-warp._ 
* _Verbose - Toggles printing messages to the terminal_
* _ChargePerMit - if you know the charge permit for the antenna, pass this for more accurate_ _time calculations._


_**Known Issues:**_ Do not use this while the ship is at high velocity and in an atmosphere.  It will deploy the 
antennas and break them.  I do not know how to make KSP select a specific antenna to transmit, therefore I wrote the
function to extend all the antennas and use which ever one KSP picks.  _**If you know how to specify a particular antenna for KSP to use for each transmission let me know!**_

### Function GetYorN(_Optional DisplayText_)

**Description:**  Gives the user a prompt in the terminal (default is "Y or N") and captures and returns the user's input.  Only accpets Y or N (upper or lower case).  

### Function GetUserInput(_Optional DisplayText_)

**Description:** Returns the character of a user key press

**Required Parameters:**  none

### Function CheckCharging()

**Description:**  Returns true if the ship's charge is increasing, false if not. 

**Required Parameters:**  none
_**Optional Parameters:** none_

### Function CalcChargeTime(DataSize, _Optional ChargePerMit_)

**Description:**  Returns the amount of time needed to charge the ship to transmit the amount of data (DataSize).  If 
the charge per mit of the antenna is known, then it should be passed in as the optional parameter to make the 
calculation more accurate.

**Required Parameters:**  DataSize - the number of mits.

_**Optional Parameters:** ChargePerMit - this is the charge required to send one mit of the known antenna._

### Function ShipMaxCharge()

**Description:**  Returns the total charge capacity of the ship when all parts that have charge are at 100%.  This does not give the current charge, but the total charge capacity of the ship when at 100% charge.

**Required Parameters:**  None

_**Optional Parameters:** None_

### Function GetEsu()

**Description:**  Searches the ship for an Experiment Storage Unit or "Science Box".  Finds the first one and returns the part.  Returns "False" if there is no ESU on the ship.

**Required Parameters:**  None

_**Optional Parameters:** None_

### Function ClearAllScience()

**Description:**  Resets all science experiments and crew reports.  Science is lost on the science parts (experiements)when this function is run.  This is useful when you've already collected all the science in the Experiment Storage Unit, and there are duplicate results that remain still on the science part(s).  Running this fuction WILL NOT erase science in the Experiment Storage Unit - just on the experiements themselves.

**Required Parameters:**  None

_**Optional Parameters:** None_

### Function GetDeployableAntList()

**Description:**  Returns a list of antenna parts that can extend or retract (fixed antennas not included).  The function checks all the parts on the ship and returns a list of parts of just antennas that can extend or retract.

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

**Description:**  Returns a list of parts that can perform science and save data.  The function checks all the parts on the ship and returns a list of just science parts.

**Required Parameters:**  None

_**Optional Parameters:** None_
