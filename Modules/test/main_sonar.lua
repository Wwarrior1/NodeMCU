debouncer = require("debouncer")
sensor = require("sonic_sensor")

led1 = 2
gpio.mode(led1, gpio.OUTPUT)
gpio.write(led1, gpio.HIGH)
debouncer.debounce(1, 50,
    function()
        gpio.write(led1, gpio.HIGH)
        local trig = 6
        local echo = 5
        sensor.measureAverage(trig, echo, 10, function(distance) print(distance) end)
    end,
    function() gpio.write(led1, gpio.LOW) end);



