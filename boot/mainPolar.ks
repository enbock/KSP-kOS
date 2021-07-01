
wait until ship:unpacked.

copyPath("0:/mainLib", "").
runOncePath("mainLib").

print "Polar-Orbit-Main v1.0.0".
wait 1.

global startDirection to 0.
global startPowerlandWithVSpeed to -5.

startRoutine().