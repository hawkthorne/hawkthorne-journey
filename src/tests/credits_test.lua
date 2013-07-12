local luassert = require "vendor/luassert"

local test = require "hawk/test"
local middle = require "hawk/middleclass"

local CreditsTest = middle.class("CreditsTest", test.Test)

function CreditsTest:testJump()
  self:visit("/credits")

  for i=1,4 do 
    self:press("DOWN")
  end

  for i=1,4 do 
    self:press("UP")
  end

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
