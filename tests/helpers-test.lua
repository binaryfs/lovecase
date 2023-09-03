local helpers = require("lovecase.helpers")
local lovecase = require("lovecase")

local test = lovecase.newTestSet("helpers")

test:group("compareTables()", function()
  test:run("should return true if the specified tables are equal", function(first, second)
    test:assertTrue(helpers.compareTables(first, second))
  end, {
    {{1, 2, 3}, {1, 2, 3}},
    {{}, {}},
    {{a = 1, b = 2}, {a = 1, b = 2}},
    {{a = 1, b = 2, c = 3}, {b = 2, c = 3, a = 1}},
    {{3; a = 1, b = 2}, {a = 1, b = 2; 3}}
  })
  test:run("should return false if the specified tables are not equal", function(first, second)
    test:assertFalse(helpers.compareTables(first, second))
  end, {
    {{1, 2, 3}, {1, 2}},
    {{1, 2, 3}, {1, 2, "3"}},
    {{a = 1, b = 2}, {a = 1, b = 22}},
    {{a = 1, b = 2, c = 3}, {a = 1, b = 2}},
    {{1, {}, 3}, {1, {}, 3}}
  })
end)

return test