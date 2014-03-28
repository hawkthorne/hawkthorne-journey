local utils = require 'utils'
local json = require 'hawk/json'

local Tracker = {}
Tracker.__index = Tracker


function Tracker:update(dt)
  self.dt = self.dt + dt

  if self.dt < self.interval then
    return
  end

  self.dt = 0

  table.insert(self.rows, {
    utils.round(self.player.position.x, 0),
    utils.round(self.player.position.y, 0),
    self.player.character.direction,
    self.player.character.state,
  })
end


function Tracker:flush()
  love.filesystem.createDirectory("replays")
  love.filesystem.write(self.filename, json.encode(self.rows))
end

local module = {}

function module.new(level, player)
  local t = {}
  setmetatable(t, Tracker)

  t.player = player
  t.level = level
  t.filename = string.format("replays/%s_%s.json", os.time(), level)
  t.interval = 0.1
  t.rows = {}
  t.dt = 0

  return t
end

return module
