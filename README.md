# lovecase
Lightweight unit testing module for [LÖVE](https://love2d.org/)-based projects. It relies on built-in features of Lua and LÖVE and has no external dependencies.

lovecase was built to be used in LÖVE 11.x but might work in earlier versions just as well. It does not provide any kind of mocking framework and also does not even try to isolate your code. So the unit tests defined by lovecase do not match the accepted definition of unit tests very well.

## Example

This is how a unit test file written with lovecase looks like:

```lua
-- Unit tests for a List class.

local lovecase = require("libs.lovecase")
local List = require("List")

local expect = lovecase.expect
local suite = lovecase.newSuite("List Tests")

-- You can group several test cases together (subgroups work as well).
suite:describe("removeValue()", function ()
  suite:test("should remove the specified value", function ()
    local list = List.new{1,2,9,3}
    list:removeValue(9)
    expect.equal(list, List.new{1,2,3})
  end)
  suite:test("should return nil if value is not present", function ()
    local list = List.new()
    expect.equal(list:removeValue(1), nil)
  end)
end)

-- Grouping is optional, though.
suite:test("reverse() should reverse the order of values", function ()
  expect.equal(List.new{1,2,3,4}:reverse(), List.new{4,3,2,1})
end)

-- You can provide your test cases with test data.
-- The test case is repeated for each row in the test data table.
suite:test("remove() should remove the value at the specified index", function (input, index, expected)
  local actual = List.new(input)
  actual:remove(index)
  expect.equal(actual, List.new(expected))
end, {
  { {6,7,8,9}, 1, {7,8,9} },
  { {6,7,8,9}, 4, {6,7,8} },
})

-- Your unit test files have to return the test suite.
return suite
```

Assuming that the above file is named `List-test.lua`, the test cases can be run as follows:

```lua
local report = lovecase.runTestFile("path/to/List-test.lua")
print(report:getResults()) -- Show the results.
```

You can also run all test files from a given directory (recursively, if you like). By default, all files whose names end with `-test.lua` are considered test files:

```lua
local report = lovecase.runAllTestFiles("directory/with/tests")
```

And this is how a printed test report looks like:

```
List Tests
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

## Assertions

Use `lovecase.expect` to make assertions about a value, e.g. `lovecase.expect.notEqual(4, 2)`.

This is a list of all available assertions:

- `equal(a, b)`
- `notEqual(a, b)`
- `lessThan(a, b)`
- `lessThanOrEqual(a, b)`
- `greaterThan(a, b)`
- `greaterThanOrEqual(a, b)`
- `isTrue(a)`
- `isFalse(a)`
- `same(a, b)` – Always uses the raw `==` operator for equality checks.
- `notSame(a, b)` – Always uses the raw `==` operator for equality checks.
- `almostEqual(a, b)` – Compares numbers with tolerance (also works with nested tables).
- `notAlmostEqual(a, b)` – Compares numbers with tolerance (also works with nested tables).
- `error(a)` – Asserts that a function raises an error.
- `noError(a)`

## Demo

lovecase ships with a LÖVE demo script that provides some working example test cases.

## FAQ

### How are tables compared for equality?

lovecase tries the following options to compare tables:

- Use the `__eq` metamethod to compare the tables, if possible.
- Use a method named `equal` or `equals` to compare the tables, if the same method exists in both tables (e.g. `t1:equal(t2)`)
- Perform a deep comparison between the tables to determine if they are equivalent.

### How and where to run the tests?

A proven approach is to create a game state dedicated to running unit tests. Set this state as the initial state if the game is started in dev mode. Show the test results if any test fails, switch to the next state otherwise.

Example:

```lua
function TestState:onEnter()
  local report = lovecase.runAllTestFiles("directory/with/tests", true)

  if report:hasErrors() then
    print(report:getResults())
  else
    self:switchToState("MainMenu")
  end
end
```

## License

MIT License (see LICENSE file in project root)
