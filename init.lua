local BASE = (...):gsub("init$", ""):gsub("([^%.])$", "%1%.")
--- @type lovecase.expect
local expect = require(BASE .. "expect")
--- @type lovecase.Report
local Report = require(BASE .. "Report")
--- @type lovecase.Suite
local Suite = require(BASE .. "Suite")

local lovecase = {
  _NAME = "lovecase",
  _DESCRIPTION = "Lightweight unit testing module for LÖVE-based projects",
  _VERSION = "4.1.0",
  _URL = "https://github.com/binaryfs/lovecase",
  _LICENSE = [[
    MIT License

    Copyright (c) 2020-2025 Fabian Staacke

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

local TEST_FILE_DEFAULT_PATTERN = "%-test%.lua$"

lovecase.expect = expect

--- Create a new test suite.
--- @param suiteName string
--- @param callback? fun(suite: lovecase.Suite)
--- @return lovecase.Suite
--- @nodiscard
function lovecase.newSuite(suiteName, callback)
  return Suite.new(suiteName, callback)
end

--- Run the specified test file and return the result.
---
--- If `report` is not specified, a new report is created internally.
--- @param filepath string The path to the test file
--- @param report? lovecase.Report The report that is to record the test results
--- @return lovecase.Report report Report with the test results
function lovecase.runTestFile(filepath, report)
  report = report or Report.new()
  local chunk, errorMessage = love.filesystem.load(filepath)

  if errorMessage then
    error(errorMessage)
  end

  --- @type lovecase.Suite
  local suite = chunk()

  if not Suite.isSuite(suite) then
    error(string.format("Test file '%s' did not return a Suite instance", filepath))
  end

  report:addSuite(suite)

  return report
end

--- Run all test files from the specified directory and return the result.
---
--- If `report` is not specified, a new report is created internally.
--- @param path string The directory path
--- @param recursive? boolean Search for test files recursively (`false`)
--- @param pattern? string The pattern for detecting test files (`"%-test%.lua$"`)
--- @param report? lovecase.Report The report that is to record the test results
--- @return lovecase.Report report Report with the test results
function lovecase.runAllTestFiles(path, recursive, pattern, report)
  pattern = pattern or TEST_FILE_DEFAULT_PATTERN
  report = report or Report.new()
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