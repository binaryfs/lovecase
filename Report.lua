--- The Report class contains the results of one or more test suites.
--- @class lovecase.Report
--- @field private lines string[]
--- @field private totalTestCount integer
--- @field private failedTestCount integer
local Report = {}
Report.__index = Report

--- @return lovecase.Report
--- @nodiscard
function Report.new()
  return setmetatable({
    lines = {},
    totalTestCount = 0,
    failedTestCount = 0
  }, Report)
end

--- Determine if the given object is an instance of the Report class.
--- @param value any The value
--- @return boolean
--- @nodiscard
function Report.isReport(value)
  return type(value) == "table" and getmetatable(value) == Report
end

--- Return true if the report contains any failed tests, false otherwise.
--- @return boolean
--- @nodiscard
function Report:hasErrors()
  return self.failedTestCount > 0
end

--- Add the test results of the specified suite to the report.
--- @param suite lovecase.Suite
function Report:addSuite(suite)
  local total, failed = suite:getTestCount()
  self.totalTestCount = self.totalTestCount + total
  self.failedTestCount = self.failedTestCount + failed
  suite:write(self.lines)
end

--- Get the test results as a string.
--- @return string
--- @nodiscard
function Report:getResults()
  local report = table.concat(self.lines, "\n")
  local result = string.format(
    "%d of %d tests passed",
    self.totalTestCount - self.failedTestCount,
    self.totalTestCount
  )
  if report ~= "" then
    report = report .. "\n"
  end
  return report.. result
end

return Report