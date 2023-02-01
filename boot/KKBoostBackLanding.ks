
wait until ship:unpacked.

global mainWasStarted to true.
global startPowerlandWithVSpeed to -5.
global ignoreFlightState to true.

copyPath("0:/mainLib", "").
runOncePath("mainLib").

copyPath("0:/KK4TEE/library", "").
copyPath("0:/KK4TEE/runmodes", "").

RUN library.
BLANKSLATE().


set terminal:charheight to 16.
set terminal:width to 50.
set terminal:height to 5.
core:part:getmodule("kOSProcessor"):doevent("Open Terminal").

print "KK Boost Back v1.0.0".
set steeringData to ORIENTTOVECTOR_INIT(0.05, 0.05, 0.3).
GYROINIT(ship:altitude, 30). //Set the ship height, maxTargetGeeforce

print "Wait for start...".
wait until ship:verticalspeed > 5.
print "Wait for decouple...".
set startParts to SHIP:PARTS:length.
wait until SHIP:PARTS:length < startParts.
set BoostBackTimelimit to 180.

set terminal:width to 50.
set terminal:height to 35.
set RUNMODE to 20.

//ON AG10 {SET RUNMODE to -1. } //End program

clearScreen.
until RUNMODE < 0 {
    PRINTTOSCREEN().
    //wait 0.001.
    RUN runmodes.
    lock throttle to TVAL. // Apply engines
}