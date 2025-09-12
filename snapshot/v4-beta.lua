LOG_LEVEL = 'info'
TICKS = 10
function info(str)
  if (LOG_LEVEL == 'info') or (LOG_LEVEL == 'verbose') then print('\n*** '..str) end
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
  if should_run(0.1) then collectgarbage('collect') end
end
local tick = 0
function should_run(hz)
  return tick % (TICKS/hz) == 0
end
function tick_frequency()
  tick = tick + 1
end
local Y, M, D = getDateTime()
local TODAY = string.format('%d%d%d', Y, M, D)
local bestTimeToday = loadVar('best_time_today')
local deltaId = addChannel('LapDeltaT', 10, 3, -5, 5, 's')
local bestTimeId = addChannel('BestTimeT', 1, 4, 0, 5, 'm')
local bestMinId = addChannel('BestMinT', 1, 0, 0, 5, 'm')
local bestSecId = addChannel('BestSecT', 1, 3, 0, 60, 's')
function __besttime_update(bestTime)
    saveVar('best_time_today', bestTime)
    setChannel(bestTimeId, bestTime)
    if bestTime ~= nil then
        local bestMin = bestTime - (bestTime % 1)
        local bestSec = (bestTime - bestMin)*60
        setChannel(bestMinId, bestMin)
        setChannel(bestSecId, bestSec)
        verbose('time='..bestTime..', min='..bestMin..', sec='..bestSec)
    end
    bestTimeToday = bestTime
end
if loadVar('best_time_day') ~= TODAY then
    info('welcome to a new day.')
    saveVar('best_time_day', TODAY)
    __besttime_update(nil)
end
function tick_besttimetoday()
    local bestTimeSession = getBestTime()
    if bestTimeToday == nil or (bestTimeSession ~= nil and bestTimeSession < bestTimeToday) then
        __besttime_update(bestTimeSession)
    end
    if bestTimeToday ~= nil then
        setChannel(deltaId, 60*(getPredTime()-bestTimeToday))
    end
end
local WINDOW_SIZE_SEC = 5
local FREQUENCY = 10
local MIN_DELTA_MPH = 10
local minId = addChannel('VMin', 5, 0, 0, 200, 'mph')
local maxId = addChannel('VMax', 5, 0, 0, 200, 'mph')
local vs = {}
function __vminmax_signal()
  verbose(table.concat(vs, ','))
  local first, mid, last = vs[1], vs[math.ceil(#vs/2)], vs[#vs]
  verbose('first='..first..', mid='..mid..', last='..last..' @'..tick)
  if math.abs(mid-first) < MIN_DELTA_MPH or math.abs(mid-last) < MIN_DELTA_MPH then
    verbose('  too similar.')
    return 0, nil
  end
  if first < mid and last < mid then
    info('  new max='..mid)
    return maxId, mid
  end
  if first > mid and last > mid then
    info('  new min='..mid)
    return minId, mid
  end
  verbose('  no hill.')
  return 0, nil
end
function tick_vminmax_simple()
  local speed = getChannel('Speed')
  if speed ~= nil and should_run(FREQUENCY) then
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
local gpsDopEnumId = addChannel('GpsDopEnum', 1, 0, 0, 5)
function tick_gpsdopenum()
  if not should_run(1) then return end
  local dop = getChannel('GPSDOP')
  local enum = 5
  if dop < 1 then enum = 0
  elseif dop >= 1 and dop <= 2 then enum = 1
  elseif dop >= 3 and dop <= 5 then enum = 2
  elseif dop >= 6 and dop <= 10 then enum = 3
  elseif dop >= 11 and dop <= 20 then enum = 4
  elseif dop >= 21 then enum = 5
  end
  setChannel(gpsDopEnumId, enum)
end
