//core:part:getmodule("kOSProcessor"):doevent("Open Terminal").

set g to gui(300, 200).

set g:x to -150.
set g:y to -100.
set g:draggable to true.

local isLaunchPressed is false.
local isLandPressed is false.
local isManeuverPressed is false.

set g:addbutton("Launch Rocket"):onclick to  {
    set isLaunchPressed to true.
}.
set g:addbutton("Land Rocket"):onclick to {
    set isLandPressed to true.
}.
set g:addbutton("Execute Maneuver"):onclick to  {
    set isManeuverPressed to true.
}.

until false {
    g:show().

    wait until isLaunchPressed or isLandPressed or isManeuverPressed.

    g:hide().

    if isLaunchPressed {
        runpath("0:/ai-pilot/launch.ks").
    } else if isLandPressed {
        runpath("0:/ai-pilot/land.ks").
    } else if isManeuverPressed {
        runpath("0:/ai-pilot/maneuver.ks").
    }

    wait 1.
    set isLaunchPressed to false.
    set isLandPressed to false.
    set isManeuverPressed to false.
}