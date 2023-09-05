-- LÖVE lovecase demo script.

local lovecase = require("lovecase")

function love.load()
  local report = lovecase.runAllTestFiles("tests", true)
  print(report:printResults())
end