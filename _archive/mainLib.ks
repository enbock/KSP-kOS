
//core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
wait 0.1.
print "Main-Lib v2.2.0".
RCS on.
set CORE:PART:TAG to "kos_processor".

global function isDecoupled {
    SET shipProcessorList to SHIP:PARTSTAGGED("kos_processor").
    return shipProcessorList:length = 1.
}

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

global function g {
    return  ship:body:mu / (ship:body:radius + ship:bounds:bottomaltradar) ^ 2.
}

global function shipPitch {
  return 90 - vang(ship:up:vector, ship:facing:forevector).
}

global function gravitationForce {
    return ship:mass * g().
}

global function shipOrientedGravityForce {
    return  gravitationForce() * (1 / 90 * shipPitch()).
}

global function shipForce {
    return ship:availableThrust - shipOrientedGravityForce().
}

global function accel {
    return (shipForce() / ship:mass).
}

global function twr {
    return (accel() / g()) * throttle.
}

global function fuelBurnTime {
    local flow to 0.
    list engines in engineList.
    FOR e IN engineList { 
        set flow to flow + e:MAXFUELFLOW.
    }
    return stage:resourcesLex["LiquidFuel"]:amount / flow.
}