//
// Powered landing
//

if defined mainWasStarted {

set terminal:width to 48.
set terminal:height to 14.

set bottomAlt to ship:bounds:bottomaltradar.
local plandDone to false.
clearScreen.
print "Powered landing v2.3.1".
print "Ready.".
wait 0.
wait until ship:verticalspeed < startPowerlandWithVSpeed.
local wantSpeed to 0.0.
local onceUnderTime to false.

local stopAirBreaksAt to 0.0.
local restartAirBreaksAt to 0.0.

if(ship:body:name = "Kerbin") {
    set stopAirBreaksAt to 45000.0.
    set restartAirBreaksAt to 15000.0.
}

set burnHeight to 0.0.

function timeToImpact {
    return bottomAlt / ship:verticalspeed * -1.0.
}

function isStartBurn {
    declare local vs to ship:verticalspeed * -1.0.
    return bottomAlt < burnHeight + vs.
}

function calculatePower {
    if (burnHeight <= 0.0001) return 0.
    return 1.0 / bottomAlt * burnHeight.
}

function isResetMode {
    return bottomAlt * 0.75 > burnHeight.
}

// itteration based burn height calculation
when not plandDone then {
    if(ship:availablethrust <= 0 or ship:verticalspeed > 0) {
        set burnHeight to 0.
        return true.
    }

	declare local surS to ship:velocity:surface:mag.
    declare local vs to ship:verticalspeed * -1.0.
    declare local a to accel() - g().

    if(surS > ship:deltaV:current or a < 0.0) {
        if(ship:body:atm:exists) {
            print "(!) only " + round(ship:deltaV:current, 0) + "m/s left. Left hope for atmosphere!" at (2, 4).
            set burnHeight to 0.
        } else {
            declare dvh to ship:deltaV:current / (accel() - g()) * (ship:verticalspeed * -1.0). 
            set burnHeight to dvh.
            print "(!) Burn Alt  : " + round(dvh, 0) + "m     " at (2, 4).
        }

        return true.
    }

    declare local hsToHeight to 0.
    if(surS - vs < vs * 0.75) set hsToHeight to ((surS - vs) / a) * vs.
    declare local bh to ((vs^2) / (2*a)) + hsToHeight.

    print "Burn Alt      : " + round(bh, 0)              + "m     " at (2, 4).
    print "H-Speed > Hgt : " + round(hsToHeight, 0) + "m     " at (2, 9).

    set burnHeight to bh.
    return true.
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

when not plandDone and ship:body:atm:exists and ship:altitude <= stopAirBreaksAt and ship:altitude > restartAirBreaksAt  and ship:velocity:surface:mag > 1000 then {
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
set brakes to false.

clearScreen.
wait 0.1.
print "Landed".
wait 5.0.

} else {
    copyPath("0:/boot/main", "1:/boot/main").
    run "boot/main".
}