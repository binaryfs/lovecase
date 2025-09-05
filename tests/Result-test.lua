local lovecase = require("init")
local Result = require("Result")

return lovecase.newSuite("Result", function (suite)
  local expect = lovecase.expect

  suite:describe("isPassed()", function ()
    suite:test("should return true for passed tests, false othewise", function ()
      local passedResult = Result.new("foo", true)
      local failedResult = Result.new("bar", false)
      expect.isTrue(passedResult:isPassed())
      expect.isFalse(failedResult:isPassed())
    end)
  end)

  suite:describe("write()", function ()
    suite:test("should produce output for a failed test", function ()
      local failedResult = Result.new("bar", false)
      local output = {}
      failedResult:write(output, 0)
      expect.greaterThan(#output, 0)
    end)
    suite:test("should not produce output for a passed test", function ()
      local passedResult = Result.new("bar", true)
      local output = {}
      passedResult:write(output, 0)
      expect.equal(#output, 0)
    end)
  end)
end)