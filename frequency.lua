--------------------------------------------
-- frequency: A script to help run actions less frequently than
-- the global TICK frequency.

-- current tick
local tick = 0

-- returns true if this is the tick to run an action.
-- E.g., pass in 10 to have an action trigger 10 times a second.
function should_run(hz)
  return tick % TICK/hz == 0
end

function tick_frequency()
  tick + 1
end


