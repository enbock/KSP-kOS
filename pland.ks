//
// Powered landing
//

if defined mainWasStarted {

set terminal:width to 48.
set terminal:height to 14.

local bottomAlt to ship:bounds:bottomaltradar.
local plandDone to false.
clearScreen.
print "Powered landing v3.0.2".
print "Ready.".
wait 0.
wait until ship:verticalspeed < startPowerlandWithVSpeed.
local wantSpeed to 0.0.
local onceUnderTime to false.

local stopAirBreaksAt to 0.0.
local restartAirBreaksAt to 0.0.
local stopEnginesUnder to 0.7.
local avoidEnginesStopUnderTime to 15.

if(ship:body:name = "Kerbin") {
    //set stopAirBreaksAt to 45000.0.
    //set restartAirBreaksAt to 15000.0.
}

set burnHeight to 0.0.

function timeToImpactCalc {
    return bottomAlt / ship:verticalspeed * -1.0.
}
local timeToImpact to timeToImpactCalc().

function isStartBurnCalc {
    declare local vs to ship:verticalspeed * -1.0.
    return bottomAlt < burnHeight + vs.
}
local isStartBurn to isStartBurnCalc().

// itteration based burn height calculation

set lt to 0.
set lt2 to 0.
when not plandDone and lt = 0 then {
    set isStartBurn to isStartBurnCalc().
    set timeToImpact to timeToImpactCalc().

    if(ship:availablethrust <= 0 or ship:verticalspeed > 0) {
        set burnHeight to 0.
        return true.
    }

    print "Tank          : " + round(stage:resourcesLex["LiquidFuel"]:amount, 0) +" ("+ round(ship:deltaV:current, 0) + "m/s dV)     " at (2, 10).
    
	declare local surSpeed to ship:velocity:surface:mag.
    declare local vs to ship:verticalspeed * -1.0.
    declare local a to accel() - g().
    declare local speed to sqrt(vs^2 + surSpeed^2) / 3 + (vs / 3) * 2.

    if (accel() / g() > 3.0) {
        set a to a * ((1.0 / (accel() / g())) * 3.0).
    }

    if(speed > ship:deltaV:current or a < 0.0) {
        if(ship:body:atm:exists) {
            print "(!) ATM break : ...hope that ATM is breaking enough  " at (2, 4).
            set burnHeight to 0.
        } else {
            declare dvh to ship:deltaV:current / (accel() - g()) * (speed * -1.0). 
            set burnHeight to dvh.
            print "(!) Burn Alt  : " + round(dvh, 0) + "m                    " at (2, 4).
        }

        return true.
    }

    //declare local hsToHeight to 0.
    //if(surSpeed - vs < vs * 0.75) set hsToHeight to ((surSpeed - vs) / a) * vs.
    declare local bh to ((speed^2) / (2*a)).// + hsToHeight.

    print "Burn Alt      : " + round(bh, 0)              + "m     " at (2, 4).
    //print "H-Speed > Hgt : " + round(hsToHeight, 0) + "m     " at (2, 9).

    set burnHeight to bh.
    return true.
}

WHEN not plandDone and lt2 = 0 THEN {
    set bottomAlt to ship:bounds:bottomaltradar.

    return true.
}

when not plandDone and lt = 0 then {
    lock steering to ship:srfretrograde.
    set SAS to false.
    set brakes to ship:body:atm:exists.
}

when not plandDone and ship:body:atm:exists and ship:altitude <= stopAirBreaksAt and ship:altitude > restartAirBreaksAt and ship:velocity:surface:mag > 1000 then {
    set brakes to false.
}
when not plandDone and ship:body:atm:exists and ship:altitude <= restartAirBreaksAt then {
    set brakes to true.
}
when not plandDone and ship:body:atm:exists and ship:altitude < ship:body:atm:height then {
    set ag2 to false.
}

when not plandDone and bottomAlt < 10 then {
    lock steering to up.
}

when not plandDone and bottomAlt < (ship:verticalspeed * -1) * 7.0 and not gear then {
    toggle gear.
}

when not plandDone and lt = 0 and not onceUnderTime and isStartBurn then { // breaking
    set wantSpeed to 1.0.
    set onceUnderTime to true.

    print "Throttle ^    : " + round(wantSpeed * 100, 0) + "%     " at (2, 12).
    lock throttle to wantSpeed.

    return true.
}
when not plandDone and onceUnderTime and lt = 0  then { // landing
    if (ship:verticalspeed >= -0.1 or timeToImpact < 0.05) {
        set wantSpeed to 0.
        set plandDone to true.
    } else {
        if (burnHeight <= 0.0001) set wantSpeed to 0.
        else set wantSpeed to 1.0 / bottomAlt * burnHeight.
    }

    if (wantSpeed < stopEnginesUnder and avoidEnginesStopUnderTime < timeToImpact) {
        set wantSpeed to 0.
        set onceUnderTime to false.
    }

    print "Throttle v    : " + round(wantSpeed * 100, 0) + "%     " at (2, 12).
    lock throttle to wantSpeed.

    return true.
}

when not plandDone and ship:availablethrust and lt = 0 then {
    print "Time to impact: " + round(timeToImpact, 0)            + "s     " at (2, 3).

    print "Alt           : " + round(bottomAlt, 0)                 + "m     " at (2, 5).
    
    print "S-Speed       : " + round(ship:velocity:surface:mag, 0) + "m/s     " at (2, 6).
    print "V-Speed       : " + round(ship:verticalspeed * -1.0, 0) + "m/s     " at (2, 7).

    return true.
}

WHEN not plandDone THEN {
    set lt to lt + 1.
    set lt2 to lt2 + 1.
    if (lt > 3) {
        set lt to 0.
    }
    if (lt2 > 25) {
        set lt2 to 0.
    }

    return true.
}

wait until plandDone or ship:availablethrust <= 0.0.
lock throttle to 0.
wait 0.1.
unlock steering.
unlock throttle.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS on.
set brakes to false.

clearScreen.
wait 0.1.
if (ship:availablethrust <= 0.0) {
    print "Thrusters lost.".
} else {
    print "Landed.".
}
wait 5.0.

} else {
    copyPath("0:/boot/main", "1:/boot/main").
    run "boot/main".
}