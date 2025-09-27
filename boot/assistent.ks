//core:part:getmodule("kOSProcessor"):doevent("Open Terminal").
//runOncePath("0:/mainLib").

set g to gui(300, 400). // Erhöhen der Höhe für mehr Platz

set g:x to -150.
set g:y to -100.
set g:draggable to true.
set g:style:fontsize to 20.

local isLaunchPressed is false.
local isLandPressed is false.
local isManeuverPressed is false.

// Eingabefelder für Zielhöhe, Startwinkel und den Puffer

// Werte aus JSON-Datei laden
local settingsFile is "0:/assistentSettings.json".
local loadedAltitude is "80".
local loadedAngle is "90".
local loadedFuelBuffer is "30".
if EXISTS(settingsFile) {
    local settingsData is READJSON(settingsFile).
    set loadedAltitude to settingsData["altitude"].
    set loadedAngle to settingsData["angle"].
    set loadedFuelBuffer to settingsData["buffer"].
}

local hflex1 is g:ADDHBOX().
hflex1:ADDLABEL("Target Altitude (km)").
local targetAltitudeInput is hflex1:ADDTEXTFIELD(loadedAltitude).

local hflex2 is g:ADDHBOX().
hflex2:ADDLABEL("Launch Angle (°)").
local launchAngleInput is hflex2:ADDTEXTFIELD(loadedAngle).

local hflex3 is g:ADDHBOX().
hflex3:ADDLABEL("Fuel Buffer (%)").
local fuelBufferInput is hflex3:ADDTEXTFIELD(loadedFuelBuffer).

// Checkbox für JSON-Speichern
local saveJsonCheckbox to true.
set g:ADDHBOX():addcheckbox("Update value store with current input", saveJsonCheckbox):ontoggle to {
    parameter newState.
    set saveJsonCheckbox to newState.
}.

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
        local targetAltitude to targetAltitudeInput:text:tonumber() * 1000.
        local launchAngle to launchAngleInput:text:tonumber().
        local fuelBuffer to fuelBufferInput:text:tonumber() / 100.
        
        // Werte als JSON speichern
        if saveJsonCheckbox {
            local settingsData is LEXICON().
            settingsData:Add("altitude", targetAltitudeInput:text).
            settingsData:Add("angle", launchAngleInput:text).
            settingsData:Add("buffer", fuelBufferInput:text).
            WRITEJSON(settingsData, settingsFile).
        }

        // Startskript mit den neuen Werten ausführen
        runpath("0:/launch", targetAltitude, launchAngle, fuelBuffer).
    } else if isLandPressed {
        //runpath("0:/v2/land").
        runpath("0:/pland").
    } else if isManeuverPressed {
        runpath("0:/maneuver").
    }

    wait 1.
    set isLaunchPressed to false.
    set isLandPressed to false.
    set isManeuverPressed to false.
}