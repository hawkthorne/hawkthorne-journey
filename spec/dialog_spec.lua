require("busted")
local imposter = require("spec/imposter")

love = imposter.new()
local dialog = require("src/dialog")


describe("Dialge box", function()


  describe("Dialog message", function()
    it("should get a shortened version of the current message", function()
      -- figure out why this needs to be here
      love.graphics.getWidth.returns = 100
      love.graphics.getHeight.returns = 100

      local d = dialog.new('foo')
      assert.are.equal(d:message(), '')
    end)
    it("should get the complete version of the current message", function()
      local d = dialog.new('foo')
      d.cursor = 3
      assert.are.equal(d:message(), 'foo')
    end)
    
    it("should update the cursor", function()
      local d = dialog.new('foo')
      assert.are.equal(d:message(), '')
      d:update(1)
      assert.are.equal(d:message(), 'foo')
    end)

  end)
end)
