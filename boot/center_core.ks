wait until ship:unpacked.

set CORE:PART:TAG to "kos_processor".

SWITCH TO 1.
copyPath("0:/pland", "1:/").

wait 1.

global function isDecoupled {
    SET shipProcessorList to SHIP:PARTSTAGGED("kos_processor").
    return shipProcessorList:length = 1.
}
wait until isDecoupled().

set g to gui(300, 400). 

set g:x to -150.
set g:y to -300.
set g:draggable to true.

local isLandPressed is false.
set g:addbutton("Land Booster"):onclick to {
    set isLandPressed to true.
}.

until false {
    g:show().

    wait until isLandPressed.

    g:hide().

    runpath("pland").

    wait 1.
    set isLandPressed to false.
}