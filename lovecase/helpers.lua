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

--- Return true if the specified primitive values are equal, false otherwise.
--- All values except tables are considered primitive.
--- @param first any
--- @param second any
--- @param almost boolean? If true, compare numbers with tolerance (default: false)
--- @return boolean equal
--- @nodiscard
--- @package
local function comparePrimitives(first, second, almost)
  if almost == true and type(first) == "number" and type(second) == "number" then
    return M.almostEqual(first, second)
  end
  return first == second
end

--- Return true if the specified values are equal, false otherwise.
--- @param first any
--- @param second any
--- @param almost boolean? If true, compare numbers with tolerance (default: false)
--- @return boolean equal
--- @nodiscard
function M.compareValues(first, second, almost)
  if type(first) == "table" and type(second) == "table" then
    local firstMt = getmetatable(first)
    local secondMt = getmetatable(second)

    -- Compare with __eq metamethod, if available.
    if firstMt and secondMt and firstMt.__eq == secondMt.__eq then
      return first == second
    end

    return M.compareTables(first, second, almost)
  end

  return comparePrimitives(first, second, almost)
end

--- Return true if the specified tables are equal, false otherwise.
---
--- This function does *not* perform a deep comparison. Only the first level of the tables
--- is compared.
--- @param table1 table
--- @param table2 table
--- @param almost boolean? If true, compare numbers with tolerance (default: false)
--- @return boolean equal
--- @nodiscard
function M.compareTables(table1, table2, almost)
  if type(table1) == "table" and table1 == table2 then
    return true
  end

  for key, value in pairs(table1) do
    if not comparePrimitives(table2[key], value, almost) then
      return false
    end
  end

  for key in pairs(table2) do
    if table1[key] == nil then
      return false
    end
  end

  return true
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