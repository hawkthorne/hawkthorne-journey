local imposter = require "spec/imposter"
local middle = require "src/hawk/middleclass"
local test = require "src/hawk/test"

local ExampleCase = middle.class("ExampleCase", test.Case)

function ExampleCase:testCase()
end

function ExampleCase:test_case()
end


describe("LOVE test cases", function()

  it("should find all the tests, different constructor", function()
    local test = ExampleCase()
    assert.are.same({"test_case", "testCase"}, test:getTests())
  end)


end)
