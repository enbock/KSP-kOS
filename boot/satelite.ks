
wait until ship:unpacked.

copyPath("0:/mainLib", "").
runOncePath("mainLib").

set terminal:charheight to 20.

print "Satelite v1.1.2".
wait 1.

global startDirection to 90.
global startPowerlandWithVSpeed to -5.
global mainWasStarted to true.
global ignoreFlightState to false.
global powerLandFuelPercentage to 0.1.

print "Wait for orbit...".
core:part:getmodule("kOSProcessor"):doevent("Close Terminal").

wait until ship:status = "ORBITING".

print "Booting...".
core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
wait 5.
startRoutine().
