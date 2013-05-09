local fakelove = require "spec/fakelove"
local core = require "src/hawk/core"

describe("HAWK Application", function()

  setup(function()
    love = fakelove()
  end)

  it("It should be read the configuration", function()
    local app = core.newApplication('config.json')
    assert.are.equal(app.config.release, false)
  end)

end)
