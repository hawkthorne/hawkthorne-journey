-- module will not return anything, only register formatters with the main assert engine
local assert = require('luassert.assert')

local function fmt_string(arg)
  if type(arg) == "string" then
    return string.format("(string) '%s'", arg)
  end
end

local function fmt_number(arg)
  if type(arg) == "number" then
    return string.format("(number) %s", tostring(arg))
  end
end

local function fmt_boolean(arg)
  if type(arg) == "boolean" then
    return string.format("(boolean) %s", tostring(arg))
  end
end

local function fmt_nil(arg)
  if type(arg) == "nil" then
    return "(nil)"
  end
end

local function fmt_table(arg)
  local tmax = assert:get_parameter("TableFormatLevel")
  local ft
  ft = function(t, l)
    local result = ""
    for k, v in pairs(t) do
      if type(v) == "table" then
        if l < tmax or tmax < 0 then
          result = result .. string.format(string.rep(" ",l * 2) .. "[%s] = {\n%s }\n", tostring(k), tostring(ft(v, l + 1):sub(1,-2)))
        else
          result = result .. string.format(string.rep(" ",l * 2) .. "[%s] = { ... more }\n", tostring(k))
        end
      else
        if type(v) == "string" then v = "'"..v.."'" end
        result = result .. string.format(string.rep(" ",l * 2) .. "[%s] = %s\n", tostring(k), tostring(v))
      end
    end
    return result
  end
  if type(arg) == "table" then
    local result
    if tmax == 0 then
      if next(arg) then
        result = "(table): { ... more }"
      else
        result = "(table): { }"
      end
    else
      result = "(table): {\n" .. ft(arg, 1):sub(1,-2) .. " }\n"
      result = result:gsub("{\n }\n", "{ }\n") -- cleanup empty tables
      result = result:sub(1,-2)                -- remove trailing newline
    end
    return result
  end
end

local function fmt_function(arg)
  if type(arg) == "function" then
    local debug_info = debug.getinfo(arg)
    return string.format("%s @ line %s in %s", tostring(arg), tostring(debug_info.linedefined), tostring(debug_info.source))
  end
end

local function fmt_userdata(arg)
  if type(arg) == "userdata" then
    return string.format("(userdata) '%s'", tostring(arg))
  end
end

assert:add_formatter(fmt_string)
assert:add_formatter(fmt_number)
assert:add_formatter(fmt_boolean)
assert:add_formatter(fmt_nil)
assert:add_formatter(fmt_table)
assert:add_formatter(fmt_function)
assert:add_formatter(fmt_userdata)
-- Set default table display depth for table formatter
assert:set_parameter("TableFormatLevel", 3)
