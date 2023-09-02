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

--- Determine if the metatable of `t` contains the specified method.
--- @param t table
--- @param methodName string
--- @return boolean
--- @nodiscard
function M.hasMetamethod(t, methodName)
  local mt = getmetatable(t)
  return mt and type(mt[methodName]) == "function" or false
end

--- Return true if the specified tables are equal, false otherwise.
---
--- This function performs a flat comparison (not a deep comparison).
--- @param table1 table
--- @param table2 table
--- @return boolean equal
--- @nodiscard
function M.compareTables(table1, table2)
  if type(table1) == "table" and table1 == table2 then
    return true
  end

  for key, value in pairs(table1) do
    if table2[key] ~= value then
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

return M