local BASE = (...):gsub("[^%.]*$", "")
--- @type lovecase.serial
local serial = require(BASE .. "serial")
--- @type lovecase.utils
local utils = require(BASE .. "utils")

--- Module to make assertions about values.
--- @class lovecase.expect
local expect = {}

--- Assert that the specified value is true.
--- @param value any
function expect.isTrue(value)
  if value ~= true then
    error(string.format(
      "Value %s was expected to be true (line %d)",
      serial.serialize(value),
      debug.getinfo(2, "l").currentline
    ), 0)
  end
end

--- Assert that the specified value is false.
--- @param value any
function expect.isFalse(value)
  if value ~= false then
    error(string.format(
      "Value %s was expected to be false (line %d)",
      serial.serialize(value),
      debug.getinfo(2, "l").currentline
    ), 0)
  end
end

--- Assert that the first value is equal to the expected value.
--- @param value any
--- @param expected any
function expect.equal(value, expected)
  if not utils.compareValues(value, expected) then
    error(string.format(
      "Value %s was expected to be %s",
      serial.serialize(value),
      serial.serialize(expected)
    ), 0)
  end
end

--- Assert that the first value is not equal to the expected value.
--- @param value any
--- @param expected any
function expect.notEqual(value, expected)
  if utils.compareValues(value, expected) then
    error(string.format(
      "Both values are equal: %s",
      serial.serialize(value)
    ), 0)
  end
end

--- Assert that the first value is almost equal to the second value.
--- @param first any
--- @param second any
function expect.almostEqual(first, second)
  if not utils.compareValues(first, second, true) then
    error(string.format(
      "Value %s was expected to be almost %s",
      serial.serialize(first),
      serial.serialize(second)
    ), 0)
  end
end

--- Assert that the first value is not almost equal to the second value.
--- @param first any
--- @param second any
function expect.notAlmostEqual(first, second)
  if utils.compareValues(first, second, true) then
    error(string.format(
      "Both values are almost equal: %s | %s",
      serial.serialize(first),
      serial.serialize(second)
    ), 0)
  end
end

--- Assert that the first value is the same as the second value.
--- This function compares values with the `rawequal` function.
--- @param first any
--- @param second any
function expect.same(first, second)
  if not rawequal(first, second) then
    error(string.format(
      "Value %s was expected to be the same as %s",
      serial.serialize(first),
      serial.serialize(second)
    ), 0)
  end
end

--- Assert that the first value is not the same as the second value.
--- This function compares values with the `rawequal` function.
--- @param first any
--- @param second any
function expect.notSame(first, second)
  if rawequal(first, second) then
    error(string.format(
      "Value %s was not expected to be the same as %s",
      serial.serialize(first),
      serial.serialize(second)
    ), 0)
  end
end

--- Assert that the first value is less than the second value.
--- @param first any
--- @param second any
function expect.lessThan(first, second)
  if first >= second then
    error(string.format(
      "Value %s is not less than %s",
      serial.serialize(first),
      serial.serialize(second)
    ), 0)
  end
end

--- Assert that the first value is less than or equal to the second value.
--- @param first any
--- @param second any
function expect.lessThanOrEqual(first, second)
  if first > second then
    error(string.format(
      "Value %s is not less than or equal to %s",
      serial.serialize(first),
      serial.serialize(second)
    ), 0)
  end
end

--- Assert that the first value is greater than the second value.
--- @param first any
--- @param second any
function expect.greaterThan(first, second)
  if first <= second then
    error(string.format(
      "Value %s is not greater than %s",
      serial.serialize(first),
      serial.serialize(second)
    ), 0)
  end
end

--- Assert that the first value is greater than or equal to the second value.
--- @param first any
--- @param second any
function expect.greaterThanOrEqual(first, second)
  if first < second then
    error(string.format(
      "Value %s is not greater than or equal to %s",
      serial.serialize(first),
      serial.serialize(second)
    ), 0)
  end
end

--- Assert that the specified function throws an error when called.
function expect.error(value)
  if pcall(value) then
    local line = debug.getinfo(2, "l").currentline
    error(string.format("The function was expected to throw an error (line %d)", line), 0)
  end
end

--- Assert that the specified function does not throw error when called.
function expect.noError(value)
  local success, errorMessage = pcall(value)
  if not success then
    error("The function threw an error: " .. errorMessage, 0)
  end
end

return expect