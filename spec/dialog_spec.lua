local fakelove = require "spec/fakelove"
local dialog = nil

describe("Dialog box", function()

  setup(function()
    love = fakelove()
    dialog = require "src/dialog"
  end)

  it("should get a shortened version of the current message", function()
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
