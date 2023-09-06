--- Internal utility functions.

local M = {}

--- Check if the specified argument is of the expected type.
--- @param index integer The index of the argument, starting with 1
--- @param value any The value of the argument
--- @param expectedType string The expected type of the argument as a string
--- @param level? integer The error level
--- @return string value The input value
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
---
--- Works like Lua's tostring function, but without calling the `__tostring`
--- metamethod on tables.
--- @param value any The value to be converted
--- @return any # The converted value
function M.rawtostring(value)
  if type(value) ~= "table" then
    return tostring(value)
  end
  local mt = getmetatable(value)
  local rawString = tostring(setmetatable(value, nil))
  setmetatable(value, mt)
  return rawString
end

--- Return whether the two numbers `a` and `b` are close to each other.
--- @param a number
--- @param b number
--- @param epsilon number? Tolerated margin of error (default: 1e-09)
--- @return boolean equal
--- @nodiscard
function M.almostEqual(a, b, epsilon)
  epsilon = epsilon or 1e-09
  return math.abs(a - b) <= epsilon * math.max(math.abs(a), math.abs(b))
end

return M