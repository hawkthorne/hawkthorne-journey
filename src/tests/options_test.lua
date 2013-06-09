local luassert = require "vendor/luassert"

local test = require "hawk/test"
local middle = require "hawk/middleclass"

local OptionsTest = middle.class("OptionsTest", test.Test)

function OptionsTest:toggleFullscreen()
  self:visit("/options")

  self:press("JUMP")
  self:press("JUMP")

  self:run(function()
    luassert.are.equal("/options", self.app.url)
  end)
end


function OptionsTest:testBackToTitle()
  self:visit("/options")

  self:press("START")

  self:run(function() 
    luassert.are.equal("/title", self.app.url)
  end)
end

return OptionsTest
