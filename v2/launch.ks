parameter targetAltitude is 80000.
parameter launchAngle is 90.
parameter fuelBuffer is 0.1.

local targetApoapsis to body:radius * 1.1.
if body:atm:exists {
  set targetApoapsis to body:atm:height * 1.1.
}

function getLEO {
  parameter b.
  if b:atm:exists {
    return b:atm:height.
  }
  return b:altitude.
}

function setCircularizationNode {
  set needVelocity to sqrt(body:mu / (body:radius + targetAltitude)).
  LOCAL timeToApoapsis to time:seconds + eta:apoapsis.
  LOCAL velcityAtAposis to velocityAt(ship, timeToApoapsis):ORBIT:MAG.
  set restVelocity to needVelocity - velcityAtAposis.

  set orbitalNode to node(timeToApoapsis, 0, 0, restVelocity).
  add orbitalNode.
}

local gOutput to gui(300, 400).
set gOutput:x to -150.
set gOutput:y to -300.
set gOutput:draggable to true.

local outputLabelAltitude to gOutput:addlabel("Altitude:").
local outputLabelLiquidFuel to gOutput:addlabel("Liquid Fuel:").
local outputLabelSolidFuel to gOutput:addlabel("Solid Fuel:").
local outputLabelTargetApoapsis to gOutput:addlabel("Target Apoapsis: " + targetApoapsis + " meters").
local outputLabelStatus to gOutput:addlabel("").

gOutput:show().

print "Launch sequence initiated.".
set outputLabelStatus:text to "Launch sequence initiated.".

stage.
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

until isApoapsisReached() {
    local apoPercent to 1.0 / targetApoapsis * ship:apoapsis.
    local angle to 90.0 - (90.0 * apoPercent).
    if ship:altitude < turnStartAltitude {
        lock steering to heading(launchAngle, 90).
    } else {
        lock steering to heading(startDirection, angle).
    }
    
    set outputLabelAltitude:text to "Altitude: " + round(ship:altitude, 1) + " m".
    set outputLabelLiquidFuel:text to "Liquid Fuel: " + round(stage:resourcesLex["LiquidFuel"]:amount, 1).
    set outputLabelSolidFuel:text to "Solid Fuel: " + round(stage:resourcesLex["SolidFuel"]:amount, 1).
    
    if stage:resourcesLex["LiquidFuel"]:amount <= (fuelBuffer * stage:resourcesLex["LiquidFuel"]:capacity) and stage:resourcesLex["SolidFuel"]:amount <= 0.025 and ship:stagenum > 0 {
        stage.
        print "Staging...".
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

lock steering to prograde.
until ship:apoapsis > targetApoapsis {
  wait 1.
}

setCircularizationNode().

lock throttle to 0.
set outputLabelStatus:text to "Launch complete!".

gOutput:hide().
unlock steering.
unlock throttle.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS on.
