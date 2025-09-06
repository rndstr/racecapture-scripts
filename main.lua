--------------------------------------------
-- main: Main tick function for racecapture device.
--
-- Uncomment calls in onTick() to run scripts.

-- 'info', 'verbose', or nil
LOG_LEVEL = 'info'
TICKS = 50

function info(str)
  if LOG_LEVEL == 'info' or LOG_LEVEL == 'verbose' then print(str) end
end

function verbose(str)
  if LOG_LEVEL == 'verbose' then print(str) end
end

setTickRate(TICKS)
function onTick()
  tick_frequency()
  -- tick_vminmax_simple()
  -- tick_besttimetoday()
  -- tick_brakebias()
  -- tick_mock()
end
