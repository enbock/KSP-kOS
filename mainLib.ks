

copyPath("0:/exec", "").
copyPath("0:/land", "").
copyPath("0:/pland", "").
copyPath("0:/start", "").

core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
wait 0.1.
print "Main-Lib 1.1.0".

global function startRoutine {
    if(ship:status = "PRELAUNCH" or ship:status = "LANDED") run start.
    else if(ship:status = "ORBITING" or ship:status = "ESCAPING") run exec.
    else if((ship:status = "SUB_ORBITAL" or (ship:body:atm:exists and ship:periapsis < ship:body:atm:height)) and ship:verticalspeed < 0) {
        if(ship:deltaV:current > 0) run pland. 
        else run land.
    }
    else if(ship:status = "SUB_ORBITAL") run start.
    else if(ship:status = "FLYING") if (ship:verticalspeed < 0) run pland. else run start.
    else print "For status " + ship:status + " Jeb does not knew a script.".
}

function g {
    return  ship:body:mu / (ship:body:radius + ship:bounds:bottomaltradar) ^ 2.
}

global function accel {
    return (ship:availableThrust / ship:mass).
}

global function twr {
    return accel() / g() * throttle.
}