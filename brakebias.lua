bbid = addChannel('BrakeBias', 50, 1, 0, 100, '%')

function tick_brakebias()
  local f = getChannel('BrakeF')
  local b = getChannel('BrakeR')
  setChannel(bbid, f/(f+b)*100)
end
