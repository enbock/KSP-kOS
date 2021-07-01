
wait until ship:unpacked.

copyPath("0:/mainLib", "").
runOncePath("mainLib").

print "Main v1.1.0".
wait 1.

global startDirection to 90.
global startPowerlandWithVSpeed to -5.

startRoutine().
