//This program uses a Hohmann transfer to calculate the burn node given a specific altitude and where on the 
//body (longitude) the ship should be after the burn. This is useful if you're trying to go to a synchronous orbit 
//and be over a specific spot on the body.  If going to a higher altitude it will reach the target longitude at 
//apoapsis, if lower it will be at periapsis. If your current orbit is really close to the synchronous altitude
//then this program may not work since it will take an long time (years, if ever) for the ship to reach the maneuver
//node.  This program will work on any body and at high inclinations. However, the ship must be in a circular
//orbit (as close to 0 eccentricity as possible).  You can run this while orbiting in the opposite direction of the
//body, but you'll immediately pass the target longitude as soon as you get there.  

//Example – Launch 1 satellite to a Kerbin synchronous orbit over the KSC.  Launch the satellite to a lower orbit 
//and then run this program to "SyncLong.ks(-74.558, 2863332)  -74.558 being the longitude of KSC. Then when you get
//to AP circularize the orbit. You could also launch to a higher orbit and drop the periapsis down to 2,863,332 
//meters but that would take more Dv.   

//Example - Launch multiple satellites on the same launcher and have them spread out evenly in synchronous orbit.  
//In this case you’ll need to enter a “resonant orbit” based on the number of satellites.  If you have 4 satellites
//you should start in an orbit that is 3/4 the orbital period of the synchronous orbit.  If you have 3 satellites 
//you would need a 2/3 resonant orbit*.  I use the mod “Resonant Orbit Calculator” to figure this out.  Once the 
//ship is in a circular orbit at the resonant orbit (3/4 is at 1,654,504.5m) then run the program to the synchronous
//altitude.  Run SyncLong.ks(-74.558, 286332) will create a node that will result in an elliptical orbit with 
//AP= 2,863,332 and keep the PE at 1,654,504.  When the launcher reaches AP, release your satellite and circularize
// it’s orbit.  Leave the launcher in the elliptical orbit and let it circle back around to the AP and release the 
//next satellite and circularize it’s orbit.  Repeat these steps for all remaining satellites. This will result in 
//all the satellites equally spaced out in a synchronous orbit with the first one located directly over the KSC. 

//If for some reason you want to start at an orbit that is higher than the synchronous altitude, change your 
//resonant orbit to 5/4 or 4/3 the synchronous orbital period and release the satellites at periapsis.  


//**************************************************************************************************************
//****These parameters must be passed into this program:
parameter TargetLongitude.  //enter both in decimal form, 
parameter TargetAltitude.   //- for west + for east

function ConvertLongitude {
//Converts a Longitude that is over 180+- to a real longitude measurement
    Declare Parameter LongToConvert.

    until LongToConvert <= 180 {
        set LongToConvert to LongToConvert - 360.
    }

    until LongToConvert >= -180 {
        set LongToConvert to LongToConvert + 360.
    }
    return LongToConvert.
}.

function SubLatLong {
//Subtracts 2 latitudes or longitudes from each other.  
//It goes around the circle from Latlong1 to LatLong2 counterclockwise
    Declare Parameter LatLong1.
    Declare Parameter LatLong2.
    set LatLongDiff to 0.

    if LatLong1 > LatLong2 {
            set LatLongDiff to 360 - LatLong1 + LatLong2.
        } else { 
            set LatLongDiff to LatLong2 - LatLong1.    
    }.
    return LatLongDiff.
}.

//MAIN PROGRAM START
// Calculate transfer DV to the target altitude
//See www.wikipedia.org/wiki/hohmann_transfer_orbit for details on the math
set OrbitRadius to ship:body:radius + ship:altitude.
set TargetAltOrbitRadius to ship:body:radius + TargetAltitude.
set DV to sqrt(ship:body:mu / OrbitRadius) * (sqrt((2 * TargetAltOrbitRadius) / (OrbitRadius + TargetAltOrbitRadius)) - 1).
set TransitTime to constant():PI * sqrt((OrbitRadius + TargetAltOrbitRadius)^3 / (8 * ship:body:mu)).

//Calculate the rotation of the body and the ship around it's orbit in degrees/second
set BodyRotationSpeedInDegrees to 360 / ship:body:rotationPeriod.
set ShipRotationSpeedInDegrees to 360 / orbit:period.
//The ClosingRate is the speed at which the planet spins relative to the ship 
set ClosingRate to ShipRotationSpeedInDegrees - BodyRotationSpeedInDegrees.
set ShipLong to ship:longitude.

//Calculate how far or ahead of the target longitude the node needs to be.
//We know the transit time so we can calculate how many degrees the body will roate during that time.
//After the transfer burn the ship will travel 180 degrees from periapsis to apoapsis
//If the ship is orbiting faster, subtract the body rotation from 180 degrees.
//If the ship is slower, then subtract 180 from the body rotation.  This gives you "NodeAngle"
if ClosingRate > 0 {    
    Set NodeAngle to 180 - (MOD(TransitTime, 21549.425) * BodyRotationSpeedInDegrees).
} else { //If the ship's speed is slower than the body, then the body will rotate more than 180
   Set NodeAngle to (MOD(TransitTime, 21549.425) * BodyRotationSpeedInDegrees) - 180.
}.

//find location of the node longitude
if ClosingRate > 0 {
    //Since the ship is orbiting faster than the body, need to subtract NodeAngle to burn before the TargetLongitude
    //Use MOD because we should never need more than 1 "lap" around the body to find the node.
    //1 lap is the time it takes for the ship to go 360 degrees around the same spot on the planet.
    set NodeLongitude to ConvertLongitude(TargetLongitude - NodeAngle).
    set ManeuverETA to MOD((SubLatLong(ShipLong, NodeLongitude))/ClosingRate, 360/ClosingRate).
} else {
    //Need to burn in front of Targetlongitude since the ship orbiting slower than the body, so add NodeAngle
    set NodeLongitude to ConvertLongitude(TargetLongitude + NodeAngle).
    set ManeuverETA to MOD((SubLatLong(NodeLongitude, ShipLong))/(-ClosingRate), 360/(-ClosingRate)).
}.
//Create the node and add it to the flight plan
set BurnNode to node(time:seconds + ManeuverETA, 0, 0, DV).
add BurnNode.
Print " ".
print "Calculated burn to " + TargetLongitude + " longitude at " + TargetAltitude + "m".
print "Transit Time = " + round(TransitTime) + "s".
print "Node Angle = " + round(NodeAngle, 2). 
print "Node Longitude = " + round(NodeLongitude, 2).
print "ETA until maneuver = " + round(ManeuverETA) + "s".
Print " ".