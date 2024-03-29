local lovecase = require("init")

local test = lovecase.newTestSet("TestSet")

local CaselessString = {}
CaselessString.__index = CaselessString

function CaselessString.new(value)
  return setmetatable({value = value}, CaselessString)
end

function CaselessString:equal(other)
  return string.lower(self.value) == string.lower(other.value)
end

function CaselessString.isInstance(value)
  return type(value) == "table" and getmetatable(value) == CaselessString
end

test:addTypeCheck(function (value)
  return CaselessString.isInstance(value) and "CaselessString" or false
end)

test:addEqualityCheck("CaselessString", function(str1, str2)
  return str1:equal(str2)
end)

test:group("assertTrue()", function ()
  test:run("should assert that the given value is true", function ()
    test:assertTrue(true)
    test:assertError(function ()
      test:assertTrue(false)
    end)
    test:assertError(function ()
      test:assertTrue(1)
    end)
    test:assertError(function ()
      test:assertTrue("true")
    end)
  end)
end)

test:group("assertFalse()", function ()
  test:run("should assert that the given value is false", function ()
    test:assertFalse(false)
    test:assertError(function ()
      test:assertFalse(true)
    end)
    test:assertError(function ()
      test:assertFalse(0)
    end)
    test:assertError(function ()
      test:assertFalse(nil)
    end)
  end)
end)

test:group("assertError()", function ()
  test:run("should assert that an error is raised", function ()
    test:assertError(function ()
      error("This error is expected")
    end)
  end)
end)

test:group("assertEqual()", function ()
  test:run("should assert that two values are equal", function ()
    test:assertEqual(123, 123)
    test:assertEqual("abc", "abc")
    test:assertEqual({1, 2, 3}, {1, 2, 3})
    test:assertEqual({a = 11, b = 22}, {b = 22, a = 11})
    test:assertEqual({a = 11, b = {"a", "b"}}, {a = 11, b = {"a", "b"}})
    test:assertEqual(CaselessString.new("abc"), {value = "abc"})
    test:assertError(function ()
      test:assertEqual(123, "123")
    end)
    test:assertError(function ()
      test:assertEqual(123, 456)
    end)
    test:assertError(function ()
      test:assertEqual({1, 2, 3}, {1, 2})
    end)
    test:assertError(function ()
      test:assertEqual({a = 11, b = 22}, {a = 33, b = 22})
    end)
  end)
  test:run("should apply custom equality checks", function ()
    test:assertEqual(CaselessString.new("abc"), CaselessString.new("abc"))
    test:assertEqual(CaselessString.new("abc"), CaselessString.new("ABC"))
    test:assertError(function ()
      test:assertEqual(CaselessString.new("abc"), CaselessString.new("xyz"))
    end)
  end)
end)

test:group("assertNotEqual()", function ()
  test:run("should assert that two values are not equal", function ()
    test:assertNotEqual(123, 456)
    test:assertNotEqual("abc", "xyz")
    test:assertNotEqual({1, 2, 3}, {9, 8, 7})
    test:assertNotEqual({a = 11, b = 22}, {c = 33, d = 44})
    test:assertError(function ()
      test:assertNotEqual(123, 123)
    end)
    test:assertError(function ()
      test:assertNotEqual({1, 2, 3}, {1, 2, 3})
    end)
    test:assertError(function ()
      test:assertNotEqual({a = 11, b = 22}, {a = 11, b = 22})
    end)
  end)
end)

test:group("assertAlmostEqual()", function ()
  test:run("should assert that two values are almost equal", function ()
    test:assertAlmostEqual(100000000000000.01, 100000000000000.011)
    test:assertAlmostEqual(3.14159265358979323846, 3.14159265358979324)
    test:assertAlmostEqual(math.sqrt(2) * math.sqrt(2), 2)
    test:assertAlmostEqual(-math.sqrt(2) * math.sqrt(2), -2)
    test:assertAlmostEqual({999, 100000000000000.01}, {999, 100000000000000.011})
    test:assertError(function ()
      test:assertAlmostEqual(100.01, 100.011)
    end)
    test:assertError(function ()
      test:assertAlmostEqual(0.001, 0.0010000001)
    end)
    test:assertError(function ()
      test:assertAlmostEqual({999, 100.01}, {999, 100.011})
    end)
  end)
end)

test:group("assertNotAlmostEqual()", function ()
  test:run("should assert that two values are NOT almost equal", function ()
    test:assertNotAlmostEqual(100.01, 100.011)
    test:assertNotAlmostEqual(0.001, 0.0010000001)
    test:assertError(function ()
      test:assertNotAlmostEqual(math.sqrt(2) * math.sqrt(2), 2)
    end)
  end)
end)

test:group("assertSame()", function ()
  test:run("should assert that two values are the same", function ()
    test:assertSame(123, 123)
    test:assertSame("abc", "abc")
    local t = {1, 2, 3}
    test:assertSame(t, t)
    test:assertError(function ()
      test:assertSame(123, 456)
    end)
    test:assertError(function ()
      test:assertSame({1, 2, 3}, {1, 2, 3})
    end)
  end)
end)

test:group("assertNotSame()", function ()
  test:run("should assert that two values are not the same", function ()
    test:assertNotSame(123, 321)
    test:assertNotSame("abc", "xyz")
    test:assertNotSame({}, {})
    test:assertError(function ()
      test:assertNotSame(123, 123)
    end)
    test:assertError(function ()
      local t = {a = 1, b = 2}
      test:assertNotSame(t, t)
    end)
  end)
end)

test:group("assertSmallerThan()", function ()
  test:run("should assert that the first value is smaller than the second", function ()
    test:assertSmallerThan(1, 2)
    test:assertError(function ()
      test:assertSmallerThan(2, 1)
    end)
    test:assertError(function ()
      test:assertSmallerThan(1, 1)
    end)
  end)
end)

test:group("assertSmallerThanEqual()", function ()
  test:run("should assert that the first value is smaller than or equal to the second", function ()
    test:assertSmallerThanEqual(1, 2)
    test:assertSmallerThanEqual(1, 1)
    test:assertError(function ()
      test:assertSmallerThanEqual(2, 1)
    end)
  end)
end)

test:group("assertGreaterThan()", function ()
  test:run("should assert that the first value is greater than the second", function ()
    test:assertGreaterThan(2, 1)
    test:assertError(function ()
      test:assertGreaterThan(1, 2)
    end)
    test:assertError(function ()
      test:assertGreaterThan(1, 1)
    end)
  end)
end)

test:group("assertGreaterThanEqual()", function ()
  test:run("should assert that the first value is greater than or equal to the second", function ()
    test:assertGreaterThanEqual(2, 1)
    test:assertGreaterThanEqual(1, 1)
    test:assertError(function ()
      test:assertGreaterThanEqual(1, 2)
    end)
  end)
end)

return test