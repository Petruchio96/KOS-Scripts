
//I got most of this code from somebody else... 
//but I can't remember who (sorry). I made some modifications to improve and make it run on "any" ship
//Must have a manuever node already on the flight plan.  It will point to the node, warp if there's time,
//burn hard, dial down the throttle for percision, finish the burn and the delete the node.

Parameter WillWarp is True.  //Optional parameter to warp to the manuever node

Declare Local n TO NEXTNODE.
Declare Local a0 to 0.0.
Declare Local a1 to 0.0.
Declare Local eIsp to 0.0.
Declare Local Ve to 0.0.
Declare Local final_mass to 0.0.
Declare Local t to 0.0.
Declare Local start_time to 0.0.
Declare Local end_time to 0.0.
Declare Local my_engines to List().

// Point at the node.
SAS off.
LOCK STEERING TO n:BURNVECTOR.
WAIT UNTIL VANG(SHIP:FACING:VECTOR, n:BURNVECTOR) < 2.

// Get initial acceleration.
SET a0 TO ship:maxthrust / mass.  //added "ship:" because of lazyglobal off

// In the pursuit of a1...
// What's our effective ISP?
//SET eIsp TO 0.  //not needed since delared up top
LIST engines IN my_engines.
FOR eng IN my_engines {
SET eIsp TO eIsp + eng:maxthrust / ship:maxthrust * eng:isp. 
}

// What's our effective exhaust velocity?
SET Ve TO eIsp * 9.82.

// What's our final mass?
SET final_mass TO mass*CONSTANT():e^(-1*n:BURNVECTOR:MAG/Ve).

// Get our final acceleration.
SET a1 TO maxthrust / final_mass.
// All of that ^ just to get a1..

// Get the time it takes to complete the burn.
SET t TO n:BURNVECTOR:MAG / ((a0 + a1) / 2).

// Set the start and end times.
SET start_time TO TIME:SECONDS + n:ETA - t/2.
SET end_time TO TIME:SECONDS + n:ETA + t/2.

//Warp to 10 seconds before the burn time
If WillWarp {
    warpto(start_time - 10).
}

// Execute the burn.
WAIT UNTIL TIME:SECONDS >= start_time.
LOCK throttle TO 1.
//WAIT UNTIL TIME:SECONDS >= end_time - 0.2.  (OLD)
//Instead, wait until there is just a little deltaV left, then stop
WAIT UNTIL ABS(n:BURNVECTOR:MAG) < 5.
LOCK throttle TO 0.

// Finish the burn and lower throttle
if ABS(n:BURNVECTOR:MAG) >= .1 {
    WAIT UNTIL VANG(SHIP:FACING:VECTOR, n:BURNVECTOR) < 2.
    until ABS(n:BURNVECTOR:MAG) < .1 {
        lock throttle to 0.1.
    }
}
unlock steering.
remove n.
set throttle TO 0.
