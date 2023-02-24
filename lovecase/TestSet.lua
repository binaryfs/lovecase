local BASE = (...):gsub("%.TestSet$", "")
local helpers = require(BASE .. ".helpers")

--- @alias lovecase.TestCallback fun(test: lovecase.TestSet)
--- @alias lovecase.EqualityCheck fun(a: any, b: any): boolean
--- @alias lovecase.TypeCheck fun(t: table): string|false

--- The TestSet class represents a collection of test cases.
--- @class lovecase.TestSet
--- @field protected _groupStack table[]
--- @field protected _typeChecks lovecase.TypeCheck[]
--- @field protected _equalityChecks table<string, lovecase.EqualityCheck>
local TestSet = {}
TestSet.__index = TestSet

--- Determine if the given value is an instance of the TestSet class.
--- @param value any
--- @return boolean
--- @nodiscard
function TestSet.isInstance(value)
  return type(value) == "table" and getmetatable(value) == TestSet
end

--- Add an equality function for a custom type.
---
--- The equality function takes to arguments and should return true if the values
--- are considered equal.
---
--- Usage:
--- ```
--- test:addEqualityCheck("Point", function(p1, p2)
---   return p1.x == p2.x and p1.y == p2.y
--- end)
--- ```
--- @param typename string The type identifier, determined by the type checker.
--- @param func lovecase.EqualityCheck The equality function. 
function TestSet:addEqualityCheck(typename, func)
  helpers.assertArgument(1, typename, "string")
  helpers.assertArgument(2, func, "function")
  self._equalityChecks[typename] = func
end

--- Add a custom type checking function to determine the type of custom tables.
---
--- The type checking function expects a table whose type is to be determined and should
--- return the type identifier if successful and false otherwise.
---
--- Usage:
--- ```
--- test:addTypeCheck(function(value)
---   return Point.isInstance(value) and "Point" or false
--- end)
--- ```
--- @param func lovecase.TypeCheck The type checking function
function TestSet:addTypeCheck(func)
  helpers.assertArgument(1, func, "function")
  table.insert(self._typeChecks, func)
end

--- Add a named test group.
--- @param groupName string The group name
--- @param groupFunc lovecase.TestCallback A function that contains the grouped test cases
function TestSet:group(groupName, groupFunc)
  helpers.assertArgument(1, groupName, "string")
  helpers.assertArgument(2, groupFunc, "function")

  self:_pushGroup(groupName)
  groupFunc(self)
  self:_popGroup()
end

--- Run the specified test.
--- @param testName string The name of the test
--- @param testFunc lovecase.TestCallback A function that provides the test
function TestSet:run(testName, testFunc)
  helpers.assertArgument(1, testName, "string")
  helpers.assertArgument(2, testFunc, "function")

  local passed, message = pcall(testFunc, self)
  -- Add the test result to the current group.
  table.insert(self:_peekGroup(), {
    name = testName,
    failed = not passed,
    error = message
  })
end

--- Assert that the given value is true.
--- @param value any The value
--- @param name? string The name by which the value is displayed in the error message
function TestSet:assertTrue(value, name)
  self:assertEqual(value, true, name)
end

--- Assert that the given value is false.
--- @param value any The value
--- @param name? string The name by which the value is displayed in the error message
function TestSet:assertFalse(value, name)
  self:assertEqual(value, false, name)
end

--- Assert that a given value is equal to an expected value.
--- @param value any The actual value
--- @param expected any The expected value
--- @param name? string The name by which the value is displayed in the error message
function TestSet:assertEqual(value, expected, name)
  if not self:_valuesEqual(value, expected) then
    error(string.format(
      "%s was expected to be %s but was %s", name or "Value", expected, value
    ), 0)
  end
end

--- Assert that a given value is not equal to another value.
--- @param value any The actual value
--- @param unexpected any The other value
--- @param name? string The name by which the value is displayed in the error message
function TestSet:assertNotEqual(value, unexpected, name)
  if self:_valuesEqual(value, unexpected) then
    error(string.format("%s was not expected to be %s", name or "Value", unexpected), 0)
  end
end

--- Assert that the given function throws an error when called.
--- @param func function The function
--- @param message? string The error message if the assertion fails
function TestSet:assertError(func, message)
  if pcall(func) then
    error(message or "The function was expected to throw an error", 0)
  end
end

--- Write the test results into the given report.
--- @param report lovecase.TestReport The report
--- @return lovecase.TestReport # The report
function TestSet:writeReport(report)
  self:_writeReport(report, self._groupStack[1])
  return report
end

--- Get a string representation of the test set.
--- @return string
function TestSet:__tostring()
  return string.format("<TestSet '%s' (%s)>", self._groupStack[1].name, helpers.rawtostring(self))
end

--- Internal function to write a report.
--- @param report lovecase.TestReport The report
--- @param group table The current test group to write into the report
--- @protected
function TestSet:_writeReport(report, group)
  report:addGroup(group.name, function(report)
    for _, test in ipairs(group) do
      report:addResult(test.name, test.failed, test.error)
    end
    for _, subgroup in ipairs(group.subgroups) do
      self:_writeReport(report, subgroup)
    end
  end)
end

--- Test if two given values are equal.
---
--- The equality operator == is used to compare the values. If both values
--- have the same type and there is an equality function available
--- for this type, the equality function is used instead. 
--- @param value1 any The first value
--- @param value2 any The second value
--- @return boolean # true if the values are considered equal, false otherwise.
--- @nodiscard
--- @protected
function TestSet:_valuesEqual(value1, value2)
  local type1 = self:_determineType(value1)
  -- Restrict custom equality checks to tables.
  if type(value1) == "table" and type1 == self:_determineType(value2) then
    local equalityCheck = self._equalityChecks[type1]
    if equalityCheck then
      return equalityCheck(value1, value2)
    end
  end
  return value1 == value2
end

--- Determine the type of the given value.
---
--- If none of the registered type checks can determine the type, the type()
--- function of Lua is used as a fallback.
--- @param value any The value
--- @return string The value's type
--- @nodiscard
--- @protected
function TestSet:_determineType(value)
  local typeOfValue = type(value)
  if typeOfValue == "table" then
    -- Check if this table is a custom type.
    for _, typeCheck in ipairs(self._typeChecks) do
      local result = typeCheck(value)
      if result then
        return result
      end
    end
  end
  return typeOfValue
end

--- Push a new group onto the stack.
--- @param groupName string The name of the group
--- @protected
function TestSet:_pushGroup(groupName)
  local newGroup = {
    name = groupName,
    subgroups = {}
  }

  if #self._groupStack > 0 then
    table.insert(self:_peekGroup().subgroups, newGroup)
  end

  self._groupStack[#self._groupStack + 1] = newGroup
end

--- Remove the topmost group from the stack.
--- @protected
function TestSet:_popGroup()
  assert(table.remove(self._groupStack), "Cannot pop empty stack")
end

--- Get the topmost group from the stack.
--- @return table # The topmost group
--- @protected
function TestSet:_peekGroup()
  return self._groupStack[#self._groupStack]
end

return TestSet