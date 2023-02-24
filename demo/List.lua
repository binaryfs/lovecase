--- Simple list class.
--- This class is used to demonstrate the lovecase module.
--- @class lovecase.demo.List
local List = {}
List.__index = List

--- Create a new list.
--- @param t? table Optional table that should be used as the list.
--- @return lovecase.demo.List
--- @nodiscard
function List.new(t)
  if t == List then
    error("List constructor was called with : operator")
  end
  return setmetatable(t or {}, List)
end

--- Determine if the given value is an instance of the List class.
--- @param value any
--- @return boolean
--- @nodiscard
function List.isInstance(value)
  return type(value) == "table" and getmetatable(value) == List
end

--- Append a value.
--- @param value any
function List:push(value)
  assert(value ~= nil, "Value must not be nil")
  self[#self + 1] = value
end

--- Insert a value at the given index.
--- @param index integer
--- @param value any
function List:insert(index, value)
  assert(value ~= nil, "Value must not be nil")
  table.insert(self, index, value)
end

--- Remove the value at the specified index and return it.
--- @param index integer
--- @return any # The removed value
function List:remove(index)
  return table.remove(self, index)
end

--- Remove the first occurance of the specified value.
--- @param value any The value to remove.
--- @param startIndex? integer The search starting position (defaults to 1).
--- @return any # The removed value
function List:removeValue(value, startIndex)
  local index = self:indexOf(value, startIndex)
  return index and self:remove(index) or nil
end

--- Remove all values.
function List:clear()
  for i = #self, 1, -1 do
    self[i] = nil
  end
end

--- Check if two lists are equal.
--- @param other lovecase.demo.List The other list
--- @return boolean
--- @nodiscard
function List:equal(other)
  if #self ~= #other then
    return false
  end
  for i = 1, #self do
    if self[i] ~= other[i] then
      return false
    end
  end
  return true
end

--- Get the index of the first occurrence of the given value.
--- @param value any The value to search for.
--- @param startIndex? integer The search starting position (defaults to 1).
--- @return integer? # The found index or nil if the value is not found.
function List:indexOf(value, startIndex)
  for i = startIndex or 1, #self do
    if self[i] == value then
      return i
    end
  end
  return nil
end

--- Reverse the order of list values.
--- @return self
function List:reverse()
  local i = 1
  local j = #self
  while i < j do
    self[i], self[j] = self[j], self[i]
    i = i + 1
    j = j - 1
  end
  return self
end

return List