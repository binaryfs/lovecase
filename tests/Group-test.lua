local Group = require("Group")
local lovecase = require("init")
local Result = require("Result")

local expect = lovecase.expect
local suite = lovecase.newSuite("Group")

suite:describe("getTestCount()", function ()
  suite:test("should return initially zero", function ()
    local group = Group.new("foo")
    expect.equal({group:getTestCount()}, {0, 0})
  end)
end)

suite:describe("addResult()", function ()
  suite:test("should update the total test count", function ()
    local group = Group.new("foo")
    group:addResult(Result.new("bar", true))
    expect.equal({group:getTestCount()}, {1, 0})
  end)
  suite:test("should update the failed test count", function ()
    local group = Group.new("foo")
    group:addResult(Result.new("bar", false))
    expect.equal({group:getTestCount()}, {1, 1})
  end)
  suite:test("should update the test count in parent groups", function ()
    local parent = Group.new("foo")
    local group = Group.new("bar", parent)
    group:addResult(Result.new("xor", false))
    expect.equal({parent:getTestCount()}, {1, 1})
  end)
end)

suite:describe("write()", function ()
  suite:test("should produce output when any test failed", function ()
    local output = {}
    local group = Group.new("foo")
    group:addResult(Result.new("bar", false))
    group:write(output, 0)
    expect.greaterThan(#output, 0)
  end)
  suite:test("should not produce output when all tests passed", function ()
    local output = {}
    local group = Group.new("foo")
    group:addResult(Result.new("bar", true))
    group:write(output, 0)
    expect.equal(#output, 0)
  end)
end)

return suite