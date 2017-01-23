print("ESP8266 Client")
wifi.sta.disconnect()
wifi.setmode(wifi.STATION)
wifi.sta.config("test", "12345678") -- connecting to server
wifi.sta.connect()
print("Looking for a connection")

debouncer = {};
function debouncer.init(pin_in, delay_ms)
    local self = {}

    self.pin = pin_in
    self.delay = delay_ms
    self.lasttime = tmr.now()
    self.tmr_value_per_ms = 1000

    function self.get_difference_ms(tmr_start, tmr_end)
        result = (tmr_end - tmr_start) / self.tmr_value_per_ms
        if (result < 0) then
            return 0
        end
        return result
    end

    function self.get_input()
        if (gpio.read(self.pin) == 0) then
            return 0
        end
        diff = self.get_difference_ms(self.lasttime, tmr.now())

        if (diff >= self.delay) then
            self.lasttime = tmr.now()
            return 1
        end
        return 0
    end

    return self
end

debouncer1 = debouncer.init(1, 200)
debouncer5 = debouncer.init(5, 200)
debouncer6 = debouncer.init(6, 200)

tmr.alarm(3, 2000, 1, function()
    if (wifi.sta.getip() ~= nil) then
        tmr.stop(3)
        print("Connected!")
        print("Client IP Address:", wifi.sta.getip())
        cl = net.createConnection(net.TCP, 0)
        cl:connect(80, "192.168.4.1")

        -- Button 1,5,6 sends info to server
        gpio.mode(2, gpio.OUTPUT)
        gpio.mode(1, gpio.INPUT, gpio.PULLUP)
        gpio.mode(5, gpio.INPUT, gpio.PULLUP)
        gpio.mode(6, gpio.INPUT, gpio.PULLUP)

        tmr.alarm(5, 50, 1, function()
            if debouncer1.get_input() == 0 then
                gpio.write(2, gpio.LOW)
            else
                gpio.write(2, gpio.HIGH)
                print(" + pressed_1")
                cl:send("Button1")
            end

            if debouncer5.get_input() == 0 then
                gpio.write(2, gpio.LOW)
            else
                gpio.write(2, gpio.HIGH)
                print(" + pressed_5")
                cl:send("Button2")
            end

            if debouncer6.get_input() == 0 then
                gpio.write(2, gpio.LOW)
            else
                gpio.write(2, gpio.HIGH)
                print(" + pressed_6")
                cl:send("Button3")
            end
        end)

    else
        print("Connecting...")
    end
end)

