-- LÖVE lovecase demo script.

local lovecase = require("init")

function love.load()
  local report = lovecase.runAllTestFiles("tests", true)
  print(report:printResults())
end

function love.draw()
  love.graphics.print("The lovecase results are output in the terminal.", 200, 300)
end