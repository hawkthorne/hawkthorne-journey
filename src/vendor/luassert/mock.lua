-- module will return a single mock function, no table nor register any assertions
local spy = require 'luassert.spy'
local stub = require 'luassert.stub'

local function mock(object, dostub, func, self, key)
  local data_type = type(object)
  if data_type == "table" then
    if spy.is_spy(object) then
      -- this table is a function already wrapped as a spy, so nothing to do here
    else
      for k,v in pairs(object) do
        object[k] = mock(v, dostub, func, object, k)
      end
    end
  elseif data_type == "function" then
    if dostub then
      return stub(self, key, func)
    elseif self==nil then
      return spy.new(object)
    else
      return spy.on(self, key)
    end
  end
  return object
end

return mock
