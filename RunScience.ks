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
//              - Must have a Experiment Storage Unit part (ESU or "Science Box") on the ship

run Standard_Lib.ks.

declare sensorlist to GetSensorList().
declare UserChoice to "none".
declare ESU to GetESU().
declare Done is False.

function ResetScreen{
    print ("Select an option: ") at(0,1).
    print ("1:  Run all science experiments") at(5,2).
    print ("2:  Collect all science") at(5,3).
    print ("3:  Clear all science experiments") at(5,4).
    print ("4:  End program") at(5,5).
}.

Clearscreen.
until Done {
    ResetScreen().
    set UserChoice to GetUserInput().
    if UserChoice = 1 {
        GetAllScience(sensorlist, False).
        Clearscreen.
        ResetScreen().
        print("Ran all available science experiments") at(0,7).
    } else if UserChoice = 2 {
        ESU:GETMODULE("ModuleScienceContainer"):doaction("collect all", true).
        Clearscreen.
        ResetScreen().
        print("Collected all available science") at(0,7).
    } else if UserChoice = 3 {
        Clearscreen.
        ResetScreen().
        print ("Reset " + ClearAllScience(sensorlist) + " experiments") at(0,7).

//Any key, not just "4" will end the program
    } else {
        set Done to True.
    }
}.
Clearscreen.