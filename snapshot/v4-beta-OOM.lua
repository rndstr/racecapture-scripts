--------------------------------------------
-- main: Main tick function for racecapture device.
--
-- Uncomment calls in onTick() to run scripts.

-- 'info', 'verbose', or nil
LOG_LEVEL = 'info'
TICKS = 50

function info(str)
  if LOG_LEVEL == 'info' or LOG_LEVEL == 'verbose' then print('*** '..str) end
end

function verbose(str)
  if LOG_LEVEL == 'verbose' then print('+++ '..str) end
end

setTickRate(TICKS)
function onTick()
  tick_frequency()
  tick_vminmax_simple()
  tick_besttimetoday()
  tick_gpsdopenum()
  tick_iatdelta()
  -- tick_brakebias()
  -- tick_mock()
end
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
-- besttimetoday: Keeps track of the best lap time today
--
-- OUT
-- channel: BestTimeT "Best lap time today"
-- channel: LapDeltaT "Lap time delta vs best time today"
-- var: best_time_day
-- var: best_time_today
--

local Y, M, D = getDateTime()
local TODAY = string.format('%d%d%d', Y, M, D)

local bestTimeToday = loadVar('best_time_today')
local deltaId = addChannel('LapDeltaT', 10, 3, -5, 5, 's')
local bestId = addChannel('BestTimeT', 1, 4, 0, 5, 'min')

function __besttime_update(bestTime)
    if bestTime ~= nil then info('\nbest time today update: '..bestTime) end
    saveVar('best_time_today', bestTime)
    setChannel(bestId, bestTime)
    bestTimeToday = bestTime
end

-- reset?
if loadVar('best_time_day') ~= TODAY then
    info('\nwelcome to a new day')
    saveVar('best_time_day', TODAY)
    __besttime_update(nil)
end

function tick_besttimetoday()
    -- track best time today
    local bestTimeSession = getBestTime()
    if bestTimeToday == nil or bestTimeSession < bestTimeToday then
        __besttime_update(bestTimeSession)
    end
    -- calculate delta
    setChannel(deltaId, 60*(getPredTime()-bestTimeToday))
end

--------------------------------------------
-- vminmax_simple: simple window based VMin and VMax signal.
--
-- OUT
-- channel: VMin
-- channel: VMax
--
-- IN
-- Speed
--

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

-- local min/max calculation.
-- Returns signalId and value to update it to.
function __vminmax_signal()
  verbose('\n'..table.concat(vs, ','))
  first, mid, last = vs[1], vs[math.ceil(#vs/2)], vs[#vs]
  verbose('\nfirst='..first..', mid='..mid..', last='..last..' @'..tick)
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
  local enum = 5

  if dop < 1 then enum = 0 -- ideal
  elseif dop >= 1 and dop <= 2 then enum = 1 -- excellent
  elseif dop >= 3 and dop <= 5 then enum = 2 --good
  elseif dop >= 6 and dop <= 10 then enum = 3 -- moderate
  elseif dop >= 11 and dop <= 20 then enum = 4 -- fair
  elseif dop >= 21 then enum = 5 -- poor
  end
  setChannel(gpsDopEnumId, enum)
end
