require("busted")

local queue = require("src/queue")

describe("Event queue", function()

  describe("queue.new", function()
    it("should create a new queue", function()
      local q = queue.new()
    end)

    it("should let me push events", function()
      local q = queue.new()
      q:push('jump')
    end)

    it("should let me push events with arguments", function()
      local q = queue.new()
      q:push('jump', 1, 2)
    end)

    it("should let me push events with arguments", function()
      local q = queue.new()
      q:push('jump', 1, 2)
      local f, x, y = q:poll('jump')
      assert.are.equal(f, true)
      assert.are.equal(x, 1)
      assert.are.equal(y, 2)
    end)

    it("should overwrite events", function() -- is this a good idea??
      local q = queue.new()
      q:push('jump', 1, 2)
      q:push('jump', 2, 3)
      local f, x, y = q:poll('jump')
      assert.are.equal(f, true)
      assert.are.equal(x, 2)
      assert.are.equal(y, 3)
    end)

  end)
end)
