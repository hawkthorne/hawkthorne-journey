local sparkle = require "hawk/sparkle"
local u = sparkle.newUpdater("0.0.0", "http://example.com")

function test_updater_get_osx_path()
  local path = u:getApplicationPath("OS X", "/Users/joe/projects/hawkthorne-journey/Journey to the Center of Hawkthorne.app/Contents/Resources")
  assert_equal("/Users/joe/projects/hawkthorne-journey/Journey to the Center of Hawkthorne.app", path)
end

function test_updater_no_root_path()
  local path = u:getApplicationPath("OS X", "//")
  assert_equal(path, "")
end

function test_updater_no_root_path()
  local path = u:getApplicationPath("OS X", "//Contents/Resources")
  assert_equal(path, "")
end

function test_updater_unknown_os()
  local path = u:getApplicationPath("", "foobar")
  assert_equal(path, "")
end

function test_updater_replace_unknown_os()
  assert_error(function() 
    u:replace("symbian", "foo", "bar")
  end)
end

function test_updater_unzip_unknown_file()
  assert_error(function() 
    u:replace("OS X", "/foo/bar.zip", "bar")
  end)
end

local function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function test_updater_unzip_and_overwrite()
  local cwd = love.filesystem.getWorkingDirectory()
  local zipfile = cwd .. "/src/test/fixtures/tmp/hawkthorne-osx.zip"
  local apppath = cwd .. "/src/test/fixtures/Fake.app"
  u:replace("OS X", zipfile, apppath)
  assert_true(file_exists(apppath))
end






