local luassert = require "vendor/luassert"

local test = require "hawk/test"
local middle = require "hawk/middleclass"

local CreditsTest = middle.class("CreditsTest", test.Test)

function CreditsTest:testJump()
  self:visit("/credits")

  self:press("DOWN", 4)
  self:press("UP", 1)

  self:run(function()
    luassert.are.equal("/credits", self.app.url)
  end)
end


function CreditsTest:testLoadTitleScreen()
  self:visit("/credits")

  self:press("START")

  self:run(function() 
    luassert.are.equal("/title", self.app.url)
  end)
end

return CreditsTest
