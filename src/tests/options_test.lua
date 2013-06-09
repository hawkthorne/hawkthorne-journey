local luassert = require "vendor/luassert"

local test = require "hawk/test"
local middle = require "hawk/middleclass"

local OptionsTest = middle.class("OptionsTest", test.Test)

function OptionsTest:testToggleFullscreen()
  self:visit("/options")

  self:press("JUMP")

  self:run(function()
    local _, _, is_fullscreen, _ = love.graphics.getMode()
    luassert.is_true(is_fullscreen)
  end)

  self:press("JUMP")
end


function OptionsTest:testBackToTitle()
  self:visit("/options")

  self:press("START")

  self:run(function() 
    luassert.are.equal("/title", self.app.url)
  end)
end

return OptionsTest
