-- Utilities to serialize tables.

local M = {}

-- Forward declarations
local serializeValue

--- @param t table
--- @param value any
--- @return integer?
--- @nodiscard
--- @package
local function indexOf(t, value)
  for index = 0, #t do
    if t[index] == value then
      return index
    end
  end
  return nil
 end

--- Serialize a primitive value to a sequence of string tokens.
--- @param value any The value to serialize
--- @param tokens table The table that receives the tokens
--- @package
local function serializePrimitive(value, tokens)
  if type(value) == "string" then
    table.insert(tokens, string.format("%q", value))
  else
    table.insert(tokens, tostring(value))
  end
end

--- Serialize a table key to a sequence of string tokens.
--- @param key any The key to serialize
--- @param tokens table The table that receives the tokens
--- @package
local function serializeKey(key, tokens)
  table.insert(tokens, "[")
  serializePrimitive(key, tokens)
  table.insert(tokens, "]")
end

--- Serialize a table to a squence of string tokens.
--- @param tbl table The table to serialize
--- @param tokens table The table that receives the tokens
--- @param stack table Stack of tables to detect loops
--- @package
local function serializeTable(tbl, tokens, stack)
  local knownKeys = {}

  table.insert(stack, tbl)
  table.insert(tokens, "{")

  -- Write the index part of the table.
  if #tbl > 0 then
    for index, value in ipairs(tbl) do
      serializeValue(value, tokens, stack)
      table.insert(tokens, ",")
      knownKeys[index] = true
    end
  end

  -- Write the hash part of the table.
  for key, value in pairs(tbl) do
    if not knownKeys[key] then
      serializeKey(key, tokens)
      table.insert(tokens, "=")
      serializeValue(value, tokens, stack)
      table.insert(tokens, ",")
    end
  end

  table.insert(tokens, "}")
  table.remove(stack)
end

--- Serialize a value to a sequence of string tokens.
--- @param value any The value to serialize
--- @param tokens table The table that receives the tokens
--- @param stack table Stack of tables to detect loops
--- @package
function serializeValue(value, tokens, stack)
  if type(value) == "table" then
    local mt = getmetatable(value)
    if (mt and mt.__tostring) or indexOf(stack, value) then
      table.insert(tokens, string.format("%q", tostring(value)))
    else
      serializeTable(value, tokens, stack)
    end
  else
    serializePrimitive(value, tokens)
  end
end

--- Serialize the given value to a string.
--- @param value any
--- @return string serializedValue
--- @nodiscard
function M.serialize(value)
  local tokens = {}
  serializeValue(value, tokens, {})
  return table.concat(tokens)
end

return M