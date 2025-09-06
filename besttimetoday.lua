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

