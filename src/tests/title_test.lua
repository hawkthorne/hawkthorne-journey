local luassert = require "vendor/luassert"

local test = require "hawk/test"
local middle = require "hawk/middleclass"

local TitleSceneTest = middle.class("TitleSceneTest", test.Test)

function TitleSceneTest:testBeginGame()
  self:visit("/title")

  self:press("DOWN") -- speed up
  self:sleep(.20)    -- wait for image to reach the top

  self:press("JUMP")

  self:queue("CHECK", function() 
    luassert.are.equal("/scanning", self.app.url)
  end)
end

function TitleSceneTest:testLoadControls()
  self:visit("/title")

  self:press("DOWN")
  self:sleep(.20)

  self:press("DOWN")
  self:press("JUMP")

  self:queue("CHECK", function() 
    luassert.are.equal("/controls", self.app.url)
  end)
end


function TitleSceneTest:testLoadOptions()
  self:visit("/title")

  self:press("DOWN")
  self:sleep(.20)

  self:press("DOWN")
  self:press("DOWN")
  self:press("JUMP")

  self:queue("CHECK", function() 
    luassert.are.equal("/options", self.app.url)
  end)
end


function TitleSceneTest:testLoadCredits()
  self:visit("/title")

  self:press("DOWN") -- speed up
  self:sleep(.20)    -- wait for image to reach the top

  self:press("DOWN")
  self:press("DOWN")
  self:press("DOWN")
  self:press("JUMP")

  self:queue("CHECK", function() 
    luassert.are.equal("/credits", self.app.url)
  end)
end

return TitleSceneTest
