-- Unit tests for the Enum class.
-- @author binaryfs
-- @copyright 2020
-- @license https://opensource.org/licenses/MIT

local lovecase = require "lovecase"
local Enum = require "demo.subfolder.Enum"

local test = lovecase.newTestSet("Enum")

test:group("new()", function()
  test:run("should create an enum from a sequence", function()
    local Color = Enum.new{"Red", "Green", "Blue"}
    test:assertEqual(Color:length(), 3)
    test:assertEqual(Color.Red, 1, "Red")
    test:assertEqual(Color.Green, 2, "Green")
    test:assertEqual(Color.Blue, 3, "Blue")
  end)
  test:run("should create an enum from a hash map", function()
    local Direction = Enum.new{Left = "left", Right = "right"}
    test:assertEqual(Direction:length(), 2)
    test:assertEqual(Direction.Left, "left")
    test:assertEqual(Direction.Right, "right")
  end)
  test:run("should create an enum from mixed input", function()
    local Color = Enum.new{"Red", "Green", Blue = "blue"}
    test:assertEqual(Color:length(), 3)
    test:assertEqual(Color.Red, 1)
    test:assertEqual(Color.Green, 2)
    test:assertEqual(Color.Blue, "blue")
  end)
end)

test:group("caseOf()", function()
  local Color = Enum.new{"Red", "Green", Blue = "blue"}
  test:run("should return the case of the given value", function()
    test:assertEqual(Color:caseOf(1), "Red")
    test:assertEqual(Color:caseOf(2), "Green")
    test:assertEqual(Color:caseOf("blue"), "Blue")
  end)
  test:run("should return nil for unknown values", function()
    test:assertEqual(Color:caseOf("green"), nil)
  end)
end)

test:group("verify()", function()
  local Direction = Enum.new{"Left", "Right"}
  test:run("should accept valid values", function()
    test:assertEqual(Direction:verify(1), 1)
    test:assertEqual(Direction:verify(2), 2)
  end)
  test:run("should raise an error for unknown values", function()
    test:assertError(function()
      Direction:verify(7)
    end)
  end)
end)

test:run("should not be extensible", function()
  local Direction = Enum.new{"Left", "Right"}
  test:assertError(function()
    Direction.Down = 3
  end)
end)

return test