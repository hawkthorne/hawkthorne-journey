local core = require "hawk/core"
local test = require "hawk/test"

function test_controls_jump()
  local app = core.Application('config.json')

  test.visit(app, "/controls")
  test.press(app, "DOWN", 8)

  assert_equal("/controls", app.url)
end


function test_controls_back_to_menu()
  local app = core.Application('config.json')

  test.visit(app, "/controls")
  test.press(app, "START")

  assert_equal("/title", app.url)
end
