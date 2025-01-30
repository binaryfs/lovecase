--- Internal utility functions.
--- @class lovecase.utils
local utils = {}

--- Number of spaces per indention level
utils.indentSpaces = 2

--- Check if the specified argument is of the expected type.
--- @param index integer The index of the argument, starting with 1
--- @param value any The value of the argument
--- @param expectedType string The expected type of the argument as a string
--- @param level? integer The error level
--- @return string value The input value
function utils.assertArgument(index, value, expectedType, level)
  local valueType = type(value)
  if valueType ~= expectedType then
    error(
      string.format("Type of argument %d should be '%s' but was '%s'", index, expectedType, valueType),
      level or 3
    )
  end
  return value
end

--- @param t table
--- @param value any
--- @return integer? index The index of the value or nil
--- @nodiscard
function utils.indexOf(t, value)
  for index = 1, #t do
    if t[index] == value then
      return index
    end
  end
  return nil
end

--- Convert the specified value to a string.
---
--- Works like Lua's tostring function, but without calling the `__tostring`
--- metamethod on tables.
--- @param value any The value to be converted
--- @return any # The converted value
function utils.rawtostring(value)
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
function utils.almostEqual(a, b, epsilon)
  epsilon = epsilon or 1e-09
  return math.abs(a - b) <= epsilon * math.max(math.abs(a), math.abs(b))
end

--- Return true if the specified values are considered equal, false otherwise.
--- @param a any
--- @param b any
--- @param almost boolean? If true, compare numbers with tolerance (false)
--- @param comparedTables table? Internal table to keep track of already compared table pairs
--- @return boolean equal
--- @nodiscard
function utils.compareValues(a, b, almost, comparedTables)
  if type(a) == "table" and type(b) == "table" then
    return utils.compareTables(a, b, almost, comparedTables)
  end

  if almost == true and type(a) == "number" and type(b) == "number" then
    return utils.almostEqual(a, b)
  end

  return a == b
end

--- Return true if the specified tables are equal, false otherwise.
--- Tables are compared recursively.
--- @param t1 table
--- @param t2 table
--- @param almost boolean? If true, compare numbers with tolerance (false)
--- @param comparedTables table? Internal table to keep track of already compared table pairs
--- @return boolean equal
--- @nodiscard
function utils.compareTables(t1, t2, almost, comparedTables)
  comparedTables = comparedTables or {}

  if comparedTables[t1] and comparedTables[t1][t2] then
    return true -- Already compared
  end

  comparedTables[t1] = comparedTables[t1] or {}
  comparedTables[t1][t2] = true

  if t1 == t2 then
    -- Same reference or compared by __eq metamethod
    return true
  end

  local mt1, mt2 = getmetatable(t1), getmetatable(t2)

  if mt1 and mt2 then
    if type(mt1.__eq) == "function" and mt1.__eq == mt2.__eq then
      -- We already used == to compare the tables some lines above.
      -- If we end up here, it means that == returned false.
      return false
    end

    -- Check metatables for equality methods
    local equalMethod1 = mt1.equal or mt1.equals
    local equalMethod2 = mt2.equal or mt2.equals

    if type(equalMethod1) == "function" and equalMethod1 == equalMethod2 then
      local success, result = pcall(equalMethod1, t1, t2)

      if success and type(result) == "boolean" then
        return result
      end
    end
  end

  for key, value in pairs(t1) do
    if not utils.compareValues(t2[key], value, almost, comparedTables) then
      return false
    end
  end

  for key in pairs(t2) do
    if rawget(t1, key) == nil then
      return false
    end
  end

  return true
end

--- @param depth integer
--- @return string
--- @nodiscard
function utils.indent(depth)
  return string.rep(" ", utils.indentSpaces * depth)
end

return utils