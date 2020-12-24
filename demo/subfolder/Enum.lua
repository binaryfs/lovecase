--- Simple Enum class.
-- This class is used to demonstrate the lovecase module.
-- @classmod Enum
-- @author binaryfs
-- @copyright 2020
-- @license https://opensource.org/licenses/MIT

local Enum = {}
Enum.__index = Enum
Enum._reverseMap = {}

--- Return a new Enum instance with the specified cases.
-- @param cases A table that represents the available enum cases
-- @return The new enum
function Enum.new(cases)
  assert(type(cases) == "table", "Enum constructor requires a table")

  local enum = {}
  Enum._reverseMap[enum] = {}

  -- Add the array-based cases first. The array indices are used as values.
  for index, value in ipairs(cases) do
    enum[value] = index
    Enum._reverseMap[enum][index] = value
  end

  -- Now add the hash-based cases.
  for key, value in pairs(cases) do
    if not enum[key] then
      enum[key] = value
      Enum._reverseMap[enum][value] = key
    end
  end

  return setmetatable(enum, Enum)
end

--- Get the case of the specified value.
-- @return The case or nil
function Enum:caseOf(value)
  return Enum._reverseMap[self][value]
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