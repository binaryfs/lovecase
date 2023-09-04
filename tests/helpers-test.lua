local helpers = require("lovecase.helpers")
local lovecase = require("lovecase")

local test = lovecase.newTestSet("helpers")

test:group("assertArgument()", function()
  test:run("should check if the specified argument is of the expected type", function()
    helpers.assertArgument(1, "abc", "string")
    helpers.assertArgument(2, 321, "number")
    test:assertError(function ()
      helpers.assertArgument(3, "abc", "boolean")
    end)
  end)
end)

test:group("rawtostring()", function()
  test:run("should ignore the __tostring metamethod", function()
    local t = {}
    local tableString = tostring(t)
    setmetatable(t, {__tostring = function () return "foo" end})
    test:assertEqual(tostring(t), "foo")
    test:assertEqual(helpers.rawtostring(t), tableString)
  end)
  test:run("should also work for primitive types", function()
    test:assertEqual(helpers.rawtostring(123), "123")
    test:assertEqual(helpers.rawtostring("abc"), "abc")
  end)
end)

return test