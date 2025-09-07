--------------------------------------------
-- gpsdopenum: Transform quality range into enum.
-- Dilution of precision.
-- See https://en.wikipedia.org/wiki/Dilution_of_precision_(navigation)
--
-- OUT
-- channel: GpsDopEnum
--
-- IN
-- channel: GPSDOP
--
-- GPSDOP (meaning) [GpsDopEnum]
-- <1 (Ideal) [0]
-- 1-2 (Excellent) [1]
-- 2-5 (Good) [2]
-- 5-10 (Moderate) [3]
-- 10-20 (Fair) [4]
-- >20 (Poor) [5]
--

local gpsDopEnumId = addChannel('GpsDopEnum', 1, 0, 0, 5)

function tick_gpsdopenum()
  if not should_run(1) then return end
  local dop = getChannel('GPSDOP')
  local enum = 21
  
  if dop < 1 then enum = 0 -- ideal
  elseif dop >= 1 and dop <= 2 then enum = 1 -- excellent
  elseif dop >= 3 and dop <= 5 then enum = 2 --good
  elseif dop >= 6 and dop <= 10 then enum = 3 -- moderate
  elseif dop >= 11 and dop <= 20 then enum = 4 -- fair
  elseif dop >= 21 then enum = 5 -- poor
  end
  setChannel(gpsDopEnumId, enum)
end
