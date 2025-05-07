ctid = addChannel("CoolantTemp", 10, 0)
otid = addChannel("OilTemp", 10, 0)

mocks = {
  {id=ctid, from=100, to=280, step=1},
  {id=otid, from=100, to=280, step=-1}
}

function tick_mock()
  for unused, mock in pairs(mocks) do
    local val = getChannel(mock.id)
    if val ~= nil then
      if val < mock.from then val = mock.to end
      if val > mock.to then val = mock.from end
      val = val + mock.step
      setChannel(mock.id, val)
    end
  end
end
