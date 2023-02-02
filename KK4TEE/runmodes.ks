//RUNMODES

rcs on.
lock steering to BoostBackVector:VEC.

if engineSafety = 1 and  VANG(BoostBackVector, fore) <= 1 {
    set engineSafety to 0.
}
if (engineSafety = 0) {
    set TVAL to 1.

    if (angleToTarget < 150) set TVAL to 0.2 + (1/150 * angleToTarget).
}

if (groundReachTime < fallTime and angleToTarget < 41) { 
    set TVAL to 0. 
    set engineSafety to 1.
    rcs on.
    brakes on.
    set RUNMODE to -1.
    unlock steering.
    unlock throttle.
}
    
lock throttle to TVAL.
