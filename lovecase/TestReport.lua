local BASE = (...):gsub("%.TestReport$", "")
local helpers = require(BASE .. ".helpers")

--- The TestReport class encapsulates the result of a test set.
--- @class lovecase.TestReport
--- @field protected _options table
--- @field protected _lines string[]
--- @field protected _depth integer
--- @field protected _failedCount integer
--- @field protected _passedCount integer
local TestReport = {}
TestReport.__index = TestReport

--- Create a new test report.
---
--- See `lovecase.newTestReport` for a list of valid options. 
--- @param options? table
--- @return lovecase.TestReport
--- @nodiscard
function TestReport.new(options)
  local instance = setmetatable({
    _options = {
      indentSpaces = 4,
      failedPrefix = "FAILED: ",
      failedResultLine = "\n\n%s tests failed",
      passedPrefix = "PASSED: ",
      passedResultLine = "\n\n%s out of %s tests passed",
      onlyFailures = false,
    },
    _lines = {},
    _depth = 0,
    _failedCount = 0,
    _passedCount = 0
  }, TestReport)

  if options then
    helpers.assertArgument(1, options, "table")
    for key, value in pairs(options) do
      instance._options[key] = value
    end
  end

  return instance
end

--- Determine if the given value is an instance of the TestReport class.
--- @param value any The value
--- @return boolean
--- @nodiscard
function TestReport.isInstance(value)
  return type(value) == "table" and getmetatable(value) == TestReport
end

--- Return true if the test set is failed, false otherwise.
--- @return boolean
--- @nodiscard
function TestReport:isFailed()
  return self._failedCount > 0
end

--- Add a group to the report.
--- @param groupName string The group name
--- @param failed boolean True if one of the contained tests failed
--- @param groupFunc function A function that provides the group closure
function TestReport:addGroup(groupName, failed, groupFunc)
  helpers.assertArgument(1, groupName, "string")
  helpers.assertArgument(2, groupFunc, "function")
  if failed or not self._options.onlyFailures then
    self:_writeLine(groupName)
    self._depth = self._depth + 1
    groupFunc()
    self._depth = self._depth - 1
  end
end

--- Add a test result to the report.
--- @param testName string The name of the test
--- @param failed boolean True for a failed test, false otherwise
--- @param reason? string The error message if the test failed
function TestReport:addResult(testName, failed, reason)
  helpers.assertArgument(1, testName, "string")
  if failed then
    helpers.assertArgument(3, reason, "string")
    self:_writeLine(self._options.failedPrefix .. testName)
    self:_writeLine(reason --[[@as string]], self._depth + 1)
    self._failedCount = self._failedCount + 1
  elseif not self._options.onlyFailures then
    self:_writeLine(self._options.passedPrefix .. testName)
    self._passedCount = self._passedCount + 1
  end
end

--- Get the test results formatted as string.
--- @return string
--- @nodiscard
function TestReport:printResults()
  local report = table.concat(self._lines, "\n")
  local result
  if self._options.onlyFailures then
    result = string.format(self._options.failedResultLine, self._failedCount)
  else
    result = string.format(
      self._options.passedResultLine,
      self._passedCount,
      self._passedCount + self._failedCount
    )
  end
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
  local indent = string.rep(" ", self._options.indentSpaces * (depth or self._depth))
  self._lines[#self._lines + 1] = indent .. message
end

return TestReport