local cli, _

-- ------- --
-- Helpers --
-- ------- --

local split = function(str, pat)
  local t = {}
  local fpat = "(.-)" .. pat
  local last_end = 1
  local s, e, cap = str:find(fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(t,cap)
    end
    last_end = e+1
    s, e, cap = str:find(fpat, last_end)
  end
  if last_end <= #str then
    cap = str:sub(last_end)
    table.insert(t, cap)
  end
  return t
end

local buildline = function(words, size, overflow)
  -- if overflow is set, a word longer than size, will overflow the size
  -- otherwise it will be chopped in line-length pieces
  local line = ""
  if string.len(words[1]) > size then
    -- word longer than line
    if overflow then
      line = words[1]
      table.remove(words, 1)
    else
      line = words[1]:sub(1, size)
      words[1] = words[1]:sub(size + 1, -1)
    end
  else
    while words[1] and (#line + string.len(words[1]) + 1 <= size) or (line == "" and #words[1] == size) do
      if line == "" then
        line = words[1]
      else
        line = line .. " " .. words[1]
      end
      table.remove(words, 1)
    end
  end
  return line, words
end

local wordwrap = function(str, size, pad, overflow)
  -- if overflow is set, then words longer than a line will overflow
  -- otherwise, they'll be chopped in pieces
  pad = pad or 0

  local line = ""
  local out = ""
  local padstr = string.rep(" ", pad)
  local words = split(str, ' ')

  while words[1] do
    line, words = buildline(words, size, overflow)
    if out == "" then
      out = padstr .. line
    else
        out = out .. "\n" .. padstr .. line
    end
  end

  return out
end

local function disect(key)
  -- characters allowed are a-z, A-Z, 0-9
  -- extended + values also allow; # @ _ + - 
  local k, ek, v
  local dummy
  -- if there is no comma, between short and extended, add one
  _, _, dummy = key:find("^%-([%a%d])[%s]%-%-")
  if dummy then key = key:gsub("^%-[%a%d][%s]%-%-", "-"..dummy..", --", 1) end
  -- for a short key + value, replace space by "="
  _, _, dummy = key:find("^%-([%a%d])[%s]")
  if dummy then key = key:gsub("^%-([%a%d])[ ]", "-"..dummy.."=", 1) end
  -- if there is no "=", then append one
  if not key:find("=") then key = key .. "=" end
  -- get value
  _, _, v = key:find(".-%=(.+)")
  -- get key(s), remove spaces
  key = split(key, "=")[1]:gsub(" ", "")
  -- get short key & extended key
  _, _, k = key:find("^%-([%a%d]+)")
  _, _, ek = key:find("%-%-(.+)$")
  if v == "" then v = nil end
  return k,ek,v
end


function cli_error(msg, noprint)
  local msg = cli.name .. ": error: " .. msg .. '; re-run with --help for usage.'
  if not noprint then print(msg) end
  return nil, msg
end

-- -------- --
-- CLI Main --
-- -------- --

cli = {
  name = "",
  required = {},
  optional = {},
  optargument = {maxcount = 0},
  colsz = { 0, 0 }, -- column width, help text. Set to 0 for auto detect
  maxlabel = 0,
}

--- Assigns the name of the program which will be used for logging.
function cli:set_name(name)
  self.name = name
end

-- Used internally to lookup an entry using either its short or expanded keys
function cli:__lookup(k, ek, t)
  t = t or self.optional
  local _
  for _,entry in ipairs(t) do
    if k  and entry.key == k then return entry end
    if ek and entry.expanded_key == ek then return entry end
  end

  return nil
end

--- Defines a required argument.
--- Required arguments have no special notation and are order-sensitive.
--- *Note:* the value will be stored in `args[@key]`.
--- *Aliases: `add_argument`*
---
--- ### Parameters
--- 1. **key**: the argument's "name" that will be displayed to the user
--- 1. **desc**: a description of the argument
---
--- ### Usage example
--- The following will parse the argument (if specified) and set its value in `args["root"]`:
--- `cli:add_arg("root", "path to where root scripts can be found")`
function cli:add_arg(key, desc)
  assert(type(key) == "string" and type(desc) == "string", "Key and description are mandatory arguments (Strings)")
  
  if self:__lookup(key, nil, self.required) then
    error("Duplicate argument: " .. key .. ", please rename one of them.")
  end

  table.insert(self.required, { key = key, desc = desc, value = nil })
  if #key > self.maxlabel then self.maxlabel = #key end
end

--- Defines an optional argument (or more than one).
--- There can be only 1 optional argument, and is has to be the last one on the argumentlist.
--- *Note:* the value will be stored in `args[@key]`. The value will be a 'string' if 'maxcount == 1',
--- or a table if 'maxcount > 1'
---
--- ### Parameters
--- 1. **key**: the argument's "name" that will be displayed to the user
--- 1. **desc**: a description of the argument
--- 1. **default**: *optional*; specify a default value (the default is "")
--- 1. **maxcount**: *optional*; specify the maximum number of occurences allowed (default is 1)
---
--- ### Usage example
--- The following will parse the argument (if specified) and set its value in `args["root"]`:
--- `cli:add_arg("root", "path to where root scripts can be found", "", 2)`
--- The value returned will be a table with at least 1 entry and a maximum of 2 entries
function cli:optarg(key, desc, default, maxcount)
  assert(type(key) == "string" and type(desc) == "string", "Key and description are mandatory arguments (Strings)")
  default = default or ""
  assert(type(default) == "string", "Default value must either be omitted or be a string")
  maxcount = maxcount or 1
  maxcount = tonumber(maxcount)
  assert(maxcount and maxcount>0 and maxcount<1000,"Maxcount must be a number from 1 to 999")

  self.optargument = { key = key, desc = desc, default = default, maxcount = maxcount, value = nil }
  if #key > self.maxlabel then self.maxlabel = #key end
end

--- Defines an option.
--- Optional arguments can use 3 different notations, and can accept a value.
--- *Aliases: `add_option`*
---
--- ### Parameters
--- 1. **key**: the argument identifier, can be either `-key`, or `-key, --expanded-key`:
--- if the first notation is used then a value can be defined after a space (`'-key VALUE'`),
--- if the 2nd notation is used then a value can be defined after an `=` (`'-key, --expanded-key=VALUE'`).
--- As a final option it is possible to only use the expanded key (eg. `'--expanded-key'`) both with and
--- without a value specified.
--- 1. **desc**: a description for the argument to be shown in --help
--- 1. **default**: *optional*; specify a default value (the default is "")
---
--- ### Usage example
--- The following option will be stored in `args["i"]` and `args["input"]` with a default value of `my_file.txt`:
--- `cli:add_option("-i, --input=FILE", "path to the input file", "my_file.txt")`
function cli:add_opt(key, desc, default)

  -- parameterize the key if needed, possible variations:
  -- 1. -key
  -- 2. -key VALUE
  -- 3. -key, --expanded
  -- 4. -key, --expanded=VALUE
  -- 5. -key --expanded
  -- 6. -key --expanded=VALUE
  -- 7. --expanded
  -- 8. --expanded=VALUE

  assert(type(key) == "string" and type(desc) == "string", "Key and description are mandatory arguments (Strings)")
  assert(type(default) == "string" or default == nil or default == false, "Default argument: expected a string or nil")

  local k, ek, v = disect(key)
  
  if default == false and v ~= nil then
    error("A flag type option cannot have a value set; " .. key)
  end

  -- guard against duplicates
  if self:__lookup(k, ek) then
    error("Duplicate option: " .. (k or ek) .. ", please rename one of them.")
  end

  -- set defaults
  if v == nil then default = false end   -- no value, so its a flag
  if default == nil then default = "" end
  
  -- below description of full entry record, nils included for reference
  local entry = {
    key = k,
    expanded_key = ek,
    desc = desc,
    default = default,
    label = key,
    flag = (default == false),
    value = default,
  }

  table.insert(self.optional, entry)
  if #key > self.maxlabel then self.maxlabel = #key end
  
end

--- Define a flag argument (on/off). This is a convenience helper for cli.add_opt().
--- See cli.add_opt() for more information.
---
--- ### Parameters
-- 1. **key**: the argument's key
-- 1. **desc**: a description of the argument to be displayed in the help listing
function cli:add_flag(key, desc)
  self:add_opt(key, desc, false)
end

--- Parses the arguments found in #arg and returns a table with the populated values.
--- (NOTE: after succesful parsing, the module will delete itself to free resources)
--- *Aliases: `parse_args`*
---
--- ### Parameters
--- 1. **noprint**: set this flag to prevent any information (error or help info) from being printed
--- 1. **dump**: set this flag to dump the parsed variables for debugging purposes, alternatively 
--- set the first option to --__DEBUG__ (option with 2 trailing and leading underscores) to dump at runtime.
---
--- ### Returns
--- 1. a table containing the keys specified when the arguments were defined along with the parsed values,
--- or nil + error message (--help option is considered an error and returns nil + help message)
function cli:parse(arg, noprint, dump)
  local args = {}
  for k,v in pairs(arg) do args[k] = v end  -- copy global args local

  -- starts with --help? display the help listing and abort!
  if args[1] and (args[1] == "--help" or args[1] == "-h") then
    return nil, self:print_help(noprint)
  end

  -- starts with --__DUMP__; set dump to true to dump the parsed arguments
  if dump == nil then 
    if args[1] and args[1] == "--__DUMP__" then
      dump = true
      table.remove(args, 1)  -- delete it to prevent further parsing
    end
  end
  
  while args[1] do
    local entry = nil
    local opt = args[1]
    local _, optpref, optkey, optkey2, optval
    _, _, optpref, optkey = opt:find("^(%-[%-]?)(.+)")   -- split PREFIX & NAME+VALUE
    if optkey then
      _, _, optkey2, optval = optkey:find("(.-)[=](.+)")       -- split value and key
      if optval then
        optkey = optkey2
      end
    end

    if not optpref then
      break   -- no optional prefix, so options are done
    end
    
    if optkey:sub(-1,-1) == "=" then  -- check on a blank value eg. --insert=
      optval = ""
      optkey = optkey:sub(1,-2)
    end
    
    if optkey then
      entry = 
        self:__lookup(optpref == '-' and optkey or nil,
                      optpref == '--' and optkey or nil)
    end

    if not optkey or not entry then
      local option_type = optval and "option" or "flag"
      return cli_error("unknown/bad " .. option_type .. "; " .. opt, noprint)
    end

    table.remove(args,1)
    if optpref == "-" then
      if optval then
        return cli_error("short option does not allow value through '='; "..opt, noprint)
      end
      if entry.flag then
        optval = true
      else
        -- not a flag, value is in the next argument
        optval = args[1]
        table.remove(args, 1)
      end
    elseif optpref == "--" and (not optval) then
      -- using the expanded-key notation with no value, it is possibly a flag
      entry = self:__lookup(nil, optkey)
      if entry then
        if entry.flag then
          optval = true
        else
          return cli_error("option --" .. optkey .. " requires a value to be set", noprint)
        end
      else
        return cli_error("unknown/bad flag; " .. opt, noprint)
      end
    end
    entry.value = optval
  end

  -- missing any required arguments, or too many?
  if #args < #self.required or #args > #self.required + self.optargument.maxcount then
    if self.optargument.maxcount > 0 then
      return cli_error("bad number of arguments; " .. #self.required .."-" .. #self.required + self.optargument.maxcount .. " argument(s) must be specified, not " .. #args, noprint)
    else
      return cli_error("bad number of arguments; " .. #self.required .. " argument(s) must be specified, not " .. #args, noprint)
    end
  end

  -- deal with required args here
  for i, entry in ipairs(self.required) do
    entry.value = args[1]
    table.remove(args, 1)
  end
  -- deal with the last optional argument
  while args[1] do
    if self.optargument.maxcount > 1 then
      self.optargument.value = self.optargument.value or {}
      table.insert(self.optargument.value, args[1])
    else
      self.optargument.value = args[1]
    end
    table.remove(args,1)
  end
  -- if necessary set the defaults for the last optional argument here
  if self.optargument.maxcount > 0 and not self.optargument.value then
    if self.optargument.maxcount == 1 then
      self.optargument.value = self.optargument.default
    else
      self.optargument.value = { self.optargument.default }
    end
  end
  
  -- populate the results table
  local results = {}
  if self.optargument.maxcount > 0 then 
    results[self.optargument.key] = self.optargument.value
  end
  for _, entry in pairs(self.required) do
    results[entry.key] = entry.value
  end
  for _, entry in pairs(self.optional) do
    if entry.key then results[entry.key] = entry.value end
    if entry.expanded_key then results[entry.expanded_key] = entry.value end
  end

  if dump then
    print("\n======= Provided command line =============")
    print("\nNumber of arguments: ", #arg)
    for i,v in ipairs(arg) do -- use gloabl 'arg' not the modified local 'args'
      print(string.format("%3i = '%s'", i, v))
    end
  
    print("\n======= Parsed command line ===============")
    if #self.required > 0 then print("\nArguments:") end
    for i,v in ipairs(self.required) do
      print("  " .. v.key .. string.rep(" ", self.maxlabel + 2 - #v.key) .. " => '" .. v.value .. "'")
    end
    
    if self.optargument.maxcount > 0 then 
      print("\nOptional arguments:")
      print("  " .. self.optargument.key .. "; allowed are " .. tostring(self.optargument.maxcount) .. " arguments")
      if self.optargument.maxcount == 1 then
          print("  " .. self.optargument.key .. string.rep(" ", self.maxlabel + 2 - #self.optargument.key) .. " => '" .. self.optargument.key .. "'")
      else
        for i = 1, self.optargument.maxcount do
          if self.optargument.value[i] then
            print("  " .. tostring(i) .. string.rep(" ", self.maxlabel + 2 - #tostring(i)) .. " => '" .. tostring(self.optargument.value[i]) .. "'")
          end
        end
      end
    end
    
    if #self.optional > 0 then print("\nOptional parameters:") end
    local doubles = {}
    for _, v in pairs(self.optional) do 
      if not doubles[v] then
        local m = v.value
        if type(m) == "string" then
          m = "'"..m.."'"
        else
          m = tostring(m) .." (" .. type(m) .. ")"
        end
        print("  " .. v.label .. string.rep(" ", self.maxlabel + 2 - #v.label) .. " => " .. m)
        doubles[v] = v
      end
    end
    print("\n===========================================\n\n")
    return cli_error("commandline dump created as requested per '--__DUMP__' option", noprint)
  end
  
  if not _TEST then
    -- cleanup entire module, as it's single use
    -- remove from package.loaded table to enable the module to
    -- garbage collected.
    for k, v in pairs(package.loaded) do
      if v == cli then
        package.loaded[k] = nil
        break
      end
    end
    -- clear table in case user holds on to module table
    for k, _ in pairs(cli) do
      cli[k] = nil
    end
  end
  
  return results
end

--- Prints the USAGE heading.
---
--- ### Parameters
 ---1. **noprint**: set this flag to prevent the line from being printed
---
--- ### Returns
--- 1. a string with the USAGE message.
function cli:print_usage(noprint)
  -- print the USAGE heading
  local msg = "Usage: " .. tostring(self.name)
  if self.optional[1] then
    msg = msg .. " [OPTIONS] "
  end
  if self.required[1] then
    for _,entry in ipairs(self.required) do
      msg = msg .. " " .. entry.key .. " "
    end
  end
  if self.optargument.maxcount == 1 then
    msg = msg .. " [" .. self.optargument.key .. "]"
  elseif self.optargument.maxcount == 2 then
    msg = msg .. " [" .. self.optargument.key .. "-1 [" .. self.optargument.key .. "-2]]"
  elseif self.optargument.maxcount > 2 then
    msg = msg .. " [" .. self.optargument.key .. "-1 [" .. self.optargument.key .. "-2 [...]]]"
  end

  if not noprint then print(msg) end
  return msg
end


--- Prints the HELP information.
---
--- ### Parameters
--- 1. **noprint**: set this flag to prevent the information from being printed
---
--- ### Returns
--- 1. a string with the HELP message.
function cli:print_help(noprint)

  local msg = self:print_usage(true) .. "\n"
  local col1 = self.colsz[1]
  local col2 = self.colsz[2]
  if col1 == 0 then col1 = cli.maxlabel end
  col1 = col1 + 3     --add margins
  if col2 == 0 then col2 = 72 - col1 end
  if col2 <10 then col2 = 10 end
  
  local append = function(label, desc)
      label = "  " .. label .. string.rep(" ", col1 - (#label + 2))
      desc = wordwrap(desc, col2)   -- word-wrap
      desc = desc:gsub("\n", "\n" .. string.rep(" ", col1)) -- add padding
      
      msg = msg .. label .. desc .. "\n"
  end
  
  if self.required[1] then
    msg = msg .. "\nARGUMENTS: \n"
    for _,entry in ipairs(self.required) do
      append(entry.key, entry.desc .. " (required)")
    end
  end
  
  if self.optargument.maxcount >0 then
    append(self.optargument.key, self.optargument.desc .. " (optional, default: " .. self.optargument.default .. ")")
  end

  if self.optional[1] then
    msg = msg .. "\nOPTIONS: \n"

    for _,entry in ipairs(self.optional) do
      local desc = entry.desc
      if not entry.flag and entry.default then
        desc = desc .. " (default: " .. entry.default .. ")"
      end
      append(entry.label, desc)
    end
  end

  if not noprint then print(msg) end
  return msg
end

--- Sets the amount of space allocated to the argument keys and descriptions in the help listing.
--- The sizes are used for wrapping long argument keys and descriptions.
--- ### Parameters
--- 1. **key_cols**: the number of columns assigned to the argument keys, set to 0 to auto detect (default: 0)
--- 1. **desc_cols**: the number of columns assigned to the argument descriptions, set to 0 to auto set the total width to 72 (default: 0)
function cli:set_colsz(key_cols, desc_cols)
  self.colsz = { key_cols or self.colsz[1], desc_cols or self.colsz[2] }
end


-- finalize setup
cli._COPYRIGHT   = "Copyright (C) 2011-2012 Ahmad Amireh"
cli._LICENSE     = "The code is released under the MIT terms. Feel free to use it in both open and closed software as you please."
cli._DESCRIPTION = "Commandline argument parser for Lua"
cli._VERSION     = "cliargs 2.0-1"

-- aliases
cli.add_argument = cli.add_arg
cli.add_option = cli.add_opt
cli.parse_args = cli.parse    -- backward compatibility

-- test aliases for local functions
if _TEST then
  cli.split = split
  cli.wordwrap = wordwrap
end

return cli
