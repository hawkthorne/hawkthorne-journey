local sparkle = require "hawk/sparkle"
local osx = require "hawk/sparkle/osx"
local windows = require "hawk/sparkle/windows"

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

function test_sparkle_same_versions()
  assert_false(sparkle.isNewer("0.0.1", "0.0.1"))
end

function test_sparkle_lower_versions()
  assert_false(sparkle.isNewer("0.0.1", "0.0.0"))
end

function test_sparkle_higher_bug_versions()
  assert_true(sparkle.isNewer("0.0.1", "0.0.2"))
end

function test_sparkle_lower_minor_version()
  assert_false(sparkle.isNewer("0.1.0", "0.0.2"))
end

function test_sparkle_unsupported_versions()
  assert_false(sparkle.isNewer("0.0.-1", "0.0.2.0"))
end

function test_sparkle_higher_minor_version()
  assert_true(sparkle.isNewer("0.1.0", "0.2.0"))
end

function test_sparkle_lower_major_version()
  assert_false(sparkle.isNewer("1.0.0", "0.2.0"))
end

function test_sparkle_higher_major_version()
  assert_true(sparkle.isNewer("1.9.9", "2.0.0"))
end

function test_sparkle_remove_path_no_exist()
  assert_true(windows.removeRecursive("nonexistant"))
end

function test_sparkle_remove_directory()
  love.filesystem.createDirectory("test_folder")
  love.filesystem.write("test_folder/foo.txt", "Hello")
  assert_true(windows.removeRecursive("test_folder"))
  assert_false(love.filesystem.exists("test_folder/foo.txt"))
end


function test_sparkle_windows_basename()
  local url = "http://files.projecthawkthorne.com/releases/v0.0.84/i386/OpenAL32.dll"
  local basename = windows.basename(url)
  assert_equal("OpenAL32.dll", basename)
end
