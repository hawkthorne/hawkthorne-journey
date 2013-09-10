local luassert = require "vendor/luassert"

local test = require "hawk/test"
local middle = require "hawk/middleclass"

local ScanningTest = middle.class("ScanningTest", test.Test)

function ScanningTest:testSkip()
  self:visit("/scanning")

  self:press("DOWN")

  self:run(function()
    luassert.are.equal("/select", self.app.url)
  end)
end

function ScanningTest:testGoBackwards()
  self:visit("/scanning")

  self:press("START")

  self:run(function()
    luassert.are.equal("/title", self.app.url)
  end)
end

return ScanningTest
