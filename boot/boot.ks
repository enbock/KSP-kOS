
wait until ship:unpacked.

set terminal:charheight to 20. // for 4k screen
core:part:getmodule("kOSProcessor"):doevent("Open Terminal").

//copyPath("0:/exec", "").
//copyPath("0:/land", "").
//copyPath("0:/start", "").
//print "Programs installed.".

switch to 0.
run start.