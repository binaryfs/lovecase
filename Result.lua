local BASE = (...):gsub("[^%.]*$", "")
--- @type lovecase.utils
local utils = require(BASE .. "utils")

--- An internal class to represent the result of a test case.
--- @class lovecase.Result
--- @field private testName string
--- @field private passed boolean
--- @field private failedMessage string|nil
local Result = {}
Result.__index = Result

--- @param testName string
--- @param passed boolean
--- @param failedMessage? string
--- @return lovecase.Result
--- @nodiscard
function Result.new(testName, passed, failedMessage)
  return setmetatable({
    testName = testName,
    passed = passed,
    failedMessage = failedMessage,
  }, Result)
end

--- @return boolean
--- @nodiscard
function Result:isPassed()
  return self.passed
end

--- Write the test results into the specified output table.
--- @param output string[]
--- @param depth integer
function Result:write(output, depth)
  if not self.passed then
    table.insert(output, utils.indent(depth) .. "FAILED: " .. self.testName)
    table.insert(output, utils.indent(depth + 1) .. (self.failedMessage or "No error message"))
  end
end

return Result