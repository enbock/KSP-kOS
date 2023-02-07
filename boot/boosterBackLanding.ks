
wait until ship:unpacked.

global mainWasStarted to true.
global startPowerlandWithVSpeed to -5.
global ignoreFlightState to true.
global powerLandFuelPercentage to 0.3.

clearScreen.
copyPath("0:/mainLib", "").
copyPath("0:/BoostBack/library", "").
copyPath("0:/BoostBack/boostBack", "").
runOncePath("mainLib").
runOncePath("library").

BackBoostInit().
print "Boost Back v1.0.2".
print "Ready.".

set terminal:charheight to 16.
set terminal:width to 30.
set terminal:height to 5.

print "Wait for start...".
wait until ship:verticalspeed > 5.

print "Wait for decouple...".
local startParts to SHIP:PARTS:length.
wait until SHIP:PARTS:length <> startParts.

set terminal:width to 30.
set terminal:height to 10.
set RUNMODE to 1.

clearScreen.

until RUNMODE < 0 {
    bbOutput().
    wait 0.
    RUN boostBack.
}

wait until RUNMODE = -1.

brakes on.
lock steering to ship:srfretrograde.
run pland.