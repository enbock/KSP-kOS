//
// Gandur's Start script.
//

global uturnStartAt to 10.
global targetOrbit to 100000.
global targetTwr to 2.
global maxVerticalSpeed to 400.0.
global minVerticalSpeed to 50.
global maxQ to 0.2.
global minTimeToApoapsis to 15.0.
global ag1DeployAt to 68000.
global ag2DeployAt to 74000.
global powerLandFluel to 100.

clearscreen.
global targetAngle to 0.0.
global startInFlight to ship:velocity:surface:mag > 100.
global orbitDone to startInFlight and isApoapsisReached().

if (body:name = "Mun") set targetOrbit to 30000.

if (not startInFlight) {
    SAS on.
    if(body:name = "Kerbin") lock throttle to 1.0.
    print "Wait for flight start.".
}
function twr {
    SET g TO body:mu / body:radius^2.
    return ship:availableThrust * throttle / ship:mass * g / 100.0.
}

global apoapsisReached to false.
function isApoapsisReached {
    set apoapsisReached to apoapsisReached or ship:apoapsis >= targetOrbit.
    return apoapsisReached.
}

local corePos to 5.
WHEN not orbitDone and not isApoapsisReached() and not startInFlight THEN {
    PRINT "TWR    : " + round(twr(), 2) + "    " at (0, corePos).
    PRINT "L-Fuel : " + round(stage:resourcesLex["LiquidFuel"]:amount, 0) + "    " at (0, corePos + 1).
    PRINT "S-Fuel : " + round(stage:resourcesLex["SolidFuel"]:amount, 0) + "    " at (0, corePos + 2).
    
    PRINT "Speed  : " + round(ship:velocity:orbit:mag, 1) + "m/s     " at (20, corePos).
    PRINT "V-Speed: " + round(ship:verticalspeed, 1) + "m/s     " at (20, corePos + 1).
    PRINT "H-Speed: " + round(ship:groundspeed, 1) + "m/s     " at (20, corePos + 2).

    local orbVel to sqrt(body:mu / (body:radius + targetOrbit)) - ship:velocity:orbit:mag.
    PRINT "Delta-V: " + round(orbVel, 1) + "m/s  " at (0, corePos + 3).
    PRINT "Rest   : " + round(ship:deltaV:current - orbVel, 1) + "m/s    " at (20, corePos + 3).

    return true.
}

if (not startInFlight) {
    wait until ship:verticalspeed > 2.
    print "Flight startet.".

    SAS off.
    wait 0.
}

when not orbitDone and ship:altitude > ag1DeployAt and not ag1 then {
    lock throttle to 0.
    wait 0.2.
    toggle ag1.
    wait 0.2.
    return false.
}

when body:name = "Kerbin" and ship:altitude > ag2DeployAt and not ag2 then {
    set ag2 to true.
    return true.
}
when body:name = "Kerbin" and ship:altitude < ag2DeployAt and ag2 then {
    set ag2 to false.
    return true.
}
when body:name <> "Kerbin" and alt:radar > 100 and gear then {
    set gear to false.
}

local burnPos to 15.
print "--== Burning ==--" at (0, burnPos).
print "Multipliers:" at (2, burnPos+3).
local startWithSolid to stage:resourcesLex["SolidFuel"]:amount > 1.
when not orbitDone and 
    not startInFlight and 
    stage:resourcesLex["LiquidFuel"]:amount <= (0.025+powerLandFluel) and 
    stage:resourcesLex["SolidFuel"]:amount <= 0.025 
    then {

    print "Stage " + ship:stagenum + " at " + round(alt:radar, 2) at (2, burnPos + 1).
    lock throttle to 0.
    set oldThrottle to 1.0.
    set thrusterLimit to 100.0.
    wait 0.1.
    stage.
    if(not startWithSolid) wait 2.
    set startWithSolid to false. // only first separation has solid fuel
    
    return true.
}

local oldThrottle to 1.0.
local thrusterLimit to 100.0.
when not orbitDone and not startInFlight then {
    if(isApoapsisReached()) {
        print "Throttle: apoapsis reached         " at (2, burnPos + 2).
        
        lock throttle to 0.
        list engines in MyList.
        FOR e IN MyList {  set e:THRUSTLIMIT to 100. }

        wait 0.
        unlock throttle.
        SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
        return false.
    }

    local newThrottle to 0.0.

    if(not isApoapsisReached()) {
        set newThrottle to 1.0. 

        local vertPercent to min(1.0, max(0.0, 1.0 - ((1.0 / maxVerticalSpeed * ship:verticalspeed) - 1.0))).
        print "vertical           : " + round(vertPercent * 100.0, 0) + "% "  at (4, burnPos + 4).
        set newThrottle to newThrottle * vertPercent. 

        local vertAccel to maxVerticalSpeed * cos(90.0 / targetOrbit * ship:apoapsis).
        if (vertAccel < minVerticalSpeed) set vertAccel to minVerticalSpeed.
        local apoPercent to min(1.0, max(0.0, 1.0 - ((1.0 / vertAccel * ship:verticalspeed) - 1.0))).
        print "apoapsis           : " + round(apoPercent * 100.0, 0) + "% "  at (4, burnPos + 5).
        print "(" + round(vertAccel, 0) + "m/s vertical)    " at (30, burnPos + 5). 
        set newThrottle to newThrottle * apoPercent. 

        local pressPercent to min(1.0, max(0.0, 1.0 - ((1.0 / maxQ * ship:dynamicpressure) - 1.0))).
        print "pressure           : " + round(pressPercent * 100.0, 0) + "% " at (4, burnPos + 6).
        print "(" + round(ship:dynamicpressure, 4) + "atm)      " at (30, burnPos + 6). 
        set newThrottle to newThrottle * pressPercent.

        local twrPercent to min(1.0, max(0.0, 1.0 - ((1.0 / targetTwr * twr()) - 1.0))).
        print "trust to wait ratio: " + round(twrPercent * 100.0, 0) + "% "  at (4, burnPos + 7).
        set newThrottle to newThrottle * twrPercent. 

        local atPercent to 0.0.
        local minTime to minTimeToApoapsis.
        if (eta:apoapsis < minTime) {
            set atPercent to max(0.0, 1.0 - (1.0 / minTime * eta:apoapsis)).
        }
        print "time to apoapsis   : " + round(atPercent * 100.0, 0) + "% "  at (4, burnPos + 8).
        set newThrottle to newThrottle + atPercent. 
    }

    set newThrottle to (oldThrottle * 3.0 + newThrottle) / 4.0.
    set oldThrottle to newThrottle.

    lock throttle to newThrottle.
    print "Throttle: " + round(newThrottle * 100.0, 0) + "%  " at (2, burnPos + 2).

    set thrusterLimit to max(0.5, (thrusterLimit * 15.0 + newThrottle * 100.0) / 16.0).
    list engines in MyList.
    FOR e IN MyList {  set e:THRUSTLIMIT to thrusterLimit. }
    print "Limit: " + round(thrusterLimit, 0) + "%  " at (20, burnPos + 2).

    wait 0.
    return true.
}

local mySteering to heading(90, 90, -90).
if (not startInFlight) LOCK steering TO mySteering.
local steeringPos to 10.
print "--== STEERING ==--" at (0, steeringPos).
WHEN not orbitDone and not startInFlight THEN {
    local speed to SHIP:VELOCITY:SURFACE:MAG.
    local apoPercent to 1.0 / targetOrbit * ship:apoapsis.
    local angle to 90.0 - ((90.0 - targetAngle) * apoPercent).
    print "Speed: " + round(speed, 1) + "m/s" at (2, steeringPos + 1).

    if(isApoapsisReached()) {
        print "Steering: apoapsis reached          "  at (2, steeringPos + 2).
        lock steering to ship:prograde.
        return false.
    }
    
    if(speed < uturnStartAt) {
        set mySteering TO heading(90, 90, -90).
    } else {
        set mySteering TO heading(90, angle, -90).
        print "Steering:" + round(angle, 2) at (2, steeringPos + 2).
    }
    wait 0.
    return true.
}

print "Ready.".
wait until apoapsisReached or startInFlight.
//core:part:getmodule("kOSProcessor"):doevent("Close Terminal").
wait 0.5.

if (not orbitDone) {
    clearScreen.
    print "Orbital mode.".
    print "Wait for manouver...".

    set needVelocity to sqrt(body:mu / (body:radius + targetOrbit)).
    LOCAL timeToApoapsis to time:seconds + eta:apoapsis.
    LOCAL velcityAtAposis to velocityAt(ship, timeToApoapsis):ORBIT:MAG.
    set restVelocity to needVelocity - velcityAtAposis.

    set orbitalNode to node(timeToApoapsis, 0, 0, restVelocity).
    add orbitalNode.
}

set orbitDone to true.
run exec.