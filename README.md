# lua-lovecase
Lightweight unit testing module written in Lua that integrates well into the [LÖVE](https://love2d.org/) framework.

lovecase was built to be used in LÖVE 11.x with LuaJIT but might work in earlier versions just as well.

## Example

This is how a unit test file written with lovecase looks like:

```lua
-- Unit tests for a List class.

local lovecase = require "lovecase"
local List = require "List"
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

-- You can group several test cases together (subgroups work as well).
test:group("removeValue()", function(test)
  test:run("should remove the specified value", function()
    local list = List.new{1,2,9,3}
    list:removeValue(9)
    test:assertEqual(list, List.new{1,2,3})
  end)
  test:run("should return nil if value is not present", function()
    local list = List.new()
    test:assertEqual(list:removeValue(1), nil)
  end)
end)

-- Grouping is optional, though.
test:run("reverse() should reverse the order of values", function()
  test:assertEqual(List.new{1,2,3,4}:reverse(), List.new{4,3,2,1})
end)

return test
```

Assuming that the above file is named `List-test.lua`, the test cases can be run as follows:

```lua
local report = lovecase.runTestFile("path/to/List-test.lua")
print(report:printResults()) -- Show the results.
```

You can also run all test files from a given directory (recursively, if you like). By default, all files whose names end with `-test.lua` are considered test files:

```lua
local report = lovecase.runAllTestFiles("directory/with/tests")
```

And this is how a printed test report looks like:

```
List
  equal()
    PASSED: should return true for lists that are equal
    PASSED: should return false for lists that are different
  push()
    PASSED: should add the specified values
    PASSED: should not add nil values
  clear()
    PASSED: should remove all values
  indexOf()
    PASSED: should return index of given value
    PASSED: should return false if value is not found
  removeValue()
    PASSED: should remove the specified value
    PASSED: should return the removed value
    FAILED: should return nil if value is not present
      Result was expected to be false but was nil
  reverse()
    PASSED: should reverse the order of values
```

## Demo

lovecase ships with a LÖVE demo script that provides some working example test cases.

## License

MIT License (see LICENSE file in project root)
