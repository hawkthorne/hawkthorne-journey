local json = require "hawk/json"
local tracker = require "src/tracker"
local player = require "src/player"
local HC = require 'vendor/hardoncollider'

function test_filename() 
  local t = tracker.new('foo', {})
  assert_match("replays/%d+_foo%.json", t.filename)
end

function test_track_row() 
  local t = tracker.new('foo', player.new(HC(100)))
  t:update(100)

  local entry = t.rows[1]
  assert_equal(entry[1], 0)
  assert_equal(entry[2], 0)
  assert_equal(entry[3], 'right')
  assert_equal(entry[4], 'idle')
end

function test_flush_row() 
  local t = tracker.new('foo', player.new(HC(100)))
  t:update(100)
  t:flush()

  local contents, _ = love.filesystem.read(t.filename)
  local entry = json.decode(contents)[1]
  love.filesystem.remove(t.filename)

  assert_equal(0, entry[1])
  assert_equal(0, entry[2])
  assert_equal('right', entry[3])
  assert_equal('idle', entry[4])
end
