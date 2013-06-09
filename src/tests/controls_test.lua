local luassert = require "vendor/luassert"

local test = require "hawk/test"
local middle = require "hawk/middleclass"

local ControlsTest = middle.class("ControlsTest", test.Test)

function ControlsTest:testJump()
  self:visit("/controls")

  for i=1,8 do 
    self:press("DOWN")
  end

  self:run(function()
    luassert.are.equal("/controls", self.app.url)
  end)
end


function ControlsTest:testBackToTitle()
  self:visit("/credits")

  self:press("START")

  self:run(function() 
    luassert.are.equal("/title", self.app.url)
  end)
end

return ControlsTest
