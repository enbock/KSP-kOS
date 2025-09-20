//core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
copyPath("0:/mainLib", "").
runOncePath("mainLib").

set g to gui(300, 400). // Erhöhen der Höhe für mehr Platz

set g:x to -150.
set g:y to -100.
set g:draggable to true.

local isLaunchPressed is false.
local isLandPressed is false.
local isManeuverPressed is false.

// Eingabefelder für Zielhöhe, Startwinkel und den Puffer
local hflex1 is g:ADDHBOX().
hflex1:ADDLABEL("Target Altitude (m)").
local targetAltitudeInput is hflex1:ADDTEXTFIELD("80000").

local hflex2 is g:ADDHBOX().
hflex2:ADDLABEL("Launch Angle").
local launchAngleInput is hflex2:ADDTEXTFIELD("90").

local hflex3 is g:ADDHBOX().
hflex3:ADDLABEL("Fuel Buffer (%)").
local fuelBufferInput is hflex3:ADDTEXTFIELD("0").

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
        // Zielhöhe, Startwinkel und Puffer aus den Eingabefeldern lesen
        local targetAltitude to targetAltitudeInput:text:tonumber().
        local launchAngle to launchAngleInput:text:tonumber().
        local fuelBuffer to fuelBufferInput:text:tonumber() / 100.

        // Startskript mit den neuen Werten ausführen
        runpath("0:/v2/launch.ks", targetAltitude, launchAngle, fuelBuffer).
    } else if isLandPressed {
        //runpath("0:/v2/land.ks").
        run pland.
    } else if isManeuverPressed {
        runpath("0:/v2/maneuver.ks").
    }

    wait 1.
    set isLaunchPressed to false.
    set isLandPressed to false.
    set isManeuverPressed to false.
}