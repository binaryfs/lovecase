local utils = require("utils")
local lovecase = require("init")

local expect = lovecase.expect
local suite = lovecase.newSuite("utils")

suite:describe("indexOf", function ()
  suite:test("should return the index of the specified value", function ()
    local array = {"a", "b", "c"}
    expect.equal(utils.indexOf(array, "b"), 2)
  end)
  suite:test("should return nil for non-existant values", function ()
    local array = {"a", "b", "c"}
    expect.equal(utils.indexOf(array, "x"), nil)
  end)
end)

suite:describe("rawtostring()", function ()
  suite:test("should ignore the __tostring metamethod", function ()
    local t = {}
    local tableString = tostring(t)
    setmetatable(t, {__tostring = function () return "foo" end})
    expect.equal(tostring(t), "foo")
    expect.equal(utils.rawtostring(t), tableString)
  end)
  suite:test("should also work for primitive types", function ()
    expect.equal(utils.rawtostring(123), "123")
    expect.equal(utils.rawtostring("abc"), "abc")
  end)
end)

suite:describe("almostEqual()", function ()
  suite:test("should return true if two values are almost equal", function (a, b)
    expect.isTrue(utils.almostEqual(a, b))
  end, {
    {100000000000000.01, 100000000000000.011},
    {3.14159265358979323846, 3.14159265358979324},
    {math.sqrt(2) * math.sqrt(2), 2},
    {-math.sqrt(2) * math.sqrt(2), -2},
  })
  suite:test("should return false if two values are NOT almost equal", function (a, b)
    expect.isFalse(utils.almostEqual(a, b))
  end, {
    {1, 2},
    {0.1, 0.2},
    {100.01, 100.011},
    {0.001, 0.0010000001},
  })
end)

suite:describe("indent", function ()
  suite:test("should return the indention for the specified level", function ()
    expect.equal(#utils.indent(1), utils.indentSpaces)
    expect.equal(#utils.indent(3), utils.indentSpaces * 3)
  end)
end)

return suite