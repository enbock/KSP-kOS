
wait until ship:unpacked.

set terminal:charheight to 16.
core:part:getmodule("kOSProcessor"):doevent("Open Terminal").

switch to 0.
if(ship:status = "PRELAUNCH" or ship:status = "LANDED") run start.
else if(ship:status = "ORBITING") run exec.
else if(ship:status = "SUB_ORBITAL" and ship:verticalspeed < 0) {
    if(ship:deltaV:current > 0) run pland. 
    else run land.
}
else print "For status " + ship:status + " Jeb does not knew a script.".