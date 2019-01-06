@lazyglobal off.

function GetYorN {
//Function to get the users input of 'y' or 'n' lower or upper case
    Declare Parameter DisplayText is "(Y/N)".  //Option parameter to display a different message
    Declare Local Answer to "n/a".
    Declare Local Done to False.

    Print DisplayText.
    until Done {
        if terminal:input:haschar {
        set Answer to terminal:input:getchar(). 
            if Answer = "y" or Answer = "n" {
                set Done to True.
            } else {
                Print ("     Type 'Y' or 'N'").
                Print DisplayText.
            }
        }
    }
    Return Answer.
}.

function GetUserInput{
//Function to get the users input 
    Declare Local Answer to "n/a".
    Declare Local Done to False.

    until Done {
        if terminal:input:haschar {
        set Answer to terminal:input:getchar(). 
        set Done to True.  
        }
    }
    Return Answer.
}.

function CheckCharging {    
//Checks to see if the ship is gaining electrical charge
    Declare Local C1 to 0.0.
    Declare Local C2 to 0.0.    
    set C1 to ship:electriccharge.
    wait 0.25.
    set C2 to ship:electriccharge.
    if c1 < c2 {
        return true.
    } 
    Else {
        return false.
    }.
}.

function CalcChargeTime {
//Returns the time until the ship charges enough to transmit a given amount of science data 
    Declare Parameter DataSize.  //Required parameter - the size of the data needed to be transmitted
    Declare Parameter PerMit is 10.//Optional parameter 
    //- the amount of charge needed to transmit 1 "Mit" of data.  This varies per antenna.  Highest stock is 10
    
    Declare Local Charge1 to 0.0.
    Declare Local Charge2 to 0.0.
    Declare Local ChargePerSec to 0.0.
        
    set Charge1 to ship:electriccharge.
        wait 0.25.
    set Charge2 to ship:electriccharge.
    set ChargePerSec to (Charge2 - Charge1) / 0.25.
   
    return ((DataSize * PerMit) - ship:electriccharge) / ChargePerSec.
}.

function ShipMaxCharge {
//Returns the total charge of the ship at full charge
    Declare Local ResList to ship:resources.
    Declare Local amount to 0.0.
    for item in ResList {
        if item:name = "ElectricCharge" {
            set amount to item:capacity.
        }
    }
    return amount.
}.

function GetESU {
//Returns an Experiment Storage Unit Part
    
    Declare Local plist to ship:parts.
    
        for item in plist {
            if item:name = "ScienceBox" {
                return item.
            }
        }
    print("No ESU on this ship").
    Return false.
}. 

function GetDeployableAntList {
//Returns a list of Deployable Antennas
    Declare Local AntList to list().
    Declare Local ModuleList to list().
    Declare Local plist to ship:parts.
    
        for item in plist {
            set ModuleList to item:modules.
            for mod in modulelist {
                if mod = "ModuleDeployableAntenna" {
                    AntList:add(item).
                }
            }
        }
    return AntList.
}. 

function ExtendAllAnts {
//Extend all Deployable Antennas or deploy a list of antennas
    Declare Parameter AntList is list().  //Optional paramenter - list of antennas to deploy

    if AntList:length = 0 {
        set AntList to GetDeployableAntList().
    }.
    For Ant in AntList {
        Ant:getmodule("ModuleDeployableAntenna"):doaction("extend antenna", true).
    }
}.

function RetractAllAnts {
//Retract all Deployable Antennas or deploy a list of antennas
    Declare Parameter AntList is list().  //Optional paramenter - list of antennas to retract

    if AntList:length = 0 {
        set AntList to GetDeployableAntList().
    }.
    For Ant in AntList {
        Ant:getmodule("ModuleDeployableAntenna"):doaction("retract antenna", true).
    }
}.

function GetSensorList {
//Returns a list of all science parts
    Declare Local SensorList to list().
    Declare Local ModuleList to list().
    Declare Local plist to ship:parts.
    
        for item in plist {
            set ModuleList to item:modules.
            for mod in modulelist {
                if mod = "ModuleScienceExperiment" {
                    SensorList:add(item).
                }
            }
        }
    return SensorList.
}. 

Function ClearAllScience {

    Declare Parameter SensorList is list().  //Optional parameter - list of science parts
    //If no list of science parts sent to the function, get a list of all science parts on the ship.
    
    Declare Local counter to 0.
    
    if SensorList:length = 0 {
        set SensorList to GetSensorList().
    }.

	For Sensor in SensorList {
        //only proceed is the experiment doesn't already have data
		if Sensor:getmodule("ModuleScienceExperiment"):hasdata {
            
            //If it the part is a science bay, we need to reset it.
            //Deleting the data will not allow the experiement to be run again 
            if Sensor:NAME = ("science.module") {
                if Sensor:getmodule("ModuleScienceExperiment"):hasevent("reset materials bay") {
                    Sensor:getmodule("ModuleScienceExperiment"):doevent("reset materials bay").
                    set counter to counter + 1.
                }
            }.

            //If it the part is a goo canister, we need to reset it.
            //Deleting the data will not allow the experiement to be run again
            if Sensor:NAME = ("GooExperiment") {
                if Sensor:getmodule("ModuleScienceExperiment"):hasevent("reset goo canister") {
                    Sensor:getmodule("ModuleScienceExperiment"):doevent("reset goo canister").
                    set counter to counter + 1.
                }
            }.

            if Sensor:getmodule("ModuleScienceExperiment"):hasaction("delete data"){  
                Sensor:getmodule("ModuleScienceExperiment"):doaction("delete data", true).
                set counter to counter + 1.
            }.

            if Sensor:getmodule("ModuleScienceExperiment"):hasaction("discard crew report"){  
                Sensor:getmodule("ModuleScienceExperiment"):doaction("discard crew report", true).
                set counter to counter + 1.
            }.
        }
    }.
    Return counter.
}.

Function GetAllScience {
//Runs all science experiments on the ship or from a list of parts.  
//Will only run 1 Goo and 1 Science Bay experiment if more than 1 in the list

	Declare Parameter SensorList is list().  //Optional parameter - list of science parts
    Declare Parameter Verbose is True.  //Optional parameter - if true prints messages

    //If no list of science parts sent to the function, get a list of all science parts on the ship.
    if SensorList:length = 0 {
        set SensorList to GetSensorList().
    }.

	Declare local DidGoo is false.
	Declare local DidBay is false.
	Declare local IsGoo is false.
	Declare local IsBay is false.
    Declare local Counter to 0.

    if Verbose {Print ("Running science experiments...").}
	For Sensor in SensorList {
        //only proceed is the experiment doesn't already have data
		if not Sensor:getmodule("ModuleScienceExperiment"):hasdata {
            //Find out if the current sensor is a Goo Container or Science Bay
			if Sensor:NAME = ("GooExperiment") set IsGoo to true.
			if Sensor:NAME = ("science.module") set IsBay to true.
                    //If not goo or bay go ahead and do experiment
		            if NOT IsGoo AND NOT IsBay {
        				if Verbose {print "     Running experiment on " + Sensor:NAME.}
                        Sensor:getmodule("ModuleScienceExperiment"):Deploy.
                        set Counter to Counter +1.                        
        			} else if IsGoo {
                        //only do 1 goo and check if the goo hasn't already been done.
        				if NOT DidGoo AND Sensor:getmodule("ModuleScienceExperiment"):HasEvent("observe mystery goo") {
        					if Verbose {print "     Running experiment on " + Sensor:NAME.}
                            Sensor:getmodule("ModuleScienceExperiment"):Deploy.
                            set Counter to Counter +1.
                            set DidGoo to true.
            				}	
			        } else if IsBay {
                        //only do 1 materials bay and check if it's already been done.
    				    if NOT DidBay AND Sensor:getmodule("ModuleScienceExperiment"):HasEvent("observe materials bay") {
                            if Verbose {print "     Running experiment on " + Sensor:NAME.}
                            Sensor:getmodule("ModuleScienceExperiment"):Deploy.
                            set Counter to Counter +1.
                            set DidBay to true.
                            }
			        }
			//set back to false inside HASDATA IF statement so it's inside for senson loop.
			set IsGoo to false.
			set IsBay to false.
		}
	}
    if Verbose {print ("Completed " + Counter + " available science experiments").}
}.
function TransmitAllScience {
//Transmits all science experiments that have data on the ship or from a list of sensors sent to the function

	Declare Parameter SensorList is list().  //Optional parameter - list of science parts to xmit data
    Declare Parameter WarpTime is True.  //Optional parameter - lets the user decide if warp while waiting    
    Declare Parameter Verbose is True.  //Optional parameter - if true prints messages
    Declare Parameter ChargePerMit is 10. //Optional parameter to know the charge per mit for antenna being used
    //Defaulted to 10 (Communotron 88) - the highest of the smaller sized antennas

    Declare Local Datalist to list().
    Declare Local Charge to 0.0.
    Declare Local ChargeTime to 0.0.
    Declare Local DataSize to 0.0.
    Declare Local TransSpeed to 5.0.
    Declare Local IsCharging to true.
    Declare Local WaitTime to 1.0.
    Declare Local WarpDelay to 0.0.
    Declare Local ChargeCapacity to 0.0.
    Declare Local Success to true.
    Declare Local DataName to " ".
    Declare Local AntList to GetDeployableAntList().

    print (" ").
    //Check if comms to KSC, else stop here and return false
    if HomeConnection:IsConnected = false {
        if Verbose {print ("****NO CONNECTION TO KSC - ABORTING TRANSMISSION ****").}
        return false.
    }

    //Deploy all antennas
    ExtendAllAnts(AntList).
    if Verbose {print ("Deploying antennas...").}
    wait 3.5.  //wait for antenna animation

    //If no list of science parts sent to the function, get a list of all science parts on the ship.
    if SensorList:length = 0 {
        set SensorList to GetSensorList().
    }.

    for Sensor in SensorList {
        
        //Check each sensor to see if has data.
        if Sensor:getmodule("ModuleScienceExperiment"):hasdata {
            set DataList to Sensor:getmodule("ModuleScienceExperiment"):data.
            
            //Get size and name of data
            //":data" returns a list, must step through list to get info
            for item in Datalist {
                set DataSize to item:dataamount.  
                set DataName to item:title.        
            }
            
            if Verbose {print "Transmitting " + DataName.}

            //Check if electric charge capacity of ship is enough to transmit this science
            set ChargeCapacity to ShipMaxCharge().
            if Verbose {print "     Current Charge: " + round(ship:electriccharge, 1).}
            if Verbose {print "     Needed Charge: " + ChargePerMit * DataSize.}
            if ChargeCapacity < (ChargePerMit * DataSize) + 2 {
                if Verbose {print ("     Vessel Electric Charge capacity not sufficient to transmit").}
                if Verbose {print ("     ****Aborting Transmission****").}
                set Success to false.
            } else {
                
                //Check if current charge is enough, if so xmit
                set Charge to ship:electriccharge.
                if Charge > ChargePerMit * DataSize + 2 {
                    set WaitTime to (DataSize / TransSpeed) + 2.
                    Sensor:getmodule("ModuleScienceExperiment"):transmit().
                    if Verbose {print "     Transmission time:  " + WaitTime + " seconds.".}
                    wait WaitTime. //wait while antenna xmits   
                    wait until Sensor:getmodule("ModuleScienceExperiment"):hasdata = false.
                    if Verbose {print ("     Transmission complete.").}    
                    if Verbose {print (" ").}                 
                } else {
                    if Verbose {print ("        Not enough charge.").} 
                    set ChargeTime to CalcChargeTime(DataSize, ChargePerMit).
                    set IsCharging to CheckCharging().
                    if Verbose {print "         Charging time is " + round(ChargeTime,1) + " seconds".}

                    //wait until there is enough charge, exit function if not charging
                    until Charge > ChargePerMit * DataSize + 2  or not (IsCharging) {
                        set ChargeTime to CalcChargeTime(DataSize, ChargePerMit).
                        set Charge to ship:electriccharge.       
                        set IsCharging to CheckCharging().                 
                        
                        //Time Warp and update charge time 
                        if WarpTime {
                            if ChargeTime > 60 {
                                set WarpDelay to ChargeTime - 10.
                                if Verbose {print ("        Warping...").}                            
                                set warp to 4.
                                wait WarpDelay.
                                if Verbose {print "         Charging time is " + round(ChargeTime - WarpDelay,1) + " seconds".}
                            } else if ChargeTime > 30 and ChargeTime <= 60 {
                                set WarpDelay to ChargeTime - 10.
                                if Verbose {print ("        Warping...").}
                                set warp to 3.
                                wait WarpDelay.
                            } else if ChargeTime > 15 and ChargeTime <= 30 {
                                set WarpDelay to ChargeTime - 5.
                                if Verbose {print ("        Warping...").}
                                set warp to 2.
                                wait WarpDelay.
                            } else {
                                set warp to 0.
                            }
                        }
                        wait 1. //wait during the until loop to update charge, chargetime, and checkcharging
                    }
                    set warp to 0.  //Just in case exited loop on ship not charging.

                    //exit function if ship not charging.
                    if not (IsCharging) {
                        if Verbose {print("****Not charging. Aborting ALL Transmissions****").}
                        set Success to false.
                        return Success.
                    //else the ship has the charge and we can xmit
                    } else {
                        set WaitTime to (DataSize / TransSpeed) + 2.
                        Sensor:getmodule("ModuleScienceExperiment"):transmit().
                        //wait 1.  //wait for antenna to deploy
                        if Verbose {print "     Transmission time:  " + WaitTime + " seconds.".}
                        wait WaitTime.  //wait while antenna xmits     
                        wait until Sensor:getmodule("ModuleScienceExperiment"):hasdata = false.      
                        if Verbose {print ("     Transmission complete.").}   
                        if Verbose {print (" ").}                    
                    }               
                }
            } 
        }
        //Wait until transmitting next sensor. 
        //There is a delay when an antenna is done before it can xmit again00
        Wait .5.  
    }. 
    Print ("All Science Data Transmitted").
    return Success.
}.

print("Loaded Library Standard_Lib.ks").