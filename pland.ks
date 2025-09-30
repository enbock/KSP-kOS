//
// Powered landing
//
//core:part:getmodule("kOSProcessor"):doevent("Open Terminal").

global function g {
    return  ship:body:mu / (ship:body:radius + ship:bounds:bottomaltradar) ^ 2.
}

global function shipPitch {
  return 90 - vang(ship:up:vector, ship:facing:forevector).
}

global function gravitationForce {
    return ship:mass * g().
}

global function shipOrientedGravityForce {
    return  gravitationForce() * (1 / 90 * shipPitch()).
}

global function shipForce {
    return ship:availableThrust - shipOrientedGravityForce().
}

global function accel {
    return (shipForce() / ship:mass).
}

global function twr {
    return (accel() / g()) * throttle.
}

global function fuelBurnTime {
    local flow to 0.
    list engines in engineList.
    FOR e IN engineList { 
        set flow to flow + e:MAXFUELFLOW.
    }
    return stage:resourcesLex["LiquidFuel"]:amount / flow.
}

local gOutput to gui(300, 400).
set gOutput:x to -150.
set gOutput:y to -400.
set gOutput:draggable to true.

local labelSSpeed to gOutput:addlabel("S-Speed :").
local labelVSpeed to gOutput:addlabel("V-Speed :").
local labelTank to gOutput:addlabel("Tank ").
local labelTimeImpact to gOutput:addlabel("Time to impact:").
local labelAlt to gOutput:addlabel("Alt :").
local labelBurnAlt to gOutput:addlabel("").
local labelThrottle to gOutput:addlabel("").
local labelStatus to gOutput:addlabel("").

local plandDone to false.

local wantSpeed to 0.0.
local onceUnderTime to false.

local stopEnginesUnder to 0.7.
lock stopEngineAtMaxHeightDifference to ship:verticalspeed.
local avoidEnginesStopUnderTime to 5.
local AIRBREAKSused to false.

set burnHeight to 0.0.

set labelStatus:text to "Powered landing v5.0.2".

set gOutput:addbutton("STOP"):onclick to  {
    set plandDone to true.
}.
gOutput:show().

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
    set labelSSpeed:text to "S-Speed: " + round(ship:velocity:surface:mag, 0) + "m/s     ".
    set labelVSpeed:text to "V-Speed: " + round(ship:verticalspeed * -1.0, 0) + "m/s     ".
    set labelTank:text to "Tank: " + round(tankAmount, 0) +"      ".

    if(not plandDone) return true.
}

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
    
    set labelTimeImpact:text to "Time to impact: " + round(timeToImpact, 0) + "s     ".
    set labelAlt:text to "Alt : " + round(bottomAlt, 0) + "m     ".

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
    set labelBurnAlt:text to "Tank-Burn Alt: " + round(maxBurnHeight, 0) + "m <-- " + round(burnHeight, 0) + "m".
        set burnHeight to maxBurnHeight.
    } else { 
    set labelBurnAlt:text to "Burn Alt: " + round(burnHeight, 0) + "m".
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

    set labelThrottle:text to "Throttle ^    : " + round(wantSpeed * 100, 0) + "%     ".
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

    set labelThrottle:text to "Throttle v    : " + round(wantSpeed * 100, 0) + "%     ".
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

gOutput:hide().
wait 0.1.
if (ship:availablethrust > 0.0) {
    set brakes to false.
}
