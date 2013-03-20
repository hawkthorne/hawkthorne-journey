require("busted")

local machine = require 'hawk/statemachine'
local middle = require 'hawk/middleclass'

describe("Lua state machine framework", function()
  describe("A stop light", function()
    local fsm
    local stoplight = {
      { name = 'warn',  from = 'green',  to = 'yellow' },
      { name = 'panic', from = 'yellow', to = 'red'    },
      { name = 'calm',  from = 'red',    to = 'yellow' },
      { name = 'clear', from = 'yellow', to = 'green'  }
    }

    before_each(function()
      fsm = machine.create({ initial = 'green', events = stoplight })
    end)

    it("should start as green", function()
      assert.is_true(fsm:is('green'))
    end)

    it("should not let you get to the wrong state", function()
      assert.is_false(fsm:panic())
      assert.is_false(fsm:calm())
      assert.is_false(fsm:clear())
    end)

    it("should let you go to yellow", function()
      assert.is_true(fsm:warn())
      assert.is_true(fsm:is('yellow'))
    end)

    it("should tell you what it can do", function()
      assert.is_true(fsm:can('warn'))
      assert.is_false(fsm:can('panic'))
      assert.is_false(fsm:can('calm'))
      assert.is_false(fsm:can('clear'))
    end)

    it("should tell you what it can't do", function()
      assert.is_false(fsm:cannot('warn'))
      assert.is_true(fsm:cannot('panic'))
      assert.is_true(fsm:cannot('calm'))
      assert.is_true(fsm:cannot('clear'))
    end)

    it("should support checking states", function()
      assert.is_true(fsm:is('green'))
      assert.is_false(fsm:is('red'))
      assert.is_false(fsm:is('yellow'))
    end)

    it("should cancel the warn event on leave", function()
      fsm.onleavegreen = function(self, name, from, to) 
        return false
      end

      local result = fsm:warn()

      assert.is_false(result)
      assert.is_true(fsm:is('green'))
    end)

    it("should cancel the warn event on before", function()
      fsm.onbeforewarn = function(self, name, from, to) 
        return false
      end

      local result = fsm:warn()

      assert.is_false(result)
      assert.is_true(fsm:is('green'))
    end)

    it("should accept other arguments", function()
      fsm.onstatechange = function(self, name, from, to, foo)
        self.foo = foo
      end

      fsm:warn("bar")

      assert.are.equals(fsm.foo, 'bar')
    end)

    it("should fire the onstatechange handler", function()
      fsm.onstatechange = function(self, name, from, to) 
        self.name = name
        self.from = from
        self.to = to
      end

      fsm:warn()

      assert.are.equals(fsm.name, 'warn')
      assert.are.equals(fsm.from, 'green')
      assert.are.equals(fsm.to, 'yellow')
    end)


    it("should support mixins", function()
      local Stoplight = middle.class('Stoplight')

      Stoplight:include(machine.mixin({ initial = 'green', events = stoplight }))

      function Stoplight:onwarn(name, from, to) 
        self.name = name
        self.from = from
        self.to = to
      end

      local light = Stoplight()
      local light2 = Stoplight()

      light:warn()

      assert.is_true(light:is('yellow'))
      assert.are.equals(light.name, 'warn')
      assert.are.equals(light.from, 'green')
      assert.are.equals(light.to, 'yellow')

      assert.is_true(light2:is('green'))
    end)

    it("should fire the onwarn handler", function()
      fsm.onwarn = function(self, name, from, to) 
        self.name = name
        self.from = from
        self.to = to
      end

      fsm:warn()

      assert.are.equals(fsm.name, 'warn')
      assert.are.equals(fsm.from, 'green')
      assert.are.equals(fsm.to, 'yellow')
    end)

  end)
end)

