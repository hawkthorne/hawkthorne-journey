local middle = require "hawk/middleclass"
local core = require "hawk/core"

local Case = middle.class("Case")

function Case:initialize(app)
  self.app = app
  self.waitTime = 0
  self.counter = 0
  self.actions = {}
end

function Case:queue(action)
  table.insert(self.actions, action)
  table.insert(self.actions, function() end)
  table.insert(self.actions, function() end)
end

function Case:press(button)
  self:queue(function() 
    self.app:buttonpressed(button)
  end)
end

function Case:sleep(time)
  self:queue(function() 
    self.counter = 0
    self.waitTime = time
  end)
end

function Case:visit(url)
  self:queue(function() 
    self.app:redirect(url)
  end)
end

function Case:getTests()
  local meta = self.class
  local methods = {} 
  for name, _ in pairs(meta['__instanceDict']) do
    if string.find(name, 'test') == 1 then
      table.insert(methods, name)
    end
  end
  return methods
end

function Case:run()
  for _, test in ipairs(self:getTests()) do
    self[test](self)
  end
end

function Case:update(dt)
  self.counter = self.counter + dt

  if self.waitTime > 0 and self.counter < self.waitTime then
    return
  end

  self.waitTime = 0

  local action = table.remove(self.actions, 1)

  if action then action() end
end

local Runner = middle.class("Runner")

function Runner:initialize(filepath)
  self.app = core.Application(filepath)
  self.config = self.app.config

  self.currentCase = nil 
  self.cases = {}

  for _, name in ipairs(love.filesystem.enumerate("tests")) do
    if string.find(name, "%.") ~= 1 then
      table.insert(self.cases, "tests/" .. string.gsub(name, "%.lua", ""))
    end
  end
end

function Runner:update(dt)
  if not self.currentCase then
    local caseFile = table.remove(self.cases)
    local testCase = require(caseFile)
    self.currentCase = testCase(self.app)
    self.currentCase:run()
  end

  self.currentCase:update(dt)
  self.app:update(dt)
end

function Runner:redirect(url)
  self.app:redirect(url)
end

function Runner:draw()
  self.app:draw()
end

function Runner:buttonpressed(k)
end

function Runner:buttonreleased(k)
end

function Runner:keypressed(k)
end

function Runner:keyreleased(k)
end

function Runner:errhand(msg)
  love.event.push('quit')
end


return {
  ["Case"] = Case,
  ["Runner"] = Runner,
}
