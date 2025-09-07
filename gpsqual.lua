--------------------------------------------
-- gpsqual: Transform quality range into enum.
--
-- OUT
-- channel: GpsQualE
--
-- IN
-- channel: GpsQual
--
-- GpsQual (meaning) [GpsQualE]
-- <1 (Ideal) [0]
-- 1-2 (Excellent) [1]
-- 2-5 (Good) [2]
-- 5-10 (Moderate) [3]
-- 10-20 (Fair) [4]
-- >20 (Poor) [5]
--

local qualId = addChannel('GpsQualE', 1, 0, 0, 5)

function tick_gpsqual
  if not should_run(1) then return end
  local qual = getChannel('GpsQual')
  local enum = 21
  
  if qual < 1 then enum = 0 -- ideal
  elseif qual >= 1 and qual <= 2 then enum = 1 -- excellent
  elseif qual >= 3 and qual <= 5 then enum = 2 --good
  elseif qual >= 6 and qual <= 10 then enum = 3 -- moderate
  elseif qual >= 11 and qual <= 20 then enum = 4 -- fair
  elseif qual >= 21 then enum = 5 -- poor
  end
  setChannel(qualId, enum)
end
