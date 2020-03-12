-- LÖVE lovecase demo script.

local lovecase = require "lovecase"

function love.load()
  local report = lovecase.runAllTestFiles("demo", true)
  print(report:toString())
end