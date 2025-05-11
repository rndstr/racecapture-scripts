-- vminmax_simple: simple window based VMin and VMax signal.

-- window size in seconds
WINDOW_SIZE_SEC = 5
-- how many per seconds to record
FREQUENCY = 5
-- minimum difference between edges and mid value to be considered a local value.
MIN_DELTA_MPH = 10

-- name, Hz, precision, min, max, units
minId = addChannel('VMin', FREQUENCY, 0, 0, 200, 'mph')
maxId = addChannel('VMax', FREQUENCY, 0, 0, 200, 'mph')

-- recorded values
vs = {}
-- we record a value every TICKS/FREQUENCY counts.
tick_count = 0

-- local min/max calculation.
function vminmax_simple()
  dbg('\n'..table.concat(vs, ','))
  -- should not happen.
  if #vs < WINDOW_SIZE_SEC*FREQUENCY then
    dbg('  not enough.')
    return 0, nil
  end
  
  first, mid, last = vs[1], vs[math.ceil(#vs/2)], vs[#vs]
  dbg('\n  first='..first..', mid='..mid..', last='..last)
  -- too flat?
  if math.abs(mid-first) < MIN_DELTA_MPH or math.abs(mid-last) < MIN_DELTA_MPH then
    dbg('\n  too similar.')
    return 0, nil
  end
  -- maxima?
  if first < mid and last < mid then
    dbg('\n  new max='..mid)
    return maxId, mid
  end
  -- minima?
  if first > mid and last > mid then
    dbg('\n  new min='..mid)
    return minId, mid
  end
  dbg('\n  no hill.')
  return 0, nil
end
  
function tick_vminmax_simple()
  local speed = getChannel('Speed')
  tick_count = tick_count + 1
  -- skip if it's not yet time to record.
  if tick_count >= TICKS/FREQUENCY then
    tick_count = 0
    -- append, resize, update.
    table.insert(vs, speed)
    if #vs > WINDOW_SIZE_SEC*FREQUENCY then table.remove(vs, 1) end
    if #vs == WINDOW_SIZE_SEC*FREQUENCY then
      id, value = vminmax_simple()
      if id ~= 0 then
        setChannel(id, value)
      end
    end
  end
end
  
  
