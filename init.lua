local BASE = (...):gsub("init$", ""):gsub("([^%.])$", "%1%.")
local TestSet = require(BASE .. "TestSet")
local TestReport = require(BASE .. "TestReport")

local lovecase = {
  _NAME = "lovecase",
  _DESCRIPTION = "Lightweight unit testing module that integrates well into the LÖVE framework",
  _VERSION = "3.1.1",
  _URL = "https://github.com/binaryfs/lovecase",
  _LICENSE = [[
    MIT License

    Copyright (c) 2020 Fabian Staacke

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
  ]],
}

--- The pattern that is used to detect test files if no custom pattern is specified.
local TEST_FILE_PATTERN = "%-test%.lua$"

--- Create a new test set.
--- @param name string The name of the test set
--- @return lovecase.TestSet
--- @nodiscard
--- @see lovecase.TestSet.new
function lovecase.newTestSet(name)
  return TestSet.new(name)
end

--- Create a new test report.
---
--- The `options` table can have the folloing fields:
--- * `indentSpaces` - Number of spaces per indention level
--- * `onlyFailures` - If true, show only failed tests
--- * `failedPrefix` - Prefix for failed tests
--- * `failedResultLine` - Format string to show number of failed tests
--- * `passedPrefix` - Prefix for passed tests
--- * `passedResultLine` - Format string to show number of passed tests
--- @param options? table
--- @return lovecase.TestReport
--- @nodiscard
--- @see lovecase.TestReport.new
function lovecase.newTestReport(options)
  return TestReport.new(options)
end

--- Run the specified unit test file and return the result.
---
--- The result is written into a `TestReport` instance. If no such report is specified, a
--- new report is created internally.
--- @param filepath string The path to the unit test file
--- @param report? lovecase.TestReport The report into which the test results are to be written
--- @return lovecase.TestReport # A report with the test results
function lovecase.runTestFile(filepath, report)
  if report and not TestReport.isInstance(report) then
    error("TestReport object expected, got: " .. type(report))
  end

  local chunk, err = love.filesystem.load(filepath)
  if err then
    error(err)
  end

  local test = chunk()
  if not TestSet.isInstance(test) then
    error("Loaded file did not return a TestSet: " .. filepath)
  end

  return test:writeReport(report or lovecase.newTestReport())
end

--- Run all unit test files from the specified directory and return the results.
---
--- The result is written into a `TestReport` instance. If no such report is specified, a
--- new report is created internally.
--- @param path string The directory path
--- @param recursive? boolean Search for test files recursively (default: false)
--- @param pattern? string The pattern for detecting test files (default: `lovecase.TEST_FILE_PATTERN`)
--- @param report? lovecase.TestReport The report into which the test results are to be written
--- @return lovecase.TestReport # A report with the test results
function lovecase.runAllTestFiles(path, recursive, pattern, report)
  pattern = pattern or TEST_FILE_PATTERN
  report = report or lovecase.newTestReport()
  local items = love.filesystem.getDirectoryItems(path)

  for _, item in ipairs(items) do
    local itemPath = path:gsub("[/\\]$", "") .. "/" .. item
    local info = love.filesystem.getInfo(itemPath)

    if info.type == "file" and string.match(item, pattern) then
      lovecase.runTestFile(itemPath, report)
    elseif recursive and info.type == "directory" then
      lovecase.runAllTestFiles(itemPath, true, pattern, report)
    end
  end

  return report
end

return lovecase