
wait until ship:unpacked.

global mainWasStarted to true.
global startPowerlandWithVSpeed to -5.
global ignoreFlightState to true.

clearScreen.
copyPath("0:/mainLib", "").
runOncePath("mainLib").
core:part:getmodule("kOSProcessor"):doevent("Close Terminal").

copyPath("0:/KK4TEE/library", "").
copyPath("0:/KK4TEE/runmodes", "").

RUN library.

set terminal:charheight to 16.
set terminal:width to 30.
set terminal:height to 5.

print "KK Boost Back v1.0.0".
BackBoostInit().

print "Wait for start...".
wait until ship:verticalspeed > 5.
print "Wait for decouple...".
set startParts to SHIP:PARTS:length.
wait until SHIP:PARTS:length < startParts.

set terminal:width to 30.
set terminal:height to 10.
set RUNMODE to 1.

core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
clearScreen.
print "KK Boost Back v1.0.0".
until RUNMODE < 0 {
    PRINTTOSCREEN().
    wait 0.
    RUN runmodes.
}

wait until RUNMODE = -1.

brakes on.
lock steering to ship:srfretrograde.
run pland.