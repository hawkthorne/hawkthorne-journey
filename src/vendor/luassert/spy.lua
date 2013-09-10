-- module will return spy table, and register its assertions with the main assert engine
local assert = require('luassert.assert')
local util = require('luassert.util')

-- Spy metatable
local spy_mt = {
  __call = function(self, ...)
    local arguments = {...}
    arguments.n = select('#',...)  -- add argument count for trailing nils
    table.insert(self.calls, arguments)
    return self.callback(...)
  end }

local spy   -- must make local before defining table, because table contents refers to the table (recursion)
spy = {
  new = function(callback)
    if not util.callable(callback) then
      error("Cannot spy on type '" .. type(callback) .. "', only on functions or callable elements", 2)
    end
    local s = setmetatable(
    {
      calls = {},
      callback = callback,
      
      target_table = nil, -- these will be set when using 'spy.on'
      target_key = nil,
      
      revert = function(self)
        if not self.reverted then
          if self.target_table and self.target_key then
            self.target_table[self.target_key] = self.callback
          end
          self.reverted = true
        end
        return self.callback
      end,
      
      called = function(self, times)
        if times then
          return (#self.calls == times), #self.calls
        end

        return (#self.calls > 0), #self.calls
      end,

      called_with = function(self, args)
        for _,v in ipairs(self.calls) do
          if util.deepcompare(v, args) then
            return true
          end
        end
        return false
      end
    }, spy_mt)
    assert:add_spy(s)  -- register with the current state
    return s
  end,

  is_spy = function(object)
    return type(object) == "table" and getmetatable(object) == spy_mt
  end,
    
  on = function(target_table, target_key)
    local s = spy.new(target_table[target_key])
    target_table[target_key] = s
    -- store original data 
    s.target_table = target_table
    s.target_key = target_key
    
    return s
  end
}

local function set_spy(state)
end

local function called_with(state, arguments)
  if rawget(state, "payload") and rawget(state, "payload").called_with then
    return state.payload:called_with(arguments)
  else
    error("'called_with' must be chained after 'spy(aspy)'")
  end
end

local function called(state, arguments)
  local num_times = arguments[1]
  if state.payload and type(state.payload) == "table" and state.payload.called then
    local result, count = state.payload:called(num_times)
    arguments[1] = tostring(arguments[1])
    table.insert(arguments, 2, tostring(count))
    arguments.n = arguments.n + 1
    arguments.nofmt = arguments.nofmt or {}
    arguments.nofmt[1] = true
    arguments.nofmt[2] = true
    return result
  elseif state.payload and type(state.payload) == "function" then
    error("When calling 'spy(aspy)', 'aspy' must not be the original function, but the spy function replacing the original")
  else
    error("'called_with' must be chained after 'spy(aspy)'")
  end
end

assert:register("modifier", "spy", set_spy)
assert:register("assertion", "called_with", called_with, "assertion.called_with.positive", "assertion.called_with.negative")
assert:register("assertion", "called", called, "assertion.called.positive", "assertion.called.negative")

return spy
