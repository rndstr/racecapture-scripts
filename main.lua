--------------------------------------------
-- main: Main tick function for racecapture device.
--
-- Uncomment calls in onTick() to run scripts.

LOG_LEVEL = 'info'
TICKS = 50

function info(str)
  if LOG_LEVEL == 'info' then print(str) end
end

function verbose(str)
  if LOG_LEVEL == 'info' or LOG_LEVEL == 'verbose' then print(str) end
end

setTickRate(TICKS)
function onTick()
  tick_frequency()
  -- tick_mock()
  -- tick_vminmax_simple()
  -- tick_brakebias()
end
