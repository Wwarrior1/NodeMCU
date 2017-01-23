sensor_temp = require("sensor_temp")

sensor_temp.getTemps(1)

tmr.alarm(tmr.create(), 1000, tmr.ALARM_AUTO, function()
    sensor_temp.getTemps(1)

    for _sensorID, temp in pairs(temps) do
        print(">> " .. temp .. " C")
    end
end)