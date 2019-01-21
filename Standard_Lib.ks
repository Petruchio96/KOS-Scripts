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
//Returns the time needed for a ship to increase it's charge by a specific charge amount
    Declare Parameter ChargeNeeded.  //Required parameter - the amount of charge needed to increase

    Declare Local Charge1 to 0.0.
    Declare Local Charge2 to 0.0.
        
    set Charge1 to ship:electriccharge.
        wait 0.5.
    set Charge2 to ship:electriccharge.

    return ChargeNeeded / ((Charge2 - Charge1) / 0.5).
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

function GetESUlist {
//Returns a list of 1 ESU part (first it finds) or a blank list if none on ship.
    Declare Local plist to List().
    Declare Local NumInList to 0.

    Set plist to ship:PARTSNAMED("ScienceBox").
    if plist:length = 0 {
        print("No ESU on this ship").
        Return plist.
    }.
    
    //Remove any extra ESUs and only return the 1st if found
    If plist:length > 1 {
        set NumInList to plist:length.
        From {Local I is NumInList.} UNTIL I = 1 STEP {set I to I - 1.} do {
            plist:remove(I-1).
        }
    }.
    Return plist.    
}. 

function GetDeployableAntList {
//Returns a list of Deployable Antennas
    Declare Local AntList to list().
    Declare Local plist to ship:parts.
    
        for item in plist {
            if item:hasmodule("ModuleDeployableAntenna") {
                AntList:add(item).
            }
        }
    return AntList.
}. 

function GetNonDeployableAntList {
//Returns a list of Non-Deployable Antennas
    Declare Local AntList to list().
    Declare Local plist to ship:parts.

        for item in plist {
            if NOT item:hasmodule("ModuleDeployableAntenna") AND NOT item:hasmodule("ModuleCommand") AND item:hasmodule("ModuleDataTransmitter"){
                AntList:add(item).
            }
        }.
    return AntList.
}.

function ExtendAllAnts {
//Extend all Deployable Antennas or deploy a list of antennas
    Declare Parameter AntList is list().  //Optional paramenter - list of antennas to deploy

    if AntList:length = 0 {
        set AntList to GetDeployableAntList().
    }.
    For Ant in AntList {
        if Ant:getmodule("ModuleDeployableAntenna"):hasaction("extend antenna"){
            Ant:getmodule("ModuleDeployableAntenna"):doaction("extend antenna", true).
        }
    }
}.

function RetractAllAnts {
//Retract all Deployable Antennas or deploy a list of antennas
    Declare Parameter AntList is list().  //Optional paramenter - list of antennas to retract

    if AntList:length = 0 {
        set AntList to GetDeployableAntList().
    }.
    For Ant in AntList {
        if Ant:getmodule("ModuleDeployableAntenna"):hasaction("retract antenna"){
            Ant:getmodule("ModuleDeployableAntenna"):doaction("retract antenna", true).
        }
    }
}.

function GetSensorList {
//Returns a list of all science parts
    Declare Local SensorList to list().
    Declare Local plist to ship:parts.
    
        for item in plist {
            if item:hasmodule("ModuleScienceExperiment") {
                SensorList:add(item).
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
            
            if Sensor:NAME = ("GooExperiment") {
            //If it the part is a goo canister, we need to reset it.
            //Deleting the data will not allow the experiement to be run again
                if Sensor:getmodule("ModuleScienceExperiment"):hasevent("reset goo canister") {
                    Sensor:getmodule("ModuleScienceExperiment"):doevent("reset goo canister").
                    set counter to counter + 1.
                }
            } else if Sensor:NAME = ("science.module") {
            //If it the part is a science bay, we need to reset it.
            //Deleting the data will not allow the experiement to be run again
                if Sensor:getmodule("ModuleScienceExperiment"):hasevent("reset materials bay") {
                    Sensor:getmodule("ModuleScienceExperiment"):doevent("reset materials bay").
                    set counter to counter + 1.
                }               
            } else if Sensor:getmodule("ModuleScienceExperiment"):hasaction("delete data"){  
                Sensor:getmodule("ModuleScienceExperiment"):doaction("delete data", true).
                set counter to counter + 1.
            } else if Sensor:getmodule("ModuleScienceExperiment"):hasaction("discard crew report"){  
                Sensor:getmodule("ModuleScienceExperiment"):doaction("discard crew report", true).
                set counter to counter + 1.
            } else if Sensor:getmodule("ModuleScienceExperiment"):hasaction("discard data"){ 
            //Discard data is needed for the Atmospheric Fluid Spectro-Variometer - others?
                Sensor:getmodule("ModuleScienceExperiment"):doaction("discard data", true).
                set counter to counter + 1.
            } 
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
    return SensorList.
}.

function TransmitAllScience {
//Transmits all science experiments that have data on the ship or from a list of sensors sent to the function
//Returns True only if all science is successfuly transmitted, else returns False.

	Declare Parameter SensorList is list(). //Optional parameter - list of science parts to xmit data
    Declare Parameter WarpTime is True.     //Optional parameter - lets the user decide if warp while waiting    
    Declare Parameter Verbose is True.      //Optional parameter - if true prints messages
    Declare Parameter ChargePerMit is 24.   //Optional parameter to know the charge per mit for antenna being used
                                            //Defaulted to 24 (RA-2 Relay) - the highest of all the antennas
    Declare Parameter TransSpeed is 2.86.   //Optional Parameter to know the antenna transmission speed
                                            //Defaulted to 2.86, (RA-2 Relay) - the slowest antenna

    Declare Local Datalist to list().
    Declare Local Charge to 0.0.
    Declare Local ChargeTime to 0.0.
    Declare Local DataSize to 0.0.    
    Declare Local IsCharging to true.
    Declare Local WaitTime to 1.0.
    Declare Local WarpDelay to 0.0.
    Declare Local ChargeCapacity to 0.0.
    Declare Local Success to true.
    Declare Local DataName to " ".
    Declare Local ReserveCharge to 0.05.                //Minimum % no to let ship charge drop below
    Declare Local AntList to GetDeployableAntList().

    //Must have antennas to transmit data
    if AntList:length = 0 {
        set Antlist to GetNonDeployableAntList().
        if AntList:length = 0 {        
            if Verbose {print ("****NO ANTENNAS ON SHIP - ABORTING TRANSMISSION ****").}
            return false.
        }
        //Must reset Antlit to a deployable list, otherwise ExtendAllAnts() will crash.
        Set AntList to GetDeployableAntList().
    }.

    if Verbose {print (" ").}
    //Check if comms to KSC, else stop here and return false
    if HomeConnection:IsConnected = false {
        if Verbose {print ("****NO CONNECTION TO KSC - ABORTING TRANSMISSION ****").}
        return false.
    }.

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
            if ChargeCapacity < (ChargePerMit * DataSize) + (ChargeCapacity * ReserveCharge) {
                if Verbose {print ("     Vessel Electric Charge capacity not sufficient to transmit").}
                if Verbose {print ("     ****Aborting Transmission****").}
                set Success to false.
            } else {
                
                //Check if current charge is enough while maintaining reserve charge
                set Charge to ship:electriccharge.
                if Charge > (ChargePerMit * DataSize) + (ChargeCapacity * ReserveCharge) {
                    set WaitTime to (DataSize / TransSpeed) + 2.
                    Sensor:getmodule("ModuleScienceExperiment"):transmit().
                    if Verbose {print "     Transmission time:  " + round(WaitTime, 1) + " seconds.".}   
                    wait until Sensor:getmodule("ModuleScienceExperiment"):hasdata = false.
                    wait WaitTime. //wait while antenna xmits
                    if Verbose {print ("     Transmission complete.").}    
                    if Verbose {print (" ").}                 
                } else {
                    if Verbose {print ("        Not enough charge.").} 
                    set IsCharging to CheckCharging().
                    //add 0.005 or to make sure the Charge time gets the ship charged slightly above the ReserveCharge
                    set ChargeTime to CalcChargeTime((DataSize * ChargePerMit) + (ChargeCapacity * (ReserveCharge + 0.005)) - Charge).
                    if Verbose {print "         Charging time is " + round(ChargeTime,1) + " seconds".}

                    // //wait until there is enough charge, exit function if not charging
                    until Charge > ((ChargePerMit * DataSize) + ChargeCapacity * ReserveCharge) or not (IsCharging) {
                        WarpTo(time:seconds + ChargeTime).
                        wait ChargeTime + 1.
                        set ChargeTime to CalcChargeTime((DataSize * ChargePerMit) + (ChargeCapacity * (ReserveCharge + 0.005)) - Charge).
                        set IsCharging to CheckCharging().
                        set Charge to ship:electriccharge.
                    }

                    //exit function if ship not charging.
                    if not (IsCharging) {
                        if Verbose {print("****Not charging. Aborting ALL Transmissions****").}
                        return false.
                    //else the ship has the charge and we can xmit
                    } else {
                        set WaitTime to (DataSize / TransSpeed) + 2.
                        Sensor:getmodule("ModuleScienceExperiment"):transmit().
                        if Verbose {print "     Transmission time:  " + round(WaitTime, 1) + " seconds.".}
                        wait until Sensor:getmodule("ModuleScienceExperiment"):hasdata = false. 
                        wait WaitTime.  //wait while antenna xmits          
                        if Verbose {print ("     Transmission complete.").}   
                        if Verbose {print (" ").}                    
                    }               
                }
            } 
        }
        //Wait until transmitting next sensor. 
        //There is a delay when an antenna is done before it can xmit again.
        Wait .5.  
    }. 
    if Verbose {Print ("All Science Data Transmitted").}
    Return Success.
}.

print("Loaded Library Standard_Lib.ks").