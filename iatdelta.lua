--------------------------------------------
-- iatdelta: Provide delta to ambient air temp.
--
-- Allows observing the temp delta between ambient
-- and intake.
--
-- OUT
-- channel: IATDelta
--
-- IN
-- channel: AAT
--

local iatDeltaId = addChannel('IATDelta', 1, 0, -50, 50, 'F')

function tick_iatdelta()
  if not should_run(1) then return end
  local aat = getChannel('AAT')
  local iat = getChannel('IAT')
  setChannel(iatDeltaId, iat-aat)
end

