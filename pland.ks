//
// Powered landing
//

set orientAt to 3. // 3 burn time before touch down
set bottomAlt to ship:bounds:bottomaltradar.
local plandDone to false.
local touchDownHeight to 0.5.
clearScreen.
print "Powered landing loaded.".
print "Ready.".
wait 0.

    
function burnTime {
    if (bottomAlt < 50.0) {
        return min(ship:velocity:surface:mag, ship:deltaV:current) / (max(0.0001, ship:availablethrust) / ship:mass).
    }

    declare local g to ship:body:mu/((body:radius)^2). // use gravi at surface -> more safety burn height
	declare local vs to ship:verticalspeed.//ship:velocity:surface:mag.//
	declare local va to (max(1, ship:availablethrust)/ship:mass) - g.
    declare local burnHeight to ((vs^2)/(2*va)).

    declare local bt to (burnHeight / va) + 0.5. // add half second safty area
    return min(bt, ship:deltaV:current / va).
}

function timeToImpact {
    return bottomAlt / ship:velocity:surface:mag.
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

when not plandDone and burnTime() * orientAt > timeToImpact and bottomAlt > 10 then {
    lock steering to ship:srfretrograde.
    set SAS to false.

    return true.
}

when not plandDone and bottomAlt < 10 then {
    lock steering to up.
}

when not plandDone and bottomAlt < 100 and not gear then {
    toggle gear.
}
local wantSpeed to 0.0.
local onceUnderTime to false.
when not plandDone and burnTime() >= timeToImpact() then { // breaking
    set wantSpeed to 1.0.
    set onceUnderTime to true.

    print "Throttle ^    : " + round(wantSpeed * 100, 0) + "%     " at (2, 10).
    lock throttle to wantSpeed.

    return true.
}
when not plandDone and onceUnderTime and burnTime() < timeToImpact() then { // landing
    set diff to timeToImpact() - burnTime().
    set wantSpeed to 1.0 / timeToImpact() * (burnTime() - diff * 0.95).
    if (ship:verticalspeed > 0.1 or burnTime() * 2 < timeToImpact()) set wantSpeed to 0.

    print "Throttle v    : " + round(wantSpeed * 100, 0) + "%     " at (2, 10).
    lock throttle to wantSpeed.

    return true.
}

when not plandDone and true then {
    print "Time to impact: " + round(timeToImpact(), 2) + "s     " at (2, 5).
    print "Burn time     : " + round(burnTime(), 2) + "s     " at (2, 6).
    print "Speed         : " + round(ship:velocity:surface:mag, 0) + "m/s     " at (2, 7).
    print "Height        : " + round(bottomAlt, 2) + "m     " at (2, 8).

    return true.
}

wait until bottomAlt < touchDownHeight.
set plandDone to true.
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
