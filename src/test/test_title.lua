local core = require "hawk/core"
local test = require "hawk/test"

local function loadscreen(app)
  test.visit(app, "/title")
  test.press(app, "DOWN")
  test.sleep(app, 1)
end

function test_title_begin()
  local app = core.Application('config.json')

  loadscreen(app)

  test.press(app, "JUMP")

  assert_equal("/scanning", app.url)
end

function test_title_pick_controls()
  local app = core.Application('config.json')

  loadscreen(app)

  test.press(app, "DOWN")
  test.press(app, "JUMP")

  assert_equal("/controls", app.url)
end

function test_title_pick_options()
  local app = core.Application('config.json')

  loadscreen(app)

  test.press(app, "DOWN", 2)
  test.press(app, "JUMP")

  assert_equal("/options", app.url)
end

function test_title_pick_credits()
  local app = core.Application('config.json')

  loadscreen(app)

  test.press(app, "DOWN", 3)
  test.press(app, "JUMP")

  assert_equal("/credits", app.url)
end
