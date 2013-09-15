local core = require "hawk/core"
local test = require "hawk/test"

function test_credits_jump_forward()
  local app = core.Application('config.json')

  test.visit(app, "/credits")

  test.press(app, "DOWN", 4)
  test.press(app, "UP", 1)

  assert_equal("/credits", app.url)
end


function test_load_title_screen()
  local app = core.Application('config.json')
  test.visit(app, "/credits")
  test.press(app, "START")

  assert_equal("/title", app.url)
end
