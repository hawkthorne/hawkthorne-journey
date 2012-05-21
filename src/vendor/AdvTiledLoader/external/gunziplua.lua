-- bin.gunzip
-- gunzip command partially reimplemented in Lua.
--
-- Note: this does not implement all of the GNU
-- gunzip[1] command-line options and might have
-- slightly different behavior.
--
-- This is designed to be called from a shell script:
--
--   #!/bin/env lua
--   package.path = '?.lua;' .. package.path
--   require 'dmlib.command_gunzip' (...)
--
-- References
--
--   [1] http://www.gnu.org/software/gzip/
--
-- (c) 2008 David Manura.  Licensed under the same terms as Lua (MIT).

local assert = assert
local error = error
local ipairs = ipairs
local require = require
local xpcall = xpcall
local type = type
local io = io
local os = os
local string = string
local debug = require "debug"
local debug_traceback = debug.traceback
local _G = _G

local DEFLATE = require( TILED_LOADER_PATH .. "external.deflatelua" )

local OptionParser = require( TILED_LOADER_PATH .. "external.optparse" ) . OptionParser

local version = '0.1'


local function runtime_assert(val, msg)
  if not val then error({msg}, val) end
  return val
end


local function runtime_error(s, level)
  level = level or 1
  error({s}, level+1)
end


local function file_exists(filename)
  local fh = io.open(filename)
  if fh then fh:close(); return true end
  return false
end


-- Run gunzip command, given command-line arguments.
local function call(...)
  local opt = OptionParser{usage="%prog [options] [gzip-file...]",
                           version=string.format("gunzip %s", version),
                           add_help_option=false}
  opt.add_option{"-h", "--help", action="store_true", dest="help",
                 help="give this help"}
  opt.add_option{
    "-c", "--stdout", dest="stdout", action="store_true",
    help="write on standard output, keep original files unchanged"}
  opt.add_option{
    "-f", "--force", dest="force", action="store_true",
    help="force overwrite of output file"}
  opt.add_option{
    "--disable-crc", dest="disable_crc", action="store_true",
    help="skip CRC check (faster performance)"}


  local options, args = opt.parse_args()

  local gzipfiles = args

  if options.help then
    opt.print_help()
    os.exit()
  end

  local ok, err = xpcall(function()
    local outfile_of = {}
    local out_of = {}

    for _,gzipfile in ipairs(gzipfiles) do
      local base = gzipfile:match('(.+)%.[gG][zZ]$')
      if not base then
        runtime_error(gzipfile .. ': unknown suffix')
      end
      outfile_of[gzipfile] = base

      out_of[gzipfile] =
        (options.stdout or not gzipfile) and assert(io.stdout)
        or outfile_of[gzipfile]

      if type(out_of[gzipfile]) == 'string' then
        if file_exists(out_of[gzipfile]) then
          io.stderr:write(out_of[gzipfile] ..
            ' already exists; do you wish to overwrite(y or n)? ')
          if not io.stdin:read'*l':match'^[yY]' then
            runtime_error 'not overwritten'
          end
        end
      end
    end

    for _,gzipfile in ipairs(gzipfiles) do
      local fh = gzipfile and runtime_assert(io.open(gzipfile, 'rb'))
                 or assert(io.stdin)
      local ofh = type(out_of[gzipfile]) == 'string' and
        runtime_assert(io.open(out_of[gzipfile], 'wb'))
        or out_of[gzipfile]

      DEFLATE.gunzip {input=fh, output=ofh,
        disable_crc=options.disable_crc}
    end

    for _,gzipfile in ipairs(gzipfiles) do
      assert(os.remove(gzipfile))
    end

  end, debug_traceback)
  if not ok then
    if type(err) == 'table' then err = err[1] end
    io.stderr:write('error: ' .. err, '\n')
  end
end


return call

--[[
LICENSE

Copyright (C) 2008, David Manura.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

(end license)
--]]
