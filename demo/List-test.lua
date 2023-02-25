-- Unit tests for the List class.

local lovecase = require("lovecase")
local List = require("demo.List")

local test = lovecase.newTestSet("List")

-- Add a check so that lovecase can detect List instances.
test:addTypeCheck(function(value)
  return List.isInstance(value) and "List" or false
end)

-- Add a check so that lovecase can compare lists.
-- Alternatively you could also overload the == operator for lists.
test:addEqualityCheck("List", function(list1, list2)
  return list1:equal(list2)
end)

test:group("equal()", function()
  test:run("should return true for lists that are equal", function()
    test:assertEqual(List.new{1,2,3}, List.new{1,2,3})
    test:assertEqual(List.new(), List.new())
  end)
  test:run("should return false for lists that are different", function(first, second)
    test:assertNotEqual(List.new(first), List.new(second))
  end, {
    {{1,2,3}, {3,2,1}},
    {{1,2,3}, {1,2}},
    {{1,2,3}, {}}
  })
end)

test:group("push()", function()
  test:run("should add the specified values", function()
    local list = List.new()
    list:push(1)
    list:push(2)
    test:assertEqual(list, List.new{1,2})
  end)
  test:run("should not add nil values", function()
    local list = List.new()
    test:assertError(function()
      list:push(nil)
    end)
  end)
end)

test:group("clear()", function()
  test:run("should remove all values", function()
    local list = List.new{1,2,3}
    list:clear()
    test:assertEqual(#list, 0)
  end)
end)

test:group("indexOf()", function()
  test:run("should return index of given value", function()
    test:assertEqual(List.new{6,7,8,9}:indexOf(8), 3)
  end)
  test:run("should return nil if value is not found", function()
    test:assertEqual(List.new{6,7,8,9}:indexOf(1), nil)
  end)
end)

test:group("removeValue()", function()
  test:run("should remove the specified value", function()
    local list = List.new{1,2,9,3}
    list:removeValue(9)
    test:assertEqual(list, List.new{1,2,3})
  end)
  test:run("should return the removed value", function()
    local list = List.new{1,2,3}
    test:assertEqual(list:removeValue(1), 1)
  end)
  test:run("should return nil if value is not present", function()
    local list = List.new()
    test:assertEqual(list:removeValue(1), nil)
  end)
end)

test:group("reverse()", function()
  test:run("should reverse the order of values", function()
    test:assertEqual(List.new{1,2,3,4}:reverse(), List.new{4,3,2,1})
  end)
end)

return test