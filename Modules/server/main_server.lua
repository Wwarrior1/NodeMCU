main = {}

print("ESP8266 Server")
wifi.setmode(wifi.STATIONAP);
wifi.ap.config({ ssid = "test", pwd = "12345678" });
print("Server IP Address:", wifi.ap.getip())

--led_1 = 5
--led_2 = 6
--led_3 = 7
--led_4 = 1
--gpio.mode(led_1, gpio.OUTPUT)
--gpio.mode(led_2, gpio.OUTPUT)
--gpio.mode(led_3, gpio.OUTPUT)
--gpio.mode(led_4, gpio.OUTPUT)

sv = net.createServer(net.TCP)
sv:listen(80, function(conn)
    conn:on("receive", function(conn, receivedData)
        print(receivedData)
        if (receivedData == "Button1") then
            -- gpio.write(led_1, gpio.HIGH)
            print("RCV: Button1")
        elseif (receivedData == "Button2") then
            -- gpio.write(led_2, gpio.HIGH)
            print("RCV: Button2")
        elseif (receivedData == "Button3") then
            -- gpio.write(led_3, gpio.HIGH)
            print("RCV: Button3")
        else
            -- gpio.write(led_4, gpio.HIGH)
            print("RCV: Button4")
        end
        --        tmr.alarm(4, 30, tmr.ALARM_SINGLE, function()
        --            gpio.write(led_1, gpio.LOW)
        --            gpio.write(led_2, gpio.LOW)
        --            gpio.write(led_3, gpio.LOW)
        --        end)
        collectgarbage()
    end)
    conn:on("sent", function(conn)
        collectgarbage()
    end)
end)

wifi_led_indicator = nil
package.loaded[main] = nil
