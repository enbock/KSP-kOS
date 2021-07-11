
wait until ship:unpacked.

copyPath("0:/mainLib", "").
runOncePath("mainLib").

set terminal:charheight to 20.

print "Main v1.1.1".
wait 1.

global startDirection to 90.
global startPowerlandWithVSpeed to -5.
global mainWasStarted to true.

startRoutine().
