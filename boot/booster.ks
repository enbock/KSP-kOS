
wait until ship:unpacked.

RUNONCEPATH("0:/mainLib").

set terminal:charheight to 16.
set terminal:width to 48.
set terminal:height to 14.

print "Bootser v2.0.0".
print "Wait for start...".
wait until ship:verticalspeed > 5.

print "Wait for decouple...".
local startParts to SHIP:PARTS:length.
wait until isDecoupled().
RUNPATH("0:/pland").
