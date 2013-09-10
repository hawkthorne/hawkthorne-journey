local core = require "hawk/core"
local test = require "hawk/test"

function test_scanning_skip()
  local app = core.Application('config.json')

  test.visit(app, "/scanning")
  test.press(app, "DOWN")

  assert_equal("/select", app.url)
end

function test_scanning_go_backwards()
  local app = core.Application('config.json')

  test.visit(app, "/scanning")
  test.press(app, "START")

  assert_equal("/title", app.url)
end
