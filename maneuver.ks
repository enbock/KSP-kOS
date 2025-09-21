

if hasNode {
    local minThustPercent is 0.1.
    local burnDone is true.
    local oldDeltaV to 0.
    local beginManouverAt to 20.
    local inManouver to false.
    local execDone to false.
    local manouver to nextNode.
    

    function getBurnDuration {
        return manouver:deltav:mag / (max(0.0001, ship:availablethrust) / ship:mass).
    }

    local maneuverOutput to gui(300, 200).
    set maneuverOutput:x to -150.
    set maneuverOutput:y to -100.
    set maneuverOutput:draggable to true.

    local output to maneuverOutput:addlabel("Maneuver Executer v1.0.0").
    set maneuverOutput:addbutton("STOP"):onclick to  {
        set execDone to true.
    }.
    maneuverOutput:show().

    SAS off.

    lock steering to manouver.
    lock manouverDeltaV to manouver:deltav:mag.
    // Warten bis Schiff ausgerichtet ist
    set output:text to "Waiting for alignment to maneuver target...".
    // Berechne Winkel zwischen Schiff und Manöver-DeltaV
    until VANG(ship:facing:vector, manouver:deltav) < 2  or execDone{
        wait 0.1.
        set output:text to "Alignment: " + round(VANG(ship:facing:vector, manouver:deltav), 2) + "°".
    }
    if not execDone {
        set output:text to "Alignment reached. Starting warp...".
        wait 5.
        WARPTO(time:seconds + nextNode:eta - beginManouverAt - (getBurnDuration() / 2.0)).
        set output:text to "Warping to maneuver node...".
    }

    set output:text to "Wait time to ignite...".
    
    until execDone {
        if burnDone and not inManouver and (nextNode:eta <= getBurnDuration() / 2.0) {
            set output:text to "Main engine start.".

            lock steering to nextNode.
            set oldDeltaV to nextNode:deltav:mag + 1000000.0.
            set burnDone to false.
            set inManouver to true.
        }

        

        if not burnDone and inManouver {
            set output:text to "Delta-V: " + round(manouverDeltaV, 2) + " m/s".
            
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

            //remove nextNode.
            set execDone to true.
        }
    }

    
    lock throttle to 0.
    set burnDone to true.
    set inManouver to false.
    unlock steering.
    unlock throttle.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
    SAS on.

    maneuverOutput:hide().
}
