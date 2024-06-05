
local minThustPercent is 0.1.
local burnDone is true.
local oldDeltaV to 0.
local beginManouverAt to 60.
local inManouver to false.
local execDone to not hasNode.

print "Warping to maneuver node...".
set g to gui(300, 200).
set g:x to -150.
set g:y to -100.
set g:draggable to true.
set output to g:addlabel("Delty-V:").

g:show().

function getBurnDuration {
    local manouver to nextNode.
    return manouver:deltav:mag / (max(0.0001, ship:availablethrust) / ship:mass).
}

if not execDone {
  // Warp to 15 seconds before the maneuver node
  WARPTO(time:seconds + nextNode:eta - 10 - (getBurnDuration() / 2.0)).
} 

when not execDone and not hasNode then {
    set output:text to "No manouver planned.".
    set execDone to true.
    return true.
}

when hasNode and burnDone and not inManouver and (nextNode:eta > getBurnDuration() / 2.0 + beginManouverAt) then {
    set output:text to "Wait for next manouver.".
    wait 1.

    return true.
}

when hasNode and burnDone and not inManouver and (nextNode:eta <= getBurnDuration() / 2.0 + beginManouverAt) then {
    local manouver to nextNode.
    SAS off.
    lock steering to manouver.
    set output:text to "Wait for ignition.".

    return true.
}

when hasNode and burnDone and not inManouver and (nextNode:eta <= getBurnDuration() / 2.0) then {
    set output:text to "Main engine start. ".

    lock steering to nextNode.
    set oldDeltaV to round(nextNode:deltav:mag + 1000000.0, 4).
    set burnDone to false.
    set inManouver to true.

    return true.
}

when not burnDone and inManouver then {
    if(not hasNode) {
        set burnDone to true.
        return true.
    }
    local manouver to nextNode.
    lock steering to manouver.
    set manouverDeltaV to round(manouver:deltav:mag, 4).
    set output:text to "Delta-V: " + round(manouverDeltaV, 2) + "m/s ".
    
    if (manouverDeltaV < 0.1 or oldDeltaV < manouverDeltaV) {
        set burnDone to true.
    } else if (manouverDeltaV < 2.0) {
        lock throttle to minThustPercent.
    } else if (manouverDeltaV < 7.0) {
        lock throttle to max(minThustPercent, 1.0 / 4.0 * (manouverDeltaV - 2.0)).
    } else lock throttle to 1.0.

    set oldDeltaV to manouverDeltaV.
    lock steering to manouver.
    wait 0.

    return true.
}

when burnDone and inManouver then {
    lock throttle to 0.
    set output:text to "Main engine cut off.".

    if(hasNode) {
      remove nextNode.
    }
    set execDone to not hasNode.
    unlock steering.
    unlock throttle.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
    SAS on.
    set inManouver to false.

    return true.
}

when not execDone and (ship:status = "SUB_ORBITAL" or ship:status = "FLYING") and ship:verticalspeed < -50 then {
    set execDone to true.
    return not execDone.
}

wait until execDone or not hasNode.

g:hide().
unlock steering.
unlock throttle.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS on.
