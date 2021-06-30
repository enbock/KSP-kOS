//
// Powered landing
//

global engineStartTime to 0.5.
//global minAltituteForBurnstart to 10000.0.
//if(ship:body:atm:exists) {
//    set minAltituteForBurnstart to ship:body:atm:height/10.0.
//}

set orientAt to 3. // 3 burn time before touch down
set bottomAlt to ship:bounds:bottomaltradar.
local plandDone to false.
local touchDownHeight to 0.5.
clearScreen.
print "Powered landing loaded. v1.0.8".
print "Ready.".
wait 0.
local wantSpeed to 0.0.
local onceUnderTime to false.

function g {
    return  ship:body:mu / (ship:body:radius + bottomAlt) ^ 2.
}
    
function burnTime {
    if(ship:availablethrust <= 0) return 0.

    declare local accel to ship:availablethrust/ship:mass.
	declare local vs to ship:velocity:surface:mag.
    
    //print "???           : " + round((timeToImpact() + vs) / accel, 2) + "s     " at (2, 10).

    declare local result to (g() * timeToImpact() + vs) / (accel * g()).

    if (result < engineStartTime) return (g() * timeToImpact() + vs) / accel. // break long at the end (for body with atm needed)
    return result.
}

function timeToImpact {
    return (bottomAlt / ship:velocity:surface:mag).
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

when not plandDone and burnTime() * orientAt > timeToImpact() and bottomAlt > 10 then {
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

when not plandDone 
//and minAltituteForBurnstart > ship:altitude 
and (
    burnTime() >= timeToImpact() or (not onceUnderTime and timeToImpact() < engineStartTime)
) then { // breaking
    set wantSpeed to 1.0.
    set onceUnderTime to true.

    print "Throttle ^    : " + round(wantSpeed * 100, 0) + "%     " at (2, 12).
    lock throttle to wantSpeed.

    return true.
}
when not plandDone and (onceUnderTime and (burnTime() < timeToImpact() or timeToImpact() < engineStartTime)) then { // landing
    set diff to timeToImpact() - burnTime().
    set wantSpeed to 1.0 / timeToImpact() * (burnTime() - diff * 0.95).
    if (ship:verticalspeed > 0.1 or burnTime() * 2 < timeToImpact()) set wantSpeed to 0.
    //if (wantSpeed < 0.1) {
    //    set wantSpeed to 0.
    //    set onceUnderTime to false.
    //}

    print "Throttle v    : " + round(wantSpeed * 100, 0) + "%     " at (2, 12).
    lock throttle to wantSpeed.

    return true.
}

when not plandDone then {
    print "Time to impact: " + round(timeToImpact(), 2) + "s     " at (2, 5).
    print "Burn time     : " + round(burnTime(), 2) + "s     " at (2, 6).
    
    print "Speed         : " + round(ship:velocity:surface:mag, 0) + "m/s     " at (2, 8).
    print "Height        : " + round(bottomAlt, 2) + "m     " at (2, 9).

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
