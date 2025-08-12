--------------------------------------------
-- main: Main tick function for racecapture device.
--
-- Uncomment calls in onTick() to run scripts.

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
  -- tick_mock()
  tick_vminmax_simple()
  -- tick_brakebias()
end
--------------------------------------------
-- frequency: A script to help run actions less frequently than
-- the global TICK frequency.

-- current tick
local tick = 0

-- returns true if this is the tick to run an action.
-- E.g., pass in 10 to have an action trigger 10 times a second.
function should_run(hz)
  return tick % (TICKS/hz) == 0
end

function tick_frequency()
  tick = tick + 1
end


--------------------------------------------
-- vminmax_simple: simple window based VMin and VMax signal.

-- window size in seconds to keep track of first and last value.
local WINDOW_SIZE_SEC = 5
-- how many per seconds to record
local FREQUENCY = 10
-- minimum difference between edges and mid value to be considered a local value.
local MIN_DELTA_MPH = 10

-- name, Hz, precision, min, max, units
local minId = addChannel('VMin', 5, 0, 0, 200, 'mph')
local maxId = addChannel('VMax', 5, 0, 0, 200, 'mph')

-- recorded values
local vs = {}
-- we record a value every TICKS/FREQUENCY counts.
local tick_count = 0

-- local min/max calculation.
-- Returns signalId and value to update it to.
function __vminmax_signal()
  verbose('\n'..table.concat(vs, ','))
  first, mid, last = vs[1], vs[math.ceil(#vs/2)], vs[#vs]
  info('\nfirst='..first..', mid='..mid..', last='..last..' @'..tick)
  -- too flat?
  if math.abs(mid-first) < MIN_DELTA_MPH or math.abs(mid-last) < MIN_DELTA_MPH then
    verbose('\n  too similar.')
    return 0, nil
  end
  -- maxima?
  if first < mid and last < mid then
    info('\n  new max='..mid)
    return maxId, mid
  end
  -- minima?
  if first > mid and last > mid then
    info('\n  new min='..mid)
    return minId, mid
  end
  verbose('\n  no hill.')
  return 0, nil
end

function tick_vminmax_simple()
  local speed = getChannel('Speed')
  if speed ~= nil and should_run(FREQUENCY) then
    -- append, resize, update.
    table.insert(vs, speed)
    if #vs > WINDOW_SIZE_SEC*FREQUENCY then table.remove(vs, 1) end
    if #vs == WINDOW_SIZE_SEC*FREQUENCY then
      local id, value = __vminmax_signal()
      if id ~= 0 then
        setChannel(id, value)
      end
    end
  end
end

--------------------------------------------
-- brakebias: Adds BrakeBias signal.
local bbid = addChannel('BrakeBias', 5, 1, 0, 100, '%')

function tick_brakebias()
  local f = getChannel('BrakeF')
  local b = getChannel('BrakeR')
  -- only update when brake applied
  if b ~= 0 then setChannel(bbid, f/(f+b)*100) end
end

