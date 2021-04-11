
wait until ship:unpacked.

copyPath("0:/pland", "").

wait until ship:verticalspeed < -100.
wait until ship:unpacked.
core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
set terminal:charheight to 12.
set terminal:width to 48.
set terminal:height to 12.

run pland.
