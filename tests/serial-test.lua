local lovecase = require("init")
local serial = require("serial")

local serialize = serial.serialize

return lovecase.newSuite("serial", function (suite)
  local expect = lovecase.expect

  suite:describe("serialize()", function ()
    suite:test("should serialize primitive values", function ()
      expect.equal(serialize(123), "123")
      expect.equal(serialize("abc"), '"abc"')
      expect.equal(serialize(true), "true")
      expect.equal(serialize(nil), "nil")
    end)
    suite:test("should pseudo-serialize functions", function ()
      local func = function () end
      expect.equal(serialize(func), tostring(func))
    end)
    suite:test("should serialize tables", function ()
      expect.equal(serialize({}), "{}")
      expect.equal(serialize({4,5,6}), "{4,5,6,}")
      expect.equal(serialize({1,"x",2}), '{1,"x",2,}')
      expect.equal(serialize({a = 123}), '{["a"]=123,}')
      expect.equal(serialize({1,2,{a = 3}}), '{1,2,{["a"]=3,},}')
    end)
    suite:test("should detect and prevent reference loops", function ()
      local a = { foo = {} }
      a.foo.bar = a
      expect.equal(serialize(a), string.format('{["foo"]={["bar"]="%s",},}', tostring(a)))
    end)
  end)
end)