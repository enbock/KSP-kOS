wait until ship:unpacked.

SWITCH TO 1.
copyPath("0:/pland", "1:/").

set CORE:PART:TAG to "kos_processor".
//local startParts to SHIP:PARTS:length.

global function isDecoupled {
    SET shipProcessorList to SHIP:PARTSTAGGED("kos_processor").
    return shipProcessorList:length = 1.
}

print "Bootser v2.2.1".
print "Wait for start...".
wait until ship:verticalspeed > 5.

print "Wait for decouple...".
wait until isDecoupled().

wait 3.

runpath("pland").
