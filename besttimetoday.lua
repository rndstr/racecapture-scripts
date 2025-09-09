--------------------------------------------
-- besttimetoday: Keeps track of the best lap time today
--
-- Due to the racecapture limitation that we cannot string
-- format lap times, we provide two separate fields too.
--
-- Not a good workaround to use virtual channels, waste of
-- metrics. But that's all we can do.
--
-- OUT
-- channel: BestTimeT "Best lap time today in decimal minutes"
-- channel: BestTMin
-- channel: BestTSec
-- channel: LapDeltaT "Lap time delta vs best time today"
-- var: best_time_day
-- var: best_time_today
--

local Y, M, D = getDateTime()
local TODAY = string.format('%d%d%d', Y, M, D)

local bestTimeToday = loadVar('best_time_today')
local deltaId = addChannel('LapDeltaT', 10, 3, -5, 5, 's')
local bestTimeId = addChannel('BestTimeT', 1, 4, 0, 5, 'm')
local bestMinId = addChannel('BestMinT', 1, 0, 0, 5, 'm')
local bestSecId = addChannel('BestSecT', 1, 3, 0, 60, 's')

function __besttime_update(bestTime)
    if bestTime ~= nil then info('\nbest time today update: '..bestTime) end
    saveVar('best_time_today', bestTime)
    setChannel(bestTimeId, bestTime)
    local bestMin = math.tointeger(bestTime)
    local bestSec = (bestTime - bestMin)*60
    setChannel(bestMinId, bestMin)
    setChannel(bestSecId, bestSec)
    verbose('time='..bestTime..', min='..bestMin..', sec='..bestSec)

    bestTimeToday = bestTime
end

-- reset?
if loadVar('best_time_day') ~= TODAY then
    info('welcome to a new day.')
    saveVar('best_time_day', TODAY)
    __besttime_update(nil)
end

function tick_besttimetoday()
    -- track best time today
    local bestTimeSession = getBestTime()
    if bestTimeToday == nil or (bestTimeSession ~= nil and bestTimeSession < bestTimeToday) then
        __besttime_update(bestTimeSession)
    end
    -- calculate delta
    if bestTimeToday ~= nil then
        setChannel(deltaId, 60*(getPredTime()-bestTimeToday))
    end
end

