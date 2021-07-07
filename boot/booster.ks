
wait until ship:unpacked.

global mainWasStarted to true.
global startPowerlandWithVSpeed to -5.

wait until ship:verticalspeed < startPowerlandWithVSpeed.
wait until ship:unpacked.
copyPath("0:/mainLib", "").
runOncePath("mainLib").

set terminal:charheight to 16.
set terminal:width to 48.
set terminal:height to 14.

print "Bootser v1.0.4".
wait 1.

run pland.
