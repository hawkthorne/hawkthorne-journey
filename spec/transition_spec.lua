require("busted")
local imposter = require("imposter")

love = imposter.new()

local transition = require("src/transition")

describe("Screen transition", function()

  describe("transition.new", function()
    it("should create a new transition", function()
      local newTrasition = transition.new('fade', 0.5)
      assert.is_false(newTrasition:finished())
    end)

    it("should finish after a certain time", function()
      local newTrasition = transition.new('fade', 0.5)
      newTrasition:update(1)
      assert.is_false(newTrasition:finished())
    end)

    it("should go forward", function()
      local newTrasition = transition.new('fade', 0.5)
      newTrasition:forward()
      assert.are.equal(newTrasition.count, 0)
    end)

    it("should go backward", function()
      local newTrasition = transition.new('fade', 0.5)
      newTrasition:backward()
      assert.are.equal(newTrasition.count, 0)
    end)
  end)
end)
