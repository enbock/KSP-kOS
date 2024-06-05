//
// Powered landing
//

if defined mainWasStarted {

set terminal:width to 48.
set terminal:height to 14.

local plandDone to false.

local wantSpeed to 0.0.
local onceUnderTime to false.

local stopEnginesUnder to 0.7.
lock stopEngineAtMaxHeightDifference to ship:verticalspeed.
local avoidEnginesStopUnderTime to 5.
local AIRBREAKSused to false.

set burnHeight to 0.0.

clearScreen.
print "Powered landing v4.3.1".
print "Ready.".
wait 0.

set lt to 0.
set lt2 to 0.

WHEN not plandDone THEN {
    set lt to lt + 1.
    set lt2 to lt2 + 1.
    if (lt > 2) {
        set lt to 0.
    }
    if (lt2 > 10) {
        set lt2 to 0.
    }

    return true.
}

lock stageDeltaV to ship:deltaV:current. //SHIP:STAGEDELTAV(SHIP:STAGENUM):CURRENT.
lock tankAmount to stage:resourcesLex["LiquidFuel"]:amount.


when lt = 0 then {
    print "S-Speed       : " + round(ship:velocity:surface:mag, 0) + "m/s     " at (2, 6).
    print "V-Speed       : " + round(ship:verticalspeed * -1.0, 0) + "m/s     " at (2, 7).
    print "Tank          : " + round(tankAmount, 0) +"      " at (2, 10).

    if(not plandDone) return true.
}


wait until ship:verticalspeed < startPowerlandWithVSpeed and (ship:status = "SUB_ORBITAL" or ignoreFlightState = true or altitude < 20000).

print "         " at (0,4).
lock steering to ship:srfretrograde.
local bottomAlt to ship:bounds:bottomaltradar.

when stageDeltaV > 0 and lt = 0 then {
    if(not plandDone) return true.
} 

function timeToImpactCalc {
    return bottomAlt / ship:verticalspeed * -1.0.
}
local timeToImpact to timeToImpactCalc().

function isStartBurnCalc {
    return bottomAlt < burnHeight.
}
local isStartBurn to isStartBurnCalc().

when lt = 0 then {
    set isStartBurn to isStartBurnCalc().
    set timeToImpact to timeToImpactCalc().
    
    print "Time to impact: " + round(timeToImpact, 0)            + "s     " at (2, 3).
    print "Alt           : " + round(bottomAlt, 0)                 + "m     " at (2, 5).

    if(ship:availablethrust <= 0 or ship:verticalspeed > 0) {
        set burnHeight to 0.
        if(not plandDone) return true.
    }
    
	declare local surSpeed to ship:velocity:surface:mag.
    declare local vs to ship:verticalspeed * -1.0.
    declare local speed to sqrt(vs^2 + surSpeed^2).
    declare local burnTime to fuelBurnTime().

    declare local maxBurnHeight to burnTime * speed.
    set burnHeight to (speed^2) / (2*accel()).
    
    if(burnHeight > maxBurnHeight and bottomAlt > 250) {
        print "Tank-Burn Alt : " + round(maxBurnHeight, 0) + "m <-- " + round(burnHeight, 0) + "m               " at (2, 4).
        set burnHeight to maxBurnHeight.
    } else { 
        print "Burn Alt      : " + round(burnHeight, 0) + "m                          " at (2, 4).
    }

    if(not plandDone) return true.
}

WHEN lt2 = 0 THEN {
    set bottomAlt to ship:bounds:bottomaltradar.

    if(not plandDone) return true.
}

when not plandDone and lt = 0 then {
    set SAS to false.
    lock steering to ship:srfretrograde.
}

when not plandDone and lt = 0 and ship:body:atm:exists then {

    if (body:name = "Kerbin" and ship:altitude < 50000 and ship:altitude > 20000 and AIRBREAKSused) set brakes to false.
    else set brakes to ship:body:atm:exists.

    return true.
}

when not plandDone and ship:body:atm:exists and ship:altitude < ship:body:atm:height then {
    set ag2 to false.
}

when not plandDone and bottomAlt < 10 then {
    lock steering to up.
}

when not plandDone and bottomAlt < (ship:verticalspeed * -1) * 4.0 and not gear then {
    gear on.
    return true.
}

when lt = 0 and not onceUnderTime and isStartBurn then { // breaking
    set wantSpeed to 1.0.
    set onceUnderTime to true.

    print "Throttle ^    : " + round(wantSpeed * 100, 0) + "%     " at (2, 12).
    lock throttle to wantSpeed.

    if(not plandDone) return true.
}

when onceUnderTime and lt = 0  then { // landing
    if ((ship:verticalspeed >= -0.1 or timeToImpact < 0.05) and bottomAlt < 10) {
        set wantSpeed to 0.
        set plandDone to true.
    } else {
        if (burnHeight <= 0.0001) set wantSpeed to 0.
        else set wantSpeed to 1.0 / bottomAlt * burnHeight.
    }

    declare local heightDiffernce to bottomAlt - burnHeight.

    if (
        (
            wantSpeed < stopEnginesUnder or 
            stopEngineAtMaxHeightDifference < heightDiffernce
        ) and avoidEnginesStopUnderTime < timeToImpact
    ) {
        set wantSpeed to 0.
        set onceUnderTime to false.
    }

    print "Throttle v    : " + round(wantSpeed * 100, 0) + "%     " at (2, 12).
    lock throttle to wantSpeed.

    if(not plandDone) return true.
}

wait until plandDone or ship:availablethrust <= 0.0.
lock throttle to 0.
wait 0.1.
unlock steering.
unlock throttle.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS on.

clearScreen.
wait 0.1.
if (ship:availablethrust <= 0.0) {
    print "Thrusters lost.".
} else {
    print "Landed.".
    set brakes to false.
}
wait 5.0.

} else {
    copyPath("0:/boot/main", "1:/boot/main").
    run "boot/main".
}