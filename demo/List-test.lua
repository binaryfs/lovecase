-- Unit tests for the List class.
-- @author Fabian Staacke
-- @copyright 2020
-- @license https://opensource.org/licenses/MIT

local lovecase = require "lovecase"
local List = require "demo.List"

local test = lovecase.newTestSet("List")

-- Add a check so we can detect values of type List.
test:addTypeCheck(function(value)
  return List.isInstance(value) and "List" or false
end)

-- Add a check so we can compare lists.
test:addEqualityCheck("List", function(list1, list2)
  return list1:equal(list2)
end)

test:group("equal()", function(test)
  test:run("should return true for lists that are equal", function(test)
    test:assertEqual(List.new{1,2,3}, List.new{1,2,3})
    test:assertEqual(List.new(), List.new())
  end)
  test:run("should return false for lists that are different", function(test)
    test:assertNotEqual(List.new{1,2,3}, List.new{3,2,1})
    test:assertNotEqual(List.new{1,2,3}, List.new{1,2})
    test:assertNotEqual(List.new{1,2,3}, List.new())
  end)
end)

test:group("push()", function(test)
  test:run("should add the specified values", function(test)
    local list = List.new()
    list:push(1)
    list:push(2)
    test:assertEqual(list, List.new{1,2})
  end)
  test:run("should not add nil values", function(test)
    local list = List.new()
    test:assertError(function()
      list:push(nil)
    end)
  end)
end)

test:group("clear()", function(test)
  test:run("should remove all values", function(test)
    local list = List.new{1,2,3}
    list:clear()
    test:assertEqual(#list, 0)
  end)
end)

test:group("indexOf()", function(test)
  test:run("should return index of given value", function(test)
    test:assertEqual(List.new{6,7,8,9}:indexOf(8), 3)
  end)
  test:run("should return false if value is not found", function(test)
    test:assertFalse(List.new{6,7,8,9}:indexOf(1))
  end)
end)

test:group("removeValue()", function(test)
  test:run("should remove the value 9", function(test)
    local list = List.new{1,2,9,3}
    list:removeValue(9)
    test:assertEqual(list, List.new{1,2,3})
  end)
  test:run("should return the removed value", function(test)
    local list = List.new{1,2,3}
    test:assertEqual(list:removeValue(1), 1)
  end)
  test:run("should return nil if value is not found", function(test)
    local list = List.new()
    test:assertEqual(list:removeValue(1), nil)
  end)
end)

test:group("reverse()", function(test)
  test:run("should reverse the order of values", function(test)
    test:assertEqual(List.new{1,2,3}:reverse(), List.new{3,2,1})
    test:assertEqual(List.new{1,2,3,4}:reverse(), List.new{4,3,2,1})
  end)
end)

return test