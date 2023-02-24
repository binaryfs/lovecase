local BASE = (...):gsub("%.TestReport$", "")
local helpers = require(BASE .. ".helpers")

--- The TestReport class encapsulates the result of a test set.
--- @class lovecase.TestReport
--- @field protected _lines table
--- @field protected _depth integer
--- @field protected _failed integer
--- @field protected _passed integer
local TestReport = {}
TestReport.__index = TestReport

TestReport.INDENT_SPACES = 4
TestReport.FAILED_PREFIX = "FAILED: "
TestReport.PASSED_PREFIX = "PASSED: "
TestReport.RESULT_LINE = "\n\n%s of %s tests passing"

--- Determine if the given value is an instance of the TestReport class.
--- @param value any The value
--- @return boolean
--- @nodiscard
function TestReport.isInstance(value)
  return type(value) == "table" and getmetatable(value) == TestReport
end

--- Add a group to the report.
--- @param groupName string The group name
--- @param groupFunc function A function that provides the group closure
function TestReport:addGroup(groupName, groupFunc)
  helpers.assertArgument(1, groupName, "string")
  helpers.assertArgument(2, groupFunc, "function")
  self:_writeLine(groupName)
  self._depth = self._depth + 1
  groupFunc(self)
  self._depth = self._depth - 1
end

--- Add a test result to the report.
--- @param testName string The name of the test
--- @param failed boolean True for a failed test, false otherwise
--- @param reason? string The error message if the test failed
function TestReport:addResult(testName, failed, reason)
  helpers.assertArgument(1, testName, "string")
  if failed then
    helpers.assertArgument(3, reason, "string")
    self:_writeLine(self.FAILED_PREFIX .. testName)
    self:_writeLine(reason or "Unknown reason", self._depth + 1)
    self._failed = self._failed + 1
  else
    self:_writeLine(self.PASSED_PREFIX .. testName)
    self._passed = self._passed + 1
  end
end

--- Get the test results formatted as string.
--- @return string
--- @nodiscard
function TestReport:printResults()
  local report = table.concat(self._lines, "\n")
  local result = string.format(
    self.RESULT_LINE,
    self._passed,
    self._passed + self._failed
  )
  return report .. result
end

--- Get an iterator over the lines of the report.
---
--- Usage:
--- ```
--- for i, line in report:lines() do
---   print(i .. ". " .. line)
--- end
--- ```
--- @return function
--- @return table
--- @return integer
function TestReport:lines()
  return ipairs(self._lines)
end

--- Get a (technical) string representation of the report.
--- @return string
function TestReport:__tostring()
  return string.format("<TestReport (%s)>", helpers.rawtostring(self))
end

--- Write a test line into the report.
--- @param message string The message to write
--- @param depth? integer The indentation depth (overrides default)
--- @protected
function TestReport:_writeLine(message, depth)
  local indent = string.rep(" ", self.INDENT_SPACES * (depth or self._depth))
  self._lines[#self._lines + 1] = indent .. message
end

return TestReport