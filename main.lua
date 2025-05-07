DEBUG = true
TICKS = 50

function dbg(str)
  if DEBUG then print(str) end
end

setTickRate(TICKS)
function onTick()
  -- tick_mock()
  -- tick_vminmax_simple()
  -- tick_brakebias()
end
