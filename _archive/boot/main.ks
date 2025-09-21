
wait until ship:unpacked.

copyPath("0:/mainLib", "").
runOncePath("mainLib").

set terminal:charheight to 20.

print "Main v1.1.2".
wait 1.

global startDirection to 90.
global startPowerlandWithVSpeed to -5.
global mainWasStarted to true.
global ignoreFlightState to false.
global powerLandFuelPercentage to 0.1.
global starterIsPresent to false.

//startRoutine().
