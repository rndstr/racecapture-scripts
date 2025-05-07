ctid = addChannel("CoolantTemp", 10, 0)
otid = addChannel("OilTemp", 10, 0)
tid = addChannel("TPS", 10, 0)
bid = addChannel("Brake", 10, 0)

mocks = {
  {id=ctid, from=100, to=280, step=1},
  {id=otid, from=100, to=280, step=-1},
  {id=tid, from=0, to=100, step=1},
  {id=bid, from=0, to=100, step=2},
}

function tick_mock()
  for unused, mock in pairs(mocks) do
    local val = getChannel(mock.id)
    if val ~= nil then
      val = val + mock.step
      if val < mock.from then val = mock.to end
      if val > mock.to then val = mock.from end
      setChannel(mock.id, val)
    end
  end
end
