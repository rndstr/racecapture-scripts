--------------------------------------------
-- dump: Dumps configured can messages.

-- Signals to reverse engineer.
local signals = {
  {name="ABSASC", id=371},
}

-- Accompanying values to compare to.
local channels = {
  -- Newly calculated basd on signal.
  "ABS", "ASC", "BrakeState",
  -- Known good values to compare to.
  "Speed", "Brake", "BrakeF", "BrakeR",
}

function dumpSignals()
  repeat 
    id, ext, data = rxCAN(0, 1000)
    if id ~= nil then
      for unused, signal in pairs(signals) do 
        if signal.id == id then
          print('\n[' ..id ..']'..signal.name..', ')
          for i = 1,#data do
            print(data[i] ..', ')
          end
        end
      end
    end
  until id == nil
end

function dumpChannels()
  for unused, channel in ipairs(channels) do
    val = getChannel(channel)
    print('\n'..channel..', ')
    if val == nil then print('nil')
    else print(val)
    end
  end
end
 
function onTick()
  println('----- SIGNALS -----')
  dumpSignals()
  println('----- CHANNELS -----')
  dumpChannels()
  println('----- END -----')
end

setTickRate(30)
