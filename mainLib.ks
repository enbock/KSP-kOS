

copyPath("0:/exec", "").
copyPath("0:/land", "").
copyPath("0:/pland", "").
copyPath("0:/start", "").

core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
wait 0.1.
print "Main-Lib 1.0.2".

global function startRoutine {
    if(ship:status = "PRELAUNCH" or ship:status = "LANDED") run start.
    else if(ship:status = "ORBITING" or ship:status = "ESCAPING") run exec.
    else if((ship:status = "SUB_ORBITAL" or ship:status = "FLYING") and ship:verticalspeed < 0) {
        if(hasNode) {
            run exec.
        } else {
            if(ship:deltaV:current > 0) run pland. 
            else run land.
        }
    }
    else print "For status " + ship:status + " Jeb does not knew a script.".
}