local fakelove = require "spec/fakelove"

local imposter = require "spec/imposter"
local middle = require "src/hawk/middleclass"
local core = require "src/hawk/core"

describe("Journey to the Center of Hawkthorne scenes", function()
  local app
  local scene

  before_each(function()
    love = fakelove()
    app = core.Application('config.json')
  end)

  describe("Credits scene", function() 

    before_each(function()
      scene = require("src/scenes/credits")(app)
    end)

    it("should jump the list forward", function()
      scene:buttonpressed('DOWN')
      assert.are.equal(100, scene.ty)
    end)

    it("should jump the list backward", function()
      scene:buttonpressed('UP')
      assert.are.equal(300, scene.ty)
    end)

    it("should go back to the splash screen", function()
      scene:buttonpressed('START')
      assert.are.equal('Title', app._next.class.name)
    end)

    it("should enter and leave correctly", function()
      scene:show()
      scene:hide()
    end)
 
    it("should draw credits", function()
      scene:draw()
    end)
    
    it("should got back to the title screen once done", function()
      scene.ty = 1000000
      scene:update(1)
      assert.are.equal('Title', app._next.class.name)
    end)

  end)

  describe("Controls scene", function()
    before_each(function()
      scene = require("src/scenes/credits")(app)
    end)
  end)

end)
