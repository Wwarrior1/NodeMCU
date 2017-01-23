print("ESP8266 Client")
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
        cl = net.createConnection(net.TCP, 0)
        cl:connect(80, "192.168.4.1")

        -- Button 1,5,6 sends info to server
        gpio.mode(5, gpio.OUTPUT)

        tmr.alarm(5, 500, 1, function()
            cl:send("Button1")
        end)

    else
        print("Connecting...")
    end
end)

