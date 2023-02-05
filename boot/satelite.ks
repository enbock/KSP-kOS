
wait until ship:unpacked.

copyPath("0:/mainLib", "").
runOncePath("mainLib").

set terminal:charheight to 20.

print "Satelite v1.0.0".
wait 1.

global startDirection to 90.
global startPowerlandWithVSpeed to -5.
global mainWasStarted to true.
global ignoreFlightState to false.
global powerLandFuelPercentage to 0.1.

print "Wait for orbit...".
wait until ship:status = "ORBITING".

run exec.
