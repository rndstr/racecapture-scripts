--------------------------------------------
-- main: Main tick function for racecapture device.
--
-- Uncomment calls in onTick() to run scripts.

-- 'info', 'verbose', or nil
LOG_LEVEL = 'info'
TICKS = 10

function info(str)
  if LOG_LEVEL == 'info' or LOG_LEVEL == 'verbose' then print('\n*** '..str) end
end

function verbose(str)
  if LOG_LEVEL == 'verbose' then print('\n+++ '..str) end
end

setTickRate(TICKS)
function onTick()
  tick_frequency()
  tick_vminmax_simple()
  tick_besttimetoday()
  tick_gpsdopenum()
  -- tick_iatdelta()
  -- tick_brakebias()
  -- tick_mock()

  -- once every 10s.
  if should_run(0.1) then collectgarbage('collect') end
end
