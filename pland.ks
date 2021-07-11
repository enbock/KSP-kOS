//
// Powered landing
//

if defined mainWasStarted {

set terminal:width to 48.
set terminal:height to 14.

set bottomAlt to ship:bounds:bottomaltradar.
local plandDone to false.
clearScreen.
print "Powered landing v2.1.0".
print "Ready.".
wait 0.
wait until ship:verticalspeed < startPowerlandWithVSpeed.
local wantSpeed to 0.0.
local onceUnderTime to false.

function deltaVHeight {
    //declare dvh to ship:deltaV:current / (accel() - g()) * (ship:verticalspeed * -1.0).
    declare dvh to (ship:verticalspeed * -1.0) / (accel() / g()).
    print "(!) Burn Alt  : " + round(dvh, 0) + "m     " at (2, 4).

    return dvh.
}
    
function burnHeight {
    if(ship:availablethrust <= 0 or ship:verticalspeed > 0) return 0.

	declare local surS to ship:velocity:surface:mag.
    declare local vs to ship:verticalspeed * -1.0.
    declare local a to accel() - g().

    if(surS > ship:deltaV:current or a < 0.0) {
        return deltaVHeight.
    }

    declare local hsToHeight to 0.
    if(surS - vs < vs * 0.75) set hsToHeight to ((surS - vs) / accel()) * vs.
    declare local bh to ((vs^2) / (2*a)) + hsToHeight.

    print "Burn Alt      : " + round(bh, 0)              + "m     " at (2, 4).
    print "H-Speed > Hgt : " + round(hsToHeight, 0) + "m     " at (2, 9).

    return bh.
}

function burnTime {
    if(ship:availablethrust <= 0) return 0.

	declare local vs to ship:velocity:surface:mag.

    declare local result to ((g() * timeToImpact()) + vs) / accel().

    print "Burntime      : " + round(result, 0)              + "s     " at (2, 4).
    print "Thrust        : " + round(accel(), 2) + "m/s       " at (2, 9).

    return result.
}

function timeToImpact {
    return bottomAlt / ship:verticalspeed * -1.0.
}

function isStartBurn {
    //if (ship:body:atm:exists) {
    //    return timeToImpact() <= burnTime().
    //}

    return bottomAlt < burnHeight().
}

function calculatePower {
    //if (ship:body:atm:exists) {
    //    return 1.0 / timeToImpact() * burnTime().
    //}
    return 1.0 / bottomAlt * burnHeight().
}

function isResetMode {
    //if (ship:body:atm:exists) {
    //    return timeToImpact() * 0.8 > burnTime().
    //}
    return bottomAlt * 0.8 > burnHeight().
}

set lt to 0.
WHEN not plandDone THEN {
    SET lt to lt + 1.
    if (lt > 2) {
        set bottomAlt to ship:bounds:bottomaltradar.
        set lt to 0.
        wait 0.
    }

    return true.
}

when not plandDone then {
    lock steering to ship:srfretrograde.
    set SAS to false.
    set brakes to ship:body:atm:exists.
}

when not plandDone and bottomAlt < 10 then {
    lock steering to up.
}

when not plandDone and bottomAlt < (ship:verticalspeed * -1) * 5.0 and not gear then {
    toggle gear.
}

when not plandDone and not onceUnderTime and isStartBurn() then { // breaking
    set wantSpeed to 1.0.
    set onceUnderTime to true.

    print "Throttle ^    : " + round(wantSpeed * 100, 0) + "%     " at (2, 12).
    lock throttle to wantSpeed.

    return true.
}
when not plandDone and onceUnderTime then { // landing
    if (ship:verticalspeed >= -0.1 or timeToImpact() < 0.05) {
        set wantSpeed to 0.
        set plandDone to true.
    } else {
        set wantSpeed to calculatePower().
    }

    if (isResetMode()) {
        set wantSpeed to 0.
        set onceUnderTime to false.
    }

    print "Throttle v    : " + round(wantSpeed * 100, 0) + "%     " at (2, 12).
    lock throttle to wantSpeed.

    return true.
}

when not plandDone and ship:availablethrust then {
    print "Time to impact: " + round(timeToImpact(), 0)            + "s     " at (2, 3).

    print "Alt           : " + round(bottomAlt, 0)                 + "m     " at (2, 5).
    
    print "S-Speed       : " + round(ship:velocity:surface:mag, 0) + "m/s     " at (2, 6).
    print "V-Speed       : " + round(ship:verticalspeed * -1.0, 0) + "m/s     " at (2, 7).

    return true.
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
print "Landed".
wait 5.0.

} else {
    copyPath("0:/boot/main", "1:/boot/main").
    run "boot/main".
}