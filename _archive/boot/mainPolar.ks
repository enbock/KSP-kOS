
wait until ship:unpacked.

copyPath("0:/mainLib", "").
runOncePath("mainLib").

set terminal:charheight to 20.
set terminal:width to 48.
set terminal:height to 24.

print "Polar-Orbit-Main v1.0.2".
wait 1.

global startDirection to 0.
global startPowerlandWithVSpeed to -5.
global mainWasStarted to true.
global ignoreFlightState to false.
global powerLandFuelPercentage to 0.1.

startRoutine().