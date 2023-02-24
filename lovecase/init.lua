local BASE = (...):gsub("%.init$", "")
local TestSet = require(BASE .. ".TestSet")
local TestReport = require(BASE .. ".TestReport")

local lovecase = {
  _NAME = "lovecase",
  _DESCRIPTION = "Lightweight unit testing module that integrates well into the LÖVE framework",
  _VERSION = "2.0.0",
  _URL = "https://github.com/binaryfs/lua-lovecase",
  _LICENSE = "MIT License",
  _COPYRIGHT = "Copyright (c) 2020 binaryfs",

  --- The pattern that is used to detect test files if no custom pattern is specified.
  TEST_FILE_PATTERN = "%-test%.lua$"
}

--- Create a new test set.
--- @param name string The name of the test set
--- @return lovecase.TestSet
--- @nodiscard
function lovecase.newTestSet(name)
  assert(type(name) == "string" and name ~= "", "Please name your TestSet")

  local instance = setmetatable({
    _groupStack = {},
    _typeChecks = {},
    _equalityChecks = {}
  }, TestSet)

  instance:_pushGroup(name)
  return instance
end

--- Create a new test report.
--- @return lovecase.TestReport
--- @nodiscard
function lovecase.newTestReport()
  return setmetatable({
    _lines = {},
    _depth = 0,
    _failed = 0,
    _passed = 0
  }, TestReport)
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
  pattern = pattern or lovecase.TEST_FILE_PATTERN
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