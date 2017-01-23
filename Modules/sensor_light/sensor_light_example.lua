-- ***************************************************************************
-- BH1750 Example Program for ESP8266 with nodeMCU
-- BH1750 compatible tested 2015-1-30
--
-- Written by xiaohu
--
-- MIT license, http://opensource.org/licenses/MIT
-- ***************************************************************************
tmr.alarm(0, 1000, 1, function()
    local sensor_light = require("sensor_light")
    sensor_light.init(6, 5) -- sda pin, GPIO12 / scl pin, GPIO14
    local l = sensor_light.get_lux()
    print(l .. " lx")
    local l = sensor_light.get_percentage()
    print(l .. " %")
end)