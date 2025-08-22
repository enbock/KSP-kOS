
local minThustPercent is 0.1.
local burnDone is true.
local oldDeltaV to 0.
local beginManouverAt to 20.
local inManouver to false.
local execDone to not hasNode.
local manouver to false.

local maneuverOutput to gui(300, 200).

set maneuverOutput:x to -150.
set maneuverOutput:y to -100.
set maneuverOutput:draggable to true.
local output to maneuverOutput:addlabel("Delty-V:").

maneuverOutput:show().

function getBurnDuration {
    return manouver:deltav:mag / (max(0.0001, ship:availablethrust) / ship:mass).
}

SAS off.
if hasNode {
    set manouver to nextNode.
    lock steering to manouver.
    lock manouverDeltaV to manouver:deltav:mag.
    WARPTO(time:seconds + nextNode:eta - beginManouverAt - (getBurnDuration() / 2.0)).
    set output:text to "Warping to maneuver node...".
}

when not execDone then {
    if not hasNode {
        set output:text to "No manouver planned.".
        set execDone to true.
        return false.
    }

    wait 0.

    if burnDone and not inManouver and (nextNode:eta <= getBurnDuration() / 2.0) {
        set output:text to "Main engine start. ".

        lock steering to nextNode.
        set oldDeltaV to nextNode:deltav:mag + 1000000.0.
        set burnDone to false.
        set inManouver to true.
    }

    if not burnDone and inManouver {
        set output:text to "Delta-V: " + round(manouverDeltaV, 2) + "m/s ".
        
        if (manouverDeltaV < 0.1 or oldDeltaV < manouverDeltaV) {
            set burnDone to true.
        } else if (manouverDeltaV < 2.0) {
            lock throttle to minThustPercent.
        } else if (manouverDeltaV < 7.0) {
            lock throttle to max(minThustPercent, 1.0 / 4.0 * (manouverDeltaV - 2.0)).
        } else lock throttle to 1.0.

        set oldDeltaV to manouverDeltaV.
    }

    if burnDone and inManouver {
        lock throttle to 0.
        set output:text to "Main engine cut off.".

        remove nextNode.
        set execDone to true.

        return false.
    }

    if (ship:status = "SUB_ORBITAL" or ship:status = "FLYING") and ship:verticalspeed < -50 {
        set execDone to true.
        return false.
    }

    return true.
}

wait until execDone.

lock throttle to 0.
set burnDone to true.
set inManouver to false.
unlock steering.
unlock throttle.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS on.
maneuverOutput:hide().
