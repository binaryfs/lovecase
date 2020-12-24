--- Internal utility functions.
-- @module lovecase.helpers
-- @author binaryfs
-- @copyright 2020
-- @license https://opensource.org/licenses/MIT

local M = {}

--- Check if the specified argument is of the expected type.
-- @param index The index of the argument, starting with 1
-- @param value The value of the argument
-- @param expectedType The expected type of the argument as a string
-- @param[opt=3] level The error level
-- @return The input value
-- @raise The argument's value is not of the expected type
function M.assertArgument(index, value, expectedType, level)
  local valueType = type(value)
  if valueType ~= expectedType then
    error(
      string.format("Type of argument %d should be '%s' but was '%s'", index, expectedType, valueType),
      level or 3
    )
  end
  return value
end

--- Convert the specified value to a string.
-- Works like Lua's tostring function, but without calling the __tostring
-- metamethod on tables.
-- @param value The value to be converted
-- @return The converted value
function M.rawtostring(value)
  if type(value) ~= "table" then
    return tostring(value)
  end
  local mt = getmetatable(value)
  local rawString = tostring(setmetatable(value, nil))
  setmetatable(value, mt)
  return rawString
end

return M