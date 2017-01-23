local Display = require("n5110d")
local debouncer = require("debouncer")
local sensor = require("sonic_sensor")

--print("Setup...")
Display.setup(4, 3, 8, 7, 5)
Display.clear()
--Display.printString("alala\0\n", 0, 0)
--print("Done")

--Display.printString("time:", 1, 2)
--tmr.alarm(1, 1000, tmr.ALARM_AUTO, function() Display.printString(""..tmr.now(), 1, 3) end)

Display.printString("Distance", 0, 0)
Display.printString("-", 0, 1)
debouncer.debounce(6, 50,
    function()
        print("press")
        local trig = 2
        local echo = 1
        sensor.measureAverage(trig, echo, 4, function(distance)
            Display.printString("            ", 0, 1)
            Display.printString("" .. (distance - distance % 1.0) .. " cm", 0, 1)
        end)
    end,
    function() end);