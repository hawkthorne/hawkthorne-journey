local fakelove = require "spec/fakelove"
local imposter = require "spec/imposter"

local core = require "src/hawk/core"
local app = nil

describe("HAWK Application", function()

  setup(function()
    love = fakelove()
    app = core.newApplication('config.json')
  end)

  it("It should be read the configuration", function()
    assert.are.equal(app.config.release, false)
  end)

  it("It should switch scenes", function()
    local scene = imposter.new()

    app:setScene(scene)
    app:update(1)

    assert.are.equals(app.scene, scene)
    assert.are.equals(app._next, nil)
  end)

  it("It should call keyreleased on the scene", function()
    local scene = mock({
      keyreleased = function(self, k) end
    })

    app.scene = scene
    app:keyreleased(3)

    assert.spy(scene.keyreleased).was.called_with(scene, 3)
  end)

  it("It should call keypressed on the scene", function()
    local scene = mock({
      keypressed = function(self, k) end
    })

    app.scene = scene
    app:keypressed('a')

    assert.spy(scene.keypressed).was.called_with(scene, 'a')
  end)

  it("It should call draw on the scene", function()
    local scene = mock({
      draw = function(self) end
    })

    app.scene = scene
    app:draw()

    assert.spy(scene.draw).was.called_with(scene)
  end)

  it("It should maintain 30fps no matter what", function()
    local scene = mock({
      update = function(self, dt) end
    })

    app:setScene(scene)
    app:update(1)

    assert.spy(scene.update).was.called_with(scene, .033333333)
  end)


  it("It should call update on the scene", function()
    local scene = mock({
      update = function(self, dt) end
    })

    app:setScene(scene)
    app:update(0)

    assert.spy(scene.update).was.called_with(scene, 0)
  end)

end)
