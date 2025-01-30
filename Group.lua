local BASE = (...):gsub("[^%.]*$", "")
--- @type lovecase.utils
local utils = require(BASE .. "utils")

--- Internal calss to represent a group of test cases.
--- @class lovecase.Group
--- @field private name string
--- @field private parentGroup lovecase.Group|nil
--- @field private results lovecase.Result[]
--- @field private subgroups lovecase.Group[]
--- @field private totalTestCount integer Number of tests in this group and subgroups
--- @field private failedTestCount integer
local Group = {}
Group.__index = Group

--- @param name string
--- @param parentGroup? lovecase.Group
--- @return lovecase.Group
--- @nodiscard
function Group.new(name, parentGroup)
  return setmetatable({
    name = name,
    parentGroup = parentGroup,
    results = {},
    subgroups = {},
    totalTestCount = 0,
    failedTestCount = 0,
  }, Group)
end

--- Return the total number of tests and the number of failed tests.
--- @return integer total
--- @return integer failed
--- @nodiscard
function Group:getTestCount()
  return self.totalTestCount, self.failedTestCount
end

--- @param result lovecase.Result
function Group:addResult(result)
  table.insert(self.results, result)
  self:updateTestCount(result:isPassed())
end

--- @param subgroup lovecase.Group
function Group:addSubgroup(subgroup)
  table.insert(self.subgroups, subgroup)
end

--- Write the test results of the group into the specified output table.
--- @param output string[]
--- @param depth integer
function Group:write(output, depth)
  if self.failedTestCount == 0 then
    return
  end

  local header = string.format(
    "%s (%d/%d passed)",
    self.name,
    self.totalTestCount - self.failedTestCount,
    self.totalTestCount
  )

  table.insert(output, utils.indent(depth) .. header)

  for _, result in ipairs(self.results) do
    result:write(output, depth + 1)
  end

  for _, subgroup in ipairs(self.subgroups) do
    subgroup:write(output, depth + 1)
  end
end

--- @param testPassed boolean
--- @private
function Group:updateTestCount(testPassed)
  local current = self

  while current do
    current.totalTestCount = current.totalTestCount + 1

    if not testPassed then
      current.failedTestCount = current.failedTestCount + 1
    end

    current = current.parentGroup
  end
end

return Group