local lovecase = require("lovecase")
local serial = require("lovecase.serial")

local test = lovecase.newTestSet("serial")

test:group("serialize()", function ()
  test:run("should serialize primitive values", function ()
    test:assertEqual(serial.serialize(123), "123")
    test:assertEqual(serial.serialize("abc"), '"abc"')
    test:assertEqual(serial.serialize(true), "true")
    test:assertEqual(serial.serialize(nil), "nil")
  end)
  test:run("should serialize tables", function ()
    test:assertEqual(serial.serialize({}), "{}")
    test:assertEqual(serial.serialize({4,5,6}), "{4,5,6,}")
    test:assertEqual(serial.serialize({1,"x",2}), '{1,"x",2,}')
    test:assertEqual(serial.serialize({a = 123}), '{["a"]=123,}')
    test:assertEqual(serial.serialize({1,2,{a = 3}}), '{1,2,{["a"]=3,},}')
  end)
  test:run("should detect and prevent reference loops", function ()
    local a = { foo = {} }
    a.foo.bar = a
    test:assertEqual(serial.serialize(a), string.format('{["foo"]={["bar"]="%s",},}', tostring(a)))
  end)
end)

return test