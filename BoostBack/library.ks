
declare function cirecleDistance {
    declare parameter from, to.
    
    // https://en.wikipedia.org/wiki/Haversine_formula
    // https://en.wikipedia.org/wiki/Great-circle_distance
    set archav to sin((from:lat-to:lat)/2)^2 + cos(from:lat)*cos(to:lat)*sin((from:lng-to:lng)/2)^2.
    set dist to body:radius*constant():PI*arctan2(sqrt(archav),sqrt(1-archav))/90.

    return dist.
}
    
declare function BackBoostInit{
     //set SEALEVELGRAVITY to (constant():G * body:mass) / body:radius^2.
     lock GRAVITY to g(). //SEALEVELGRAVITY / ((body:radius+ALTITUDE) / body:radius)^2.
     set landingTarget to SHIP:GEOPOSITION.

     lock shipLatLng to SHIP:GEOPOSITION.
     lock fallTime to (((-VERTICALSPEED) - sqrt(VERTICALSPEED^2-(2 * (-GRAVITY) * ship:altitude ))) /  (-GRAVITY)).
     lock groundReachTime to cirecleDistance(shipLatLng, landingTarget) / GROUNDSPEED.
     lock BoostBackVector to landingTarget:ALTITUDEPOSITION(max(landingTarget:TERRAINHEIGHT, 0) + ALTITUDE * 0.8).
     lock fore to ship:facing:vector.
     lock angleToTarget to VANG(BoostBackVector, VELOCITY:SURFACE).
     set engineSafety to 1. 
     set tval to 0.
}

declare function bbOutput {
     set screenline to 2.
     print "Throttle        : " + round(TVAL * 100, 2) + "%       " at (2,screenline).
     set screenline to screenline + 2.
     print "Fall time       : " + round(fallTime, 2) + "       " at (2,screenline).
     set screenline to screenline + 1.
     print "Time to target  : " + round(groundReachTime, 2) + "       " at (2,screenline).
     set screenline to screenline + 1.
     print "Dist.Angl. to t.: " + round(angleToTarget, 2) + "    " at (2,screenline).
     set screenline to screenline + 1.
     print "Angle to fore   : " + round(VANG(BoostBackVector, fore), 2) + "       " at (2,screenline).
}
