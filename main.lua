-- LÖVE lovecase demo script.

local lovecase = require("init")

function love.load()
  local report = lovecase.runAllTestFiles("tests", true)
  print(report:getResults())
  love.event.quit()
end