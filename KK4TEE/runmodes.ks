//RUNMODES
	
if runmode = 20 { //Boost Back
    rcs on.
    set BoostBackVector to landingtargetLATLNG:ALTITUDEPOSITION(max(landingtargetLATLNG:TERRAINHEIGHT, 0) + ALTITUDE * 1.30).
    ORIENTTOVECTOR(BoostBackVector:VEC, steeringData).
    
    if VANG( BoostBackVector, fore) < 15 {
        set engineSafety to 0. // Arm the engines
        set TVAL to 3 / TWR.
        }
    else if engineSafety = 0 { //If the engine has fired but we've moved off target
        set TVAL to 0.5 / TWR.
        }
    else { //Wait for things to line up.
        set TVAL to 0.
        }
    // if it will take less time to get to the LZ then it will to hit the ground, while also going in the generally correct direction, end burn
    //if ((gs_distance(shipLatLng,landingtargetLATLNG) / GROUNDSPEED) + 0) * 1.025 < fallTime + 0 and VANG( BoostBackVector, VELOCITY:SURFACE) < 45{ 
    if ((gs_distance(shipLatLng,landingtargetLATLNG) / GROUNDSPEED) + 0) < fallTime and VANG( BoostBackVector, VELOCITY:SURFACE) < 45{ 
        //TODO: Finish the above formula instead of fudging the BBTL
        //The plus 30 is the modifier for atmo drag
        set TVAL to 0. 
        set engineSafety to 1.
            SET SHIP:CONTROL:NEUTRALIZE to TRUE.
        rcs on.
        wait 1.
        SET SHIP:CONTROL:PITCH to -1.
        wait 3.
        SET SHIP:CONTROL:NEUTRALIZE to TRUE.
        wait 3.
        //set runmode to 21.
        
        brakes on.
        //replace original to pland
        set runmode to -1.
        run pland.
        }
    }
    
set t0 to TIME:SECONDS.