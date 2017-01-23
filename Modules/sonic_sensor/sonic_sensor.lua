local Sensor = {
    start = 0,
    last = 0,
    min = 200,
    callback = function(distance) end,
    trig = 2,
    echo = 1
}

function Sensor.init(trig, echo, callback)
    Sensor.trig = trig
    Sensor.echo = echo
    Sensor.callback = callback
    gpio.mode(trig, gpio.OUTPUT)
    gpio.write(trig, gpio.LOW)
    gpio.mode(echo, gpio.INT, gpio.PULLUP)
    gpio.trig(echo, "both",
        function(level)
            if level == gpio.HIGH then
                Sensor.start = tmr.now()
            else
                if Sensor.callback ~= nil then
                    local diff = tmr.now() - Sensor.start
                    local distance = diff / 57
                    Sensor.callback(distance)
                end
            end;
        end)
end

local function trigger()
    gpio.write(Sensor.trig, gpio.HIGH)
    tmr.delay(12)
    gpio.write(Sensor.trig, gpio.LOW)
    Sensor.last = tmr.now()
end

function Sensor.measureSingle()
    trigger()
end

function Sensor.measureAverage(count)
    local i, sum = 0, 0
    Sensor.callback = function(distance)
        local user_callback = Sensor.callback
        sum = sum + distance
        i = i + 1
        if i < count then
            local diff = tmr.now() - Sensor.last
            if diff < Sensor.min then
                tmr.alarm(tmr.create(), Sensor.min - diff, tmr.ALARM_SINGLE, function()
                    trigger(trig)
                end)
            else
                trigger(trig)
            end
        else
            Sensor.callback = user_callback
            user_callback(sum / count)
        end
    end
    tmr.alarm(tmr.create(), 10, tmr.ALARM_SINGLE, function()
        trigger()
    end)
end

return Sensor
