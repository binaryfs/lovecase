local BASE = (...):gsub("[^%.]*$", "")
--- @type lovecase.Group
local Group = require(BASE .. "Group")
--- @type lovecase.Result
local Result = require(BASE .. "Result")

--- Represents a collection of groups and test cases.
--- @class lovecase.Suite
--- @field private totalTestCount integer
--- @field private failedTestCount integer
--- @field private groupStack lovecase.Group[]
local Suite = {}
Suite.__index = Suite

--- @param suiteName string
--- @param callback? fun(suite: lovecase.Suite)
--- @return lovecase.Suite
--- @nodiscard
function Suite.new(suiteName, callback)
  --- @type lovecase.Suite
  local suite = setmetatable({}, Suite)

  suite.totalTestCount = 0
  suite.failedTestCount = 0
  suite.groupStack = {}
  suite:pushGroup(suiteName)

  if type(callback) == "function" then
    callback(suite)
  end

  return suite
end

--- Determine if the specified object is an instance of the Suite class.
--- @param object any
--- @return boolean
--- @nodiscard
function Suite.isSuite(object)
  return type(object) == "table" and getmetatable(object) == Suite
end

--- Return the total number of tests and the number of failed tests.
--- @return integer total
--- @return integer failed
--- @nodiscard
function Suite:getTestCount()
  return self.groupStack[1]:getTestCount()
end

--- @param name string
--- @param func function
function Suite:describe(name, func)
  self:pushGroup(name)
  func()
  self:popGroup()
end

--- Perform a test with optional test data.
--- @param testName string
--- @param func function
--- @param data? table Test data that should be passed to `func`
function Suite:test(testName, func, data)
  local passed, failedMessage

  if data then
    for i = 1, #data do
      passed, failedMessage = pcall(func, unpack(data[i]))
      if not passed then
        break
      end
    end
  else
    passed, failedMessage = pcall(func)
  end

  local result = Result.new(testName, passed, failedMessage)
  self:getCurrentGroup():addResult(result)
end

--- Write the test results of the suite into the specified output table.
--- @param output string[]
function Suite:write(output)
  self.groupStack[1]:write(output, 0)
end

--- @return lovecase.Group currentGroup
--- @nodiscard
--- @private
function Suite:getCurrentGroup()
  return self.groupStack[#self.groupStack]
end

--- Push a new group onto the stack.
--- @param groupName string
--- @private
function Suite:pushGroup(groupName)
  local currentGroup = self:getCurrentGroup()
  local newGroup = Group.new(groupName, currentGroup)

  if currentGroup then
    currentGroup:addSubgroup(newGroup)
  end

  table.insert(self.groupStack, newGroup)
end

--- Remove the topmost group from the stack.
--- @private
function Suite:popGroup()
  assert(table.remove(self.groupStack), "Group stack is empty")
end

return Suite