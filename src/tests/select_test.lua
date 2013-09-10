local luassert = require "vendor/luassert"

local test = require "hawk/test"
local middle = require "hawk/middleclass"

local SelectScreenTest = middle.class("SelectScreenTest", test.Test)

function SelectScreenTest:testSelectAllCharaters()
  self:visit("/select")
  self:sleep(.5)

  self:press("DOWN", 3)
  self:press("LEFT")
  self:press("UP", 4)
  self:press("RIGHT")
end

function SelectScreenTest:testAlternateCharaters()
  self:visit("/select")
  self:sleep(.5)

  self:press("DOWN", 3)
  self:press("LEFT")
  self:press("JUMP", 3)
end

function SelectScreenTest:testSelectCostumes()
  self:visit("/select")
  self:sleep(.5)

  self:press("ATTACK", 5)
end


return SelectScreenTest
