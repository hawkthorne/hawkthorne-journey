local sparkle = require "hawk/sparkle"
local osx = require "hawk/sparkle/osx"

local u = sparkle.newUpdater("0.0.0", "http://example.com")

function test_updater_create()
  local u = sparkle.newUpdater("0.0.0", "")
  assert_true(u:done())
end

function test_osx_get_application_path()
  local path = osx.getApplicationPath("/Users/joe/projects/hawkthorne-journey/Journey to the Center of Hawkthorne.app/Contents/Resources")
  assert_equal("/Users/joe/projects/hawkthorne-journey/Journey to the Center of Hawkthorne.app", path)
end

function test_osx_short_path()
  local path = osx.getApplicationPath("//")
  assert_equal(path, "")
end

function test_osx_no_root_path()
  local path = osx.getApplicationPath("//Contents/Resources")
  assert_equal(path, "")
end

function test_updater_no_thread_started()
  local u = sparkle.newUpdater("0.0.0", "")
  u:start()
  assert_nil(u.thread)
end

function test_updater_progress_not_started()
  local u = sparkle.newUpdater("0.0.0", "http://example.com")
  local msg, percent = u:progress()
  assert_equal("Waiting to start", msg)
  assert_equal(0, percent)
end

function test_sparkle_osx_unzip_unknown_file()
  assert_error(function() 
    osx.replace("/foo/bar.zip", "bar")
  end)
end

local function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function test_sparkle_osx_unzip_and_overwrite()
  local cwd = love.filesystem.getWorkingDirectory()
  local zipfile = cwd .. "/src/test/fixtures/tmp/hawkthorne-osx.zip"
  local apppath = cwd .. "/src/test/fixtures/Fake.app"
  osx.replace(zipfile, apppath)
  assert_true(file_exists(apppath))
end






