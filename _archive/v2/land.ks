// Suicide burn landing script
lock throttle to 0.
lock steering to retrograde.

// Function to calculate the suicide burn altitude
function getSuicideBurnAltitude {
  local TWR is ship:maxthrust / (ship:mass * body:surfacegravity).
  local v is ship:velocity:surface:mag.
  local burnTime is v / (TWR * body:surfacegravity).
  return 0.5 * v * burnTime.
}

// Wait until near the suicide burn altitude
until ship:altitude - getSuicideBurnAltitude() < 500 {
  wait 1.
}

// Perform the suicide burn
lock throttle to 1.
wait until ship:verticalspeed > -5.

// Cut off engines and land gently
lock throttle to 0.1.
wait until ship:verticalspeed < 0.
lock throttle to 0.
print "Landing complete!".
