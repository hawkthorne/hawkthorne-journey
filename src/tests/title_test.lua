local luassert = require "vendor/luassert"

local test = require "hawk/test"
local middle = require "hawk/middleclass"

local TitleSceneTest = middle.class("TitleSceneTest", test.Case)

function TitleSceneTest:testStartGame()
  self:visit("/title")

  self:press("DOWN") -- speed up
  self:sleep(.20)    -- wait for image to reach the top

  self:press("JUMP")

  self:queue(function() 
    luassert.are.equal("/loading", self.app.url)
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

  self:queue(function() 
    luassert.are.equal("/credits", self.app.url)
  end)
end

return TitleSceneTest
