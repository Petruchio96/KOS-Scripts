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

    } else {
        set Done to True.
    }
}.
Clearscreen.