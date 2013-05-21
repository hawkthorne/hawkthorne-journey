local tween = require("src/vendor/tween")

describe("The tween system", function()

  it("should handle a zero dt value", function()
    tween.update(0)
  end)

  it("should handle a negative value", function()
    tween.update(-5)
  end)

  it("should handle a nil ", function()
    tween.update(nil)
  end)

  it("should handle anything ", function()
    tween.update("fkajsdkfj")
  end)

end)
