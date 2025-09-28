//RUNMODES

RCS on.
SAS off.
lock steering to BoostBackVector:VEC.

if engineSafety = 1 and  VANG(BoostBackVector, fore) <= 5 {
    set engineSafety to 0.
}
if (engineSafety = 0) {
    set TVAL to 1.

    if (angleToTarget < 150) set TVAL to 0.2 + (1/150 * angleToTarget).
}

set landOnWater to 75.
set landOnStartingPlace to 55.

if (groundReachTime < fallTime * 2.3 and angleToTarget < landOnWater) { 
    set TVAL to 0. 
    set engineSafety to 1.
    rcs on.
    brakes on.
    set RUNMODE to -1.
    unlock steering.
    unlock throttle.
}
    
lock throttle to TVAL.
