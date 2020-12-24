--- The TestSet class represents a collection of test cases.
-- @classmod lovecase.TestSet
-- @author binaryfs
-- @copyright 2020
-- @license https://opensource.org/licenses/MIT

local BASE = (...):gsub("%.TestSet$", "")
local helpers = require(BASE .. ".helpers")

local TestSet = {}
TestSet.__index = TestSet

--- Determine if the given value is an instance of the TestSet class.
-- @param value The value
-- @return True or false
function TestSet.isInstance(value)
  return type(value) == "table" and getmetatable(value) == TestSet
end

--- Add an equality function for a custom type.
--
-- @param typename The type identifier, determined by the type checker.
-- @param func The equality function. The function expects the two values to be compared
--   as arguments and should return true if the values are considered equal.
--
-- @usage
-- test:addEqualityCheck("Point", function(p1, p2)
--   return p1.x == p2.x and p1.y == p2.y
-- end)
function TestSet:addEqualityCheck(typename, func)
  helpers.assertArgument(1, typename, "string")
  helpers.assertArgument(2, func, "function")
  self._equalityChecks[typename] = func
end

--- Add a custom type checking function to determine the type of custom tables.
--
-- @param func The type checking function. The function expects a table whose type is
--   to be determined and should return the type identifier if successful and false otherwise.
--
-- @usage
-- test:addTypeCheck(function(value)
--   return Point.isInstance(value) and "Point" or false
-- end)
function TestSet:addTypeCheck(func)
  helpers.assertArgument(1, func, "function")
  table.insert(self._typeChecks, func)
end

--- Add a named test group.
--
-- @param groupName The group name
-- @param groupFunc A function that contains the grouped test cases. The function expects
--   the TestSet instance as its only argument and doesn't return anything.
function TestSet:group(groupName, groupFunc)
  helpers.assertArgument(1, groupName, "string")
  helpers.assertArgument(2, groupFunc, "function")

  self:_pushGroup(groupName)
  groupFunc(self)
  self:_popGroup()
end

--- Run the specified test.
--
-- @param testName The name of the test
-- @param testFunc A function that provides the test. The function expects the TestCase
--   instance as its only argument and doesn't return anything.
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
--
-- @param value The value
-- @param[opt] message Error message if the assertion fails
--
-- @raise if the assertion fails
function TestSet:assertTrue(value, message)
  self:assertEqual(value, true, message)
end

--- Assert that the given value is false.
--
-- @param value The value
-- @param[opt] message Error message if the assertion fails
--
-- @raise if the assertion fails
function TestSet:assertFalse(value, message)
  self:assertEqual(value, false, message)
end

--- Assert that a given value is equal to an expected value.
--
-- @param actual The actual value
-- @param expected The expected value
-- @param[opt] message Error message if the assertion fails
--
-- @raise if the assertion fails
function TestSet:assertEqual(actual, expected, message)
  if not self:_valuesEqual(actual, expected) then
    error(string.format(message or "Value was expected to be %s but was %s", expected, actual), 0)
  end
end

--- Assert that a given value is not equal to another value.
--
-- @param actual The actual value
-- @param unexpected The other value
-- @param[opt] message Error message if the assertion fails
--
-- @raise if the assertion fails
function TestSet:assertNotEqual(actual, unexpected, message)
  if self:_valuesEqual(actual, unexpected) then
    error(string.format(message or "Value was not expected to be %s", unexpected), 0)
  end
end

--- Assert that the given function throws an error when called.
--
-- @param func The function
-- @param[opt] message Error message if the assertion fails
--
-- @raise if the assertion fails
function TestSet:assertError(func, message)
  if pcall(func) then
    error(message or "The function was expected to throw an error", 0)
  end
end

--- Write the test results into the given report.
-- @param report The report (a TestReport instance)
-- @return The report
function TestSet:writeReport(report)
  self:_writeReport(report, self._groupStack[1])
  return report
end

--- Get a string representation of the test set.
-- @treturn string
function TestSet:__tostring()
  return string.format("<TestSet '%s' (%s)>", self._groupStack[1].name, helpers.rawtostring(self))
end

--- Internal function to write a report.
-- @param report The report (a TestReport instance)
-- @param group The current test group to write into the report
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
--
-- The equality operator == is used to compare the values. If both values
-- have the same type and there is an equality function available
-- for this type, the equality function is used instead. 
--
-- @param value1 The first value
-- @param value2 The second value
-- @return true if the values are considered equal, false otherwise.
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
--
-- If none of the registered type checks can determine the type, the type()
-- function of Lua is used as a fallback.
--
-- @param value The value
-- @return The value's type
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
-- @param groupName The name of the group
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
function TestSet:_popGroup()
  assert(table.remove(self._groupStack), "Cannot pop empty stack")
end

--- Get the topmost group from the stack.
-- @return The topmost group
function TestSet:_peekGroup()
  return self._groupStack[#self._groupStack]
end

return TestSet