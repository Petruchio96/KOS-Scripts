//This script is used to make it easier to quickly run science experiments and crew reports,store the
//science in an "Experiment Storage Unit" (ESU) and reset the experiements.  Clearing all science is 
//useful if you have already run the experiment and have stored the science in the ESU.  "Collecting 
//all science" will not store duplicate science data, and for Science Bays and Goo Canisters it will 
//reset them so they can be run again.  It will delete science data on experiments that can be 
//repeatedly run, like thermometers.  This allows you to repeatedly press 1-2-3 to quickly run all 
//science experiments and gather all the data. I use this script while descending through an
//atmosphere so I can quickly get all the sceince at different altitudes and bioms.  I don't have to 
//click on each part or check to see if I've already got the data before running a goo or science bay.

//Requirements  - must have "Standard_Lib.ks" file in the same directory
//              - For option #2 to function, an Experiment Storage Unit part (ESU or "Science Box") on 
//                the ship. The program will inform you of this.  Options 1 and 3 will still function

run Standard_Lib.ks.

declare sensorlist to GetSensorList().
declare UserChoice to "none".
declare ESUList to GetESUlist().
declare Done is False.

function ResetScreen{
    Clearscreen.
    print ("Select an option: ") at(0,1).
    print ("1:  Run all science experiments") at(5,2).
    print ("2:  Collect all science") at(5,3).
    print ("3:  Clear all science experiments") at(5,4).
    print ("4:  End program") at(5,5).
    print ("                                        ") at(0,7).
}.

ResetScreen().
until Done {
    set UserChoice to GetUserInput().
    if UserChoice = 1 {
        ResetScreen().
        GetAllScience(sensorlist, False).
        print("Conducted " + sensorlist:length + " science experiments") at(0,7).
    } else if UserChoice = 2 {
        if ESUList:length = 0 {
            ResetScreen().
            print("No ESU on this ship, no data stored.") at(0,7).            
        } else {
            ESUList[0]:GETMODULE("ModuleScienceContainer"):doaction("collect all", true).
            ResetScreen().
            print("Collected all available science") at(0,7).                        
        }
    } else if UserChoice = 3 {
        ResetScreen().
        print ("Reset " + ClearAllScience(sensorlist) + " experiments") at(0,7).

    } else if UserChoice = 4 {
        set Done to True.
    }
}.
Clearscreen.