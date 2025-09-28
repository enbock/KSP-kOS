parameter targetAltitude, launchAngle, fuelBuffer.

local targetApoapsis to targetAltitude.
local lauchRunning to true.

function setTargetAltitudeNode {
  LOCAL radiusApoapsis TO ship:body:radius + targetAltitude.
  LOCAL velocityCircular TO sqrt(body:mu / radiusApoapsis).
  LOCAL timeToApoapsis TO time:seconds + eta:apoapsis.
  LOCAL velocityAtApoapsis TO velocityAt(ship, timeToApoapsis):ORBIT:MAG.
  LOCAL deltaVelocity TO velocityCircular - velocityAtApoapsis.

  LOCAL orbitalNode TO node(timeToApoapsis, 0, 0, deltaVelocity).
  add orbitalNode.
}

local gOutput to gui(300, 400).
set gOutput:x to -150.
set gOutput:y to -300.
set gOutput:draggable to true.

local fuelBufferInputBox to gOutput:ADDHBOX().
fuelBufferInputBox:ADDLABEL("Fuel Buffer (%)").
set fuelBufferInputBox:ADDTEXTFIELD((fuelBuffer * 100):tostring):onchange to {
  parameter value.
  set fuelBuffer to value:tonumber() / 100.
}.

local outputLabelAltitude to gOutput:addlabel("Altitude:").
local outputLabelLiquidFuel to gOutput:addlabel("Liquid Fuel:").
local outputLabelSolidFuel to gOutput:addlabel("Solid Fuel:").
local outputLabelTargetApoapsis to gOutput:addlabel("Target Apoapsis: " + targetApoapsis + " meters").
local outputLabelStatus to gOutput:addlabel("Launch v1.1.0").

set gOutput:addbutton("STOP"):onclick to  {
    set lauchRunning to false.
}.
gOutput:show().

set outputLabelStatus:text to "Launch sequence initiated.".

if ship:stagenum > 0 {
  stage.
}
lock throttle to 1.

wait until ship:altitude > 100.

set turnStartAltitude to 0.01 * targetApoapsis.
set startDirection to launchAngle.

set maxQ to 0.2.
set minTimeToApoapsis to 10.
set maxTimeToApoapsis to 60.
set minThrust to 0.25.

set apoapsisReached to false.
function isApoapsisReached {
    set apoapsisReached to apoapsisReached or ship:apoapsis >= targetApoapsis.
    return apoapsisReached.
}

local oldThrottle to 1.0.
lock liquidTank to stage:resourcesLex["LiquidFuel"]:amount.
lock solidTank to stage:resourcesLex["SolidFuel"]:amount.
lock fuelReserve to (
    stage:resourcesLex["LiquidFuel"]:capacity * fuelBuffer 
    * min(1, (1 / targetAltitude) * (ship:altitude + targetAltitude * 0.3))
) + 0.025.


until isApoapsisReached() or not lauchRunning {
    local apoPercent to 1.0 / targetApoapsis * ship:apoapsis.
    local angle to 90.0 - (90.0 * apoPercent).

    if ship:altitude < turnStartAltitude {
        lock steering to heading(launchAngle, 90).
    } else {
        lock steering to heading(startDirection, angle).
    }
    
    set outputLabelAltitude:text to "Altitude: " + round(ship:altitude, 1) + " m".
    set outputLabelLiquidFuel:text to "Liquid Fuel: " + round(liquidTank, 1).
    set outputLabelSolidFuel:text to "Solid Fuel: " + round(solidTank, 1).
    
    if (
        liquidTank <= fuelReserve 
        or (
            stage:resourcesLex["SolidFuel"]:capacity > 0
            and solidTank < 1
        )
    ) and ship:stagenum > 0  
    {   
        stage.
        set outputLabelStatus:text to "Staging...".
    }
    
    local newThrottle to 1.0.

    if eta:apoapsis < minTimeToApoapsis {
        set newThrottle to newThrottle * (1.0 + (1.0 - eta:apoapsis / minTimeToApoapsis)).
    }
    
    if eta:apoapsis > maxTimeToApoapsis {
        set newThrottle to newThrottle * (1.0 - (eta:apoapsis - maxTimeToApoapsis) / maxTimeToApoapsis).
    }
    
    local pressPercent to min(1.0, max(0.0, 1.0 - ((1.0 / maxQ * ship:dynamicpressure) - 1.0))).
    set newThrottle to newThrottle * pressPercent.
    
    if newThrottle < minThrust {
        set newThrottle to minThrust.
    }
    
    set newThrottle to (oldThrottle * 3.0 + newThrottle) / 4.0.
    set oldThrottle to newThrottle.
    
    lock throttle to newThrottle.
    
    wait 0.1.
}

setTargetAltitudeNode().

gOutput:hide().

lock throttle to 0.
unlock steering.
unlock throttle.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS on.
