local fakelove = require "spec/fakelove"
local imposter = require "spec/imposter"

local middle = require "src/hawk/middleclass"
local core = require "src/hawk/core"


describe("HAWK Application", function()
  local app

  before_each(function()
    love = fakelove()
    app = core.Application('config.json')
  end)

  it("should be read the configuration", function()
    assert.are.equal(app.config.iteration, "0.0.0")
  end)

  it("should load a scene", function()
    app:redirect('/title')
    app:update(0)

    -- TODO: Figure out why middle class is failing here
    assert.are.equal(app.scene.class.name, 'Title')
    assert.are.equal(app.url, '/title')
  end)

  it("should switch scenes", function()
    local scene = imposter.new()

    app:setScene(scene)
    app:update(1)

    assert.are.equals(app.scene, scene)
    assert.are.equals(app._next, nil)
  end)

  it("should call keyreleased on the scene", function()
    local scene = mock({
      keyreleased = function(self, k) end
    })

    app.scene = scene
    app:keyreleased(3)

    assert.spy(scene.keyreleased).was.called_with(scene, 3)
  end)

  it("should call keypressed on the scene", function()
    local scene = mock({
      keypressed = function(self, k) end
    })

    app.scene = scene
    app:keypressed('a')

    assert.spy(scene.keypressed).was.called_with(scene, 'a')
  end)

  it("should call draw on the scene", function()
    local scene = mock({
      draw = function(self) end
    })

    app.scene = scene
    app:draw()

    assert.spy(scene.draw).was.called_with(scene)
  end)

  it("should maintain 30fps no matter what", function()
    local scene = mock({
      update = function(self, dt) end,
      show = function(self) end
    })

    app:setScene(scene)
    app:update(1)

    assert.spy(scene.update).was.called_with(scene, .033333333)
  end)

end)
