local config = require 'hawk/config'
local gamesave = require 'hawk/gamesave'
local i18n = require 'hawk/i18n'
local json = require 'hawk/json'
local middle = require 'hawk/middleclass'

local function stackmessage(msg, trace)
  local err = {}

  table.insert(err, msg.."\n\n")

  for l in string.gmatch(trace, "(.-)\n") do
    if not string.match(l, "boot.lua") then
      l = string.gsub(l, "stack traceback:", "Traceback\n")
      table.insert(err, l)
    end
  end

  local p = table.concat(err, "\n")

  p = string.gsub(p, "\t", "")
  p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

  return p
end

local Application = middle.class('Application')

function Application:initialize(configurationPath)
  assert(love.filesystem.exists(configurationPath),
         "Can't read app configuration at path: " .. configurationPath)
  
  self.config = config.load(configurationPath)
  self.gamesaves = gamesave(3)
  self.i18n = i18n("locales")
  self.url = "/"
  self.scene = nil
  self._next = nil
end


function Application:errhand(msg)
  msg = tostring(msg)

  if not love.graphics or not love.event or not love.graphics.isCreated() then
    return
  end

  -- Load.
  if love.audio then love.audio.stop() end
  love.graphics.reset()
  love.graphics.setBackgroundColor(89, 157, 220)
  local font = love.graphics.newFont(14)
  love.graphics.setFont(font)

  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.clear()

  local trace = debug.traceback()
  local p = stackmessage(msg, trace)

  local function draw()
    love.graphics.clear()
    love.graphics.printf(p, 70, 70, love.graphics.getWidth() - 70)
    love.graphics.present()
  end

  draw()

  local e, a, b, c
  while true do
    e, a, b, c = love.event.wait()

    if e == "quit" then
      return
    end
    if e == "keypressed" and a == "escape" then
      return
    end

    draw()

  end
end

function Application:releaseerrhand(msg)
  print("An error has occured, the game has been stopped.")

  if not love.graphics or not love.event or not love.graphics.isCreated() then
    return
  end

  love.graphics.setCanvas()
  love.graphics.setPixelEffect()

  -- Load.
  if love.audio then love.audio.stop() end
  love.graphics.reset()
  love.graphics.setBackgroundColor(89, 157, 220)
  local font = love.graphics.newFont(14)
  love.graphics.setFont(font)

  love.graphics.setColor(255, 255, 255, 255)

  love.graphics.clear()

  local trace = debug.traceback()
  local report_msg = stackmessage(msg, trace)

  local release = love._release or {}

  p = string.format("Error has occured that caused %s to stop.\nYou can notify %s about this%s.", release.title or "this game", release.author or "the author", release.url and " at " .. release.url or "")

  local function draw()
    love.graphics.clear()
    love.graphics.printf(p, 70, 70, love.graphics.getWidth() - 70)
    love.graphics.present()
  end

  draw()

  api.report(report_msg, {
    ['release'] = 'production',
    ['version'] = self.config.iteration,
  })

  local e, a, b, c
  while true do
    e, a, b, c = love.event.wait()

    if e == "quit" then
      return
    end
    if e == "keypressed" and a == "escape" then
      return
    end

    draw()

  end
end

function Application:setScene(scene, url)
  self._next = scene
  self._url = url
end

function Application:redirect(url)
  local scene = require("scenes" .. url)
  self:setScene(scene(self), url)
end

function Application:draw()
  if self.scene then self.scene:draw() end
end

function Application:update(dt)

  if self._next ~= nil then
    if self.scene then self.scene:hide() end
    self.scene = self._next
    self.url = self._url
    self._next = nil
    self._url = nil
    if self.scene then self.scene:show() end
  end

  if self.scene then self.scene:update(dt) end
end

function Application:buttonpressed(k)
  if self.scene then self.scene:buttonpressed(k) end
end

function Application:buttonreleased(k)
  if self.scene then self.scene:buttonreleased(k) end
end

function Application:keypressed(k)
  if self.scene then self.scene:keypressed(k) end
end

function Application:keyreleased(k)
  if self.scene then self.scene:keyreleased(k) end
end

local Scene = middle.class('Scene')

function Scene:draw()
end

function Scene:show()
end

function Scene:hide()
end

function Scene:update(dt)
end

function Scene:keypressed(k)
end

function Scene:keyreleased(k)
end

function Scene:buttonpressed(b)
end

function Scene:buttonreleased(b)
end


return {
  ["Application"] = Application,
  ["Scene"] = Scene,
}
