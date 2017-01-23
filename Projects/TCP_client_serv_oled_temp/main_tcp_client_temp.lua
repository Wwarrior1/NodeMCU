sensor_temp = require("sensor_temp")
sensor_temp.getTemps(1) -- initialize loading temp to global variable "temps"

print("+ Client starting...")
wifi.sta.disconnect()
wifi.setmode(wifi.STATION)
wifi.sta.config("test", "12345678") -- connecting to server
wifi.sta.connect()
print("Looking for a connection")

tmr.alarm(3, 2000, 1, function()
    if (wifi.sta.getip() ~= nil) then
        tmr.stop(3)
        print("Connected!")
        print("Client IP Address:", wifi.sta.getip())
        local cl = net.createConnection(net.TCP, 0)
        cl:connect(80, "192.168.4.1")

        tmr.alarm(tmr.create(), 1000, tmr.ALARM_AUTO, function()
            local temp2send

            for _sensorID, temp in pairs(temps) do
                --temp2send = temp2send .. "#" .. _sensorID .. "#" .. temp -- TODO (now working with single DS18B20)
                print(">> " .. temp .. " C")
                temp2send = temp
            end

            print("+ sent temperature")
            cl:send("#temp#" .. temp2send)

            sensor_temp.getTemps(1) -- reinitialize variable "temps"
        end)

    else
        print("Connecting...")
    end
end)

