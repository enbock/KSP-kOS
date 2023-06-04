
wait until ship:unpacked.

global mainWasStarted to true.
global startPowerlandWithVSpeed to -5.
global ignoreFlightState to true.

copyPath("0:/mainLib", "").
runOncePath("mainLib").

set terminal:charheight to 16.
set terminal:width to 48.
set terminal:height to 14.
global powerLandFuelPercentage to 0.1.

print "Bootser v1.1.0".
print "Wait for start...".
wait until ship:verticalspeed > 5.

print "Wait for decouple...".
local startParts to SHIP:PARTS:length.
wait until isDecoupled().
run pland.
