bbid = addChannel('BrakeBias', 5, 1, 0, 100, '%')

function tick_brakebias()
  local f = getChannel('BrakeF')
  local b = getChannel('BrakeR')
  -- only update when brake applied
  if b ~= 0 then setChannel(bbid, f/(f+b)*100) end
end

