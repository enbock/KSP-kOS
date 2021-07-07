//
// Powered landing
//

if defined mainWasStarted {

set bottomAlt to ship:bounds:bottomaltradar.
set power to 95.0. // only 95% max power (5% for "falling down")
local plandDone to false.
clearScreen.
print "Powered landing loaded. v1.0.10".
print "Ready.".
wait 0.
local wantSpeed to 0.0.
local onceUnderTime to false.

function g {
    return  ship:body:mu / (ship:body:radius + bottomAlt) ^ 2.
}
    
function burnTime {
    if(ship:availablethrust <= 0) return 0.

    declare local accel to 0.
	declare local vs to ship:velocity:surface:mag.

    if(ship:body:atm:exists) {
        set accel to (ship:availablethrust / ship:mass) - g().
        print "Thrust(ATM)   : " + round(accel, 2) + "m/s     " at (2, 10).
    } else {
        set accel to (ship:availablethrust / ship:mass) * g().
        print "Thrust        : " + round(accel, 2) + "m/s     " at (2, 10).
    }

    declare local result to ((g() * timeToImpact()) + vs) / accel.

    return result.
}

function timeToImpact {
    return bottomAlt / ship:verticalspeed * -1.0. //ship:velocity:surface:mag.
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

when not plandDone and ship:verticalspeed < startPowerlandWithVSpeed then {
    lock steering to ship:srfretrograde.
    set SAS to false.

    return true.
}

when not plandDone and bottomAlt < 10 then {
    lock steering to up.
}

when not plandDone and bottomAlt < (ship:verticalspeed * -1) * 5.0 and not gear then {
    toggle gear.
}

when not plandDone and not onceUnderTime and burnTime() >= timeToImpact() then { // breaking
    set wantSpeed to 1.0.
    set onceUnderTime to true.

    print "Throttle ^    : " + round(wantSpeed * 100, 0) + "%     " at (2, 12).
    lock throttle to wantSpeed.

    return true.
}
when not plandDone and onceUnderTime then { // landing
    set wantSpeed to (power / 100.0) / timeToImpact() * burnTime().
    
    local halfTTI to timeToImpact() * 0.5.
    if (halfTTI > 2.0 and burnTime() < halfTTI) {
        set wantSpeed to 0.
        set onceUnderTime to false.
    }
    if (ship:verticalspeed >= -0.1 or timeToImpact() < 0.01) {
        set wantSpeed to 0.
        set plandDone to true.
    }

    print "Throttle v    : " + round(wantSpeed * 100, 0) + "%     " at (2, 12).
    lock throttle to wantSpeed.

    return true.
}

when not plandDone then {
    print "Time to impact: " + round(timeToImpact(), 2)            + "s     " at (2, 3).
    print "Burn time     : " + round(burnTime(), 2)                + "s     " at (2, 4).
    
    print "S-Speed       : " + round(ship:velocity:surface:mag, 0) + "m/s     " at (2, 6).
    print "V-Speed       : " + round(ship:verticalspeed * -1.0, 0) + "m/s     " at (2, 7).
    print "Height        : " + round(bottomAlt, 2)                 + "m     " at (2, 8).

    return true.
}

wait until plandDone.
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