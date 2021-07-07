
wait until ship:unpacked.

copyPath("0:/mainLib", "").
runOncePath("mainLib").

set terminal:charheight to 20.
set terminal:width to 48.
set terminal:height to 24.

print "Main v1.1.1".
wait 1.

global startDirection to 90.
global startPowerlandWithVSpeed to -5.
global mainWasStarted to true.

startRoutine().
