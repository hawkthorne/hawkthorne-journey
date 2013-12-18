#!/usr/bin/env lua

--[[

Usage: lualint [-r|-s] filename.lua [ [-r|-s] [filename.lua] ...]

lualint performs static analysis of Lua source code's usage of global
variables.. It uses luac's bytecode listing. It reports all accesses
to undeclared global variables, which catches many typing errors in
variable names. For example:

  local really_aborting
  local function abort() os.exit(1) end
  if not os.getenv("HOME") then
    realy_aborting = true
    abortt()
  end

reports:

  /tmp/example.lua:4: *** global SET of realy_aborting
  /tmp/example.lua:5: global get of abortt

It is primarily designed for use on LTN7-style modules, where each
source file only exports one global symbol. (A module contained in
the file "foobar.lua" should only export the symbol "foobar".)

A "relaxed" mode is available for source not in LTN7 style. It only
detects reads from globals that were never set. The switch "-r" puts
lualint into relaxed mode for the following files; "-s" switches back
to strict.

Required packages are tracked, although not recursively. If you call
"myext.process()" you should require "myext", and not depend on other
dependencies to load it. LUA_PATH is followed as usual to find
requirements.

Some (not strictly LTN7) modules may wish to export other variables
into the global environment. To do so, use the declare function:

  declare "xpairs"
  function xpairs(node)
    [...]

Similarly, to quiet warnings about reading global variables you are
aware may be unavailable:

  lint_ignore "lua_fltk_version"
  if lua_fltk_version then print("fltk loaded") end

One way of defining these is in a module "declare.lua":

  function declare(s)
  end
  declare "lint_ignore"
  function lint_ignore(s)
  end

(Setting declare is OK, because it's in the "declare" module.) These
functions don't have to do anything, or in fact actually exist! They
can be in dead code:

  if false then declare "xpairs" end
    
This is because lualint only performs a rather primitive and cursory
scan of the bytecode. Perhaps declarations should only be allowed in
the main chunk.

TODO:

The errors don't come out in any particular order.

Should switch to Rici's parser, which should do a much better job of
this, and allow detection of some other common situations.

CREDITS:

Jay Carlson (nop@nop.com)

This is all Ben Jackson's (ben@ben.com) fault, who did some similar
tricks in MOO.
]]


local function Set(l)
local t = {}
for _,v in ipairs(l) do
t[v] = true
end
return t
end

local ignoreget = Set{
"LUA_PATH", "_G", "_LOADED", "_TRACEBACK", "_VERSION", "__pow", "arg",
"assert", "collectgarbage", "coroutine", "debug", "dofile", "error",
"gcinfo", "getfenv", "getmetatable", "io", "ipairs", "loadfile",
"loadlib", "loadstring", "math", "newproxy", "next", "os", "pairs",
"pcall", "print", "rawequal", "rawget", "rawset", "require",
"setfenv", "setmetatable", "string", "table", "tonumber", "tostring",
"type", "unpack", "xpcall", "love", "null",
}

local builtins = Set{
  "love.event", "love.filesystem", 
  "socket.http", "socket.url", "ltn12",
}

local function fileexists(fname)
local f = io.open(fname)
if f then
f:close()
return true
else
return false
end
end

-- borrowed from LTN11
local function locate(name)

local paths = ""

if type(LUA_PATH) == "string" then
-- Use the LUA_PATH variable
paths = LUA_PATH
else
-- Try to get the LUA_PATH env variable
local env_lua_path = os.getenv "LUA_PATH"
if type(env_lua_path) == "string" then
paths = env_lua_path
end
end

-- Add current directory
paths = paths .. ";./?.lua"

-- Add src directory
paths = paths .. ";src/?.lua"

-- Add init directory
paths = paths .. ";src/?/init.lua"

for path in string.gfind(paths, "[^;]+") do
-- Construct full filename from path, module name and file extension
path = string.gsub(path, "?", name)

if fileexists(path) then
return path
end
end
return nil
end


local function scanfile(filename)
local modules = {}
local declared = {}
local lint_ignored = {}
local refs = {}
local saw_last = nil

local context, curfunc

if not fileexists(filename) then
return nil, "file "..filename.." does not exist"
end

-- Run once to see if it parses correctly
if not os.execute("luac -o lualint.tmp \"" .. filename .. "\"") then
return nil, "file "..filename.." did not successfully parse"
end

if not fileexists("lualint.tmp") then
return nil, "file "..filename.." did not successfully parse"
end

assert(os.remove("lualint.tmp"))

local bc = assert(io.popen("luac -l -p \"" .. filename .. "\""))
for line in bc:lines() do
-- main <examples/xhtml2wiki.lua:0> (64 instructions, 256 bytes at 0x805c1a0)
-- function <examples/xhtml2wiki.lua:13> (6 instructions, 24 bytes at 0x805c438)
local found, _, type, fname = string.find(line, "(%w+) <([^>]+)>")
if found then
if context == "main" then fname="*MAIN*" end
curfunc = fname
end
-- print("sawlast", saw_last)
-- 2 [1] LOADK 1 1 ; "lazytree"
local found, _, constname = string.find(line, '%sLOADK .-;%s"(.-)"')
    if saw_last and found then
      if saw_last == "require" then
        -- print("require", constname)
        table.insert(modules, constname)
      elseif saw_last == "declare" then
        -- print("declare", constname)
        table.insert(declared, constname)
      elseif saw_last == "lint_ignore" then
        lint_ignored[constname] = true
      end
    end
    
    -- 4	[2]	GETGLOBAL	0 0	; require
    local found, _, lineno, instr, gname = string.find(line, "%[(%d+)%]%s+([SG]ETGLOBAL).-; (.+)")
    if found then
      local t = refs[curfunc] or {SETGLOBAL={n=0}, GETGLOBAL={n=0}}
      local err = {name=gname, lineno=lineno}
      table.insert(t[instr], err)
      refs[curfunc] = t
      saw_last = gname
    else
      saw_last = nil
    end
  end
  bc:close()
  return modules, declared, lint_ignored, refs
end

local found_sets = false
local found_gets = false
local parse_failed = false
local import_failed = false
-- print("args", arg[1])

-- Used to cache all printed output
local g_output = {}
local function lint_output(filename, row, description)
   -- Helper to gather all errors
   local file_info = nil
   if g_output[filename] == nil then
      file_info = {}
   else
      file_info = g_output[filename]
   end
   
   local error_info = {row, description}
   table.insert(file_info, error_info)
   g_output[filename] = file_info
end

local function print_lint_output()
   -- Prints all errors sorted by row number

   local function row_compare(a,b)
      -- a[1] and b[1] contains the row numbers for the errors
      return tonumber(a[1]) < tonumber(b[1])
   end

   for file,info in pairs(g_output) do
      table.sort(info, row_compare)
      for k,error in pairs(info) do
-- error[1] is the row and error[2] is the description
       print(string.format("%s:%d: %s", file, error[1], error[2]))
      end
   end
end

local function lint(filename, relaxed)
  local modules, declared, lint_ignored, refs = scanfile(filename)

  if not modules then
    lint_output(filename, 1, string.format("*** could not parse: %s ",declared))
    parse_failed = true
    return
  end
  
  local imported_declare_set = {}
  for i,module in ipairs(modules) do
    local path = locate(module)
    if not path then
      if not builtins[module] and not ignoreget[module] then
        lint_output(filename, 1, string.format("*** could not find imported module %s ", module))
        import_failed = true
      end
    else
      local success, imported_declare, _, _ = scanfile(path)
      if not success then
        lint_output(path, 1, string.format("*** could not parse import: %s ", imported_declare))
        import_failed = true
      else
        for i,declared in ipairs(imported_declare) do
          imported_declare_set[declared] = true
        end
      end
    end
  end
    
  local moduleset = Set(modules)
  local declaredset = Set(declared)
  
  local self_name = nil
  do
    local _
    if string.find(filename, "/") then
      _, _, self_name = string.find(filename, ".-/(%w+)%.lua")
    else
      _,_,self_name = string.find(filename, "(%w+)%.lua")
    end
  end
  -- print("selfname", self_name)

  local was_set = {}
  
  local function will_warn_for(name)
    if relaxed and was_set[name] then
      return false
    end
    if name == self_name or
      lint_ignored[name] or
      ignoreget[name] or
      moduleset[name] or
      declaredset[name] or
      imported_declare_set[name] then
      return false
    end
    return true
  end

  for f,t in pairs(refs) do
    for _,r in ipairs(t.SETGLOBAL) do
      if r.name ~= self_name and not declaredset[r.name] then
        was_set[r.name] = true
        if not relaxed then
          lint_output(filename, r.lineno, string.format("*** global SET of %s", r.name))
          found_sets = true
        end
      end
    end
  end

  for f,t in pairs(refs) do
    for _,r in ipairs(t.GETGLOBAL) do
      if will_warn_for(r.name) then
        lint_output(filename, r.lineno, string.format("*** global get of %s", r.name))
        found_gets = true
      end
    end
  end
end

if arg.n == 0 then
  print("usage: lualint filename.lua [filename.lua ...]")
  os.exit(1)
end

local relaxed_mode = false

for i,v in ipairs(arg) do
  if v == "-r" then
    relaxed_mode = true
  elseif v == "-s" then
    relaxed_mode = false
  else
    lint(v, relaxed_mode)
  end
end

-- Prints all of the errors per file - sorted by row number.
print_lint_output()

if parse_failed then
  os.exit(3)
elseif import_failed then
  os.exit(1)
elseif found_sets then
  os.exit(2)
elseif found_gets then
  os.exit(1)
else
  os.exit(0)
end
