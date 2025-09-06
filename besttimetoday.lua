local Y, M, D = getDateTime()
local TODAY = string.format('%d%d%d', Y, M, D)

local bestTimeToday = loadVar('best_time_today')
local deltaId = addChannel('LapDeltaToday', 10, 3, -100, 100, 's')


-- reset?
if loadVar('best_time_day') ~= TODAY then
    info('it is a new day')
    saveVar('best_time_day', TODAY)
    __update_besttime(nil)
end


function __update_besttime(bestTime)
    info('updating today\'s best time to: '..bestTime)
    saveVar('best_time_today', bestTime)
    bestTimeToday = bestTime
end


function tick_besttimetoday()
    -- track best time today
    local bestTimeSession = getBestTime()
    if bestTimeToday == nil or bestTimeSession < bestTimeToday then
        __update_besttime(bestTimeSession)
    end
    -- calculate delta
    setChannel(deltaId, 60*(getPredTime()-bestTimeToday))
end

