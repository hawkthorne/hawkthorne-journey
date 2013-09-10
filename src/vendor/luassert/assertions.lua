-- module will not return anything, only register assertions with the main assert engine

-- assertions take 2 parameters;
-- 1) state
-- 2) arguments list. The list has a member 'n' with the argument count to check for trailing nils
-- returns; boolean; whether assertion passed

local assert = require('luassert.assert')
local util = require ('luassert.util')
local s = require('say')

local function unique(state, arguments)
  local list = arguments[1]
  local deep = arguments[2]
  for k,v in pairs(list) do
    for k2, v2 in pairs(list) do
      if k ~= k2 then
        if deep and util.deepcompare(v, v2, true) then
          return false
        else
          if v == v2 then
            return false
          end
        end
      end
    end
  end
  return true
end

local function equals(state, arguments)
  local argcnt = arguments.n
  assert(argcnt > 1, s("assertion.internal.argtolittle", { "equals", 2, tostring(argcnt) }))
  for i = 2,argcnt  do
    if arguments[1] ~= arguments[i] then
      -- switch arguments for proper output message
      util.tinsert(arguments, 1, arguments[i])
      util.tremove(arguments, i + 1)
      return false
    end
  end
  return true
end

local function same(state, arguments)
  local argcnt = arguments.n
  assert(argcnt > 1, s("assertion.internal.argtolittle", { "same", 2, tostring(argcnt) }))
  local prev = nil
  for i = 2,argcnt  do
    if type(arguments[1]) == 'table' and type(arguments[i]) == 'table' then
      if not util.deepcompare(arguments[1], arguments[i], true) then
        -- switch arguments for proper output message
        util.tinsert(arguments, 1, arguments[i])
        util.tremove(arguments, i + 1)
        return false
      end
    else
      if arguments[1] ~= arguments[i] then
        -- switch arguments for proper output message
        util.tinsert(arguments, 1, arguments[i])
        util.tremove(arguments, i + 1)
        return false
      end
    end
  end
  return true
end

local function truthy(state, arguments)
  return arguments[1] ~= false and arguments[1] ~= nil
end

local function falsy(state, arguments)
  return not truthy(state, arguments)
end

local function has_error(state, arguments)
  local func = arguments[1]
  local err_expected = arguments[2]
  
  assert(util.callable(func), s("assertion.internal.badargtype", { "error", "function, or callable object", type(func) }))
  local err_actual = nil
  --must swap error functions to get the actual error message
  local old_error = error
  error = function(err)
    err_actual = err
    return old_error(err)
  end
  local status = pcall(func)
  error = old_error
  local val = not status and (err_expected == nil or same(state, {err_expected, err_actual, ["n"] = 2}))

  return val
end

local function is_true(state, arguments)
  table.insert(arguments, 2, true)
  arguments.n = arguments.n + 1
  return arguments[1] == arguments[2]
end

local function is_false(state, arguments)
  table.insert(arguments, 2, false)
  arguments.n = arguments.n + 1
  return arguments[1] == arguments[2]
end

local function is_type(state, arguments, etype)
  table.insert(arguments, 2, "type " .. etype)
  arguments.nofmt = arguments.nofmt or {}
  arguments.nofmt[2] = true
  arguments.n = arguments.n + 1
  return arguments.n > 1 and type(arguments[1]) == etype
end

local function returned_arguments(state, arguments)
  arguments[1] = tostring(arguments[1])
  arguments[2] = tostring(arguments.n - 1)
  arguments.nofmt = arguments.nofmt or {}
  arguments.nofmt[1] = true
  arguments.nofmt[2] = true
  if arguments.n < 2 then arguments.n = 2 end
  return arguments[1] == arguments[2]
end

local function is_boolean(state, arguments)  return is_type(state, arguments, "boolean")  end
local function is_number(state, arguments)   return is_type(state, arguments, "number")   end
local function is_string(state, arguments)   return is_type(state, arguments, "string")   end
local function is_table(state, arguments)    return is_type(state, arguments, "table")    end
local function is_nil(state, arguments)      return is_type(state, arguments, "nil")      end
local function is_userdata(state, arguments) return is_type(state, arguments, "userdata") end
local function is_function(state, arguments) return is_type(state, arguments, "function") end
local function is_thread(state, arguments)   return is_type(state, arguments, "thread")   end

assert:register("assertion", "true", is_true, "assertion.same.positive", "assertion.same.negative")
assert:register("assertion", "false", is_false, "assertion.same.positive", "assertion.same.negative")
assert:register("assertion", "boolean", is_boolean, "assertion.same.positive", "assertion.same.negative")
assert:register("assertion", "number", is_number, "assertion.same.positive", "assertion.same.negative")
assert:register("assertion", "string", is_string, "assertion.same.positive", "assertion.same.negative")
assert:register("assertion", "table", is_table, "assertion.same.positive", "assertion.same.negative")
assert:register("assertion", "nil", is_nil, "assertion.same.positive", "assertion.same.negative")
assert:register("assertion", "userdata", is_userdata, "assertion.same.positive", "assertion.same.negative")
assert:register("assertion", "function", is_function, "assertion.same.positive", "assertion.same.negative")
assert:register("assertion", "thread", is_thread, "assertion.same.positive", "assertion.same.negative")
assert:register("assertion", "returned_arguments", returned_arguments, "assertion.returned_arguments.positive", "assertion.returned_arguments.negative")

assert:register("assertion", "same", same, "assertion.same.positive", "assertion.same.negative")
assert:register("assertion", "equals", equals, "assertion.equals.positive", "assertion.equals.negative")
assert:register("assertion", "equal", equals, "assertion.equals.positive", "assertion.equals.negative")
assert:register("assertion", "unique", unique, "assertion.unique.positive", "assertion.unique.negative")
assert:register("assertion", "error", has_error, "assertion.error.positive", "assertion.error.negative")
assert:register("assertion", "errors", has_error, "assertion.error.positive", "assertion.error.negative")
assert:register("assertion", "truthy", truthy, "assertion.truthy.positive", "assertion.truthy.negative")
assert:register("assertion", "falsy", falsy, "assertion.falsy.positive", "assertion.falsy.negative")
