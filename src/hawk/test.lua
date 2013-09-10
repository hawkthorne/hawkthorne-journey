local middle = require "hawk/middleclass"
local core = require "hawk/core"

local Test = middle.class("Test")

function Test:initialize(app)
  self.app = app
  self.waitTime = 0
  self.counter = 0
  self.failed = false
  self.actions = {}
  self.history = {}
end

function Test:queue(message, action)
  table.insert(self.history, "\t" .. message)
  table.insert(self.actions, action)
  table.insert(self.actions, function() end)
  table.insert(self.actions, function() end)
end


function Test:press(button, times)
  local times = times or 1
  for i=1,times do
    self:queue("PRESS\t" .. button, function()
      self.app:buttonpressed(button)
    end)
  end
end

function Test:sleep(time)
  self:queue("SLEEP\t" .. tostring(time), function()
    self.counter = 0
    self.waitTime = time
  end)
end

function Test:visit(url)
  self:queue("VISIT\t" .. url, function()
    self.app:redirect(url)
  end)
end

function Test:run(func)
  self:queue("RUN", func)
end

function Test:finished()
  return #self.actions == 0
end

function Test:fail()
  self.failed = true
  self.actions = {}
end


function Test:getTests()
  local meta = self.class
  local methods = {} 
  for name, _ in pairs(meta['__instanceDict']) do
    if string.find(name, 'test') == 1 then
      table.insert(methods, name)
    end
  end
  return methods
end

function Test:go(method)
  self[method](self)
end

function Test:update(dt)
  self.counter = self.counter + dt

  if self.waitTime > 0 and self.counter < self.waitTime then
    self:check(self.app.update, self.app, dt)
    return
  end

  self.waitTime = 0

  local action = table.remove(self.actions, 1)

  if action then self:check(action) end

  self:check(self.app.update, self.app, dt)
end

function Test:check(...)
  local ok, result = pcall(...)

  if not ok then
    self:fail()
    print("FAIL\t" .. result)
    print()

    for _, msg in ipairs(self.history) do
      print(msg)
    end

    print()
  end
end

function Test:draw()
  self:check(self.app.draw, self.app)
end


local Runner = middle.class("Runner")

function Runner:initialize(filepath)
  self.app = core.Application(filepath)
  self.config = self.app.config

  self.test = nil 
  self.tests = {}
  self.failures = {}

  for _, name in ipairs(love.filesystem.enumerate("tests")) do
    if string.find(name, "%.") ~= 1 then
      local testClass = require("tests/" .. string.gsub(name, "%.lua", ""))
      local test = testClass(nil)

      for _, method in ipairs(test:getTests()) do
        table.insert(self.tests, {["class"] = testClass, ["method"] = method})
      end
    end
  end
end

function Runner:report()
  if #self.failures > 0 then
    print("STOP\tThere were errors :(")
    os.exit(2)
  else
    print("STOP\tEverything is lovley :D")
    love.event.push('quit')
  end
end

function Runner:update(dt)
  if self.test == nil and #self.tests == 0 then
    self:report()
  end

  if self.test and self.test:finished() then
    if self.test.failed then table.insert(self.failures, self.test.history) end
    self.test = nil
  end

  if self.test == nil then
    local test = table.remove(self.tests)
   
    if test ~= nil then
      print("START\t" .. test.class.name .. ":" .. test.method)
      self.test = test.class(self.app)
      self.test:go(test.method)
    end
  end

  if self.test ~= nil then self.test:update(dt) end
end


function Runner:draw()
  if self.test ~= nil then self.test:draw() end
end

function Runner:redirect()
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
  ["Test"] = Test,
  ["Runner"] = Runner,
}
