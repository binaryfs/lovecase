--- Simple Enum class.
-- This class is used to demonstrate the lovecase module.
-- @classmod Enum
-- @author binaryfs
-- @copyright 2020
-- @license https://opensource.org/licenses/MIT

local Enum = {}
Enum.__index = Enum

--- Return a new Enum instance with the specified cases.
-- @param cases A table that represents the available enum cases
-- @return The new enum
function Enum.new(cases)
  assert(type(cases) == "table", "Enum constructor requires a table")

  local enum = {}

  for key, value in pairs(cases) do
    if type(key) == "string" then
      enum[key] = value
    elseif type(key) == "number" and type(value) == "string" then
      enum[value] = key
    else
      error("Enum keys must be strings")
    end
  end

  return setmetatable(enum, Enum)
end

--- Get the case of the specified value.
-- @return The case or nil
function Enum:caseOf(value)
  for case, v in pairs(self) do
    if v == value then
      return case
    end
  end
  return nil
end

--- Get the number of enum values.
-- @return Number of values
function Enum:length()
  local length = 0
  for _ in pairs(self) do
    length = length + 1
  end
  return length
end

--- Verify that the enum contains a given value.
-- @raise Enum does not contain the value
-- @return The verified value
function Enum:verify(value)
  if not self:caseOf(value) then
    error("Enum has no case with this value: " .. value)
  end
  return value
end

function Enum:__newindex()
  error("Enum is read-only")
end

return Enum