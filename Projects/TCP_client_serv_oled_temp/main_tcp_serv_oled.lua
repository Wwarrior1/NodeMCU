if file.exists("debouncer.lc") then debouncer = require("debouncer")
else print("(!) Module 'debouncer' not exist.")
end
if file.exists("SSD1306.lc") then oled = require("SSD1306")
else print("(!) Module 'SSD1306' not exist.")
end
if file.exists("led_rgb.lc") then led_rgb = require("led_rgb")
else print("(!) Module 'led_rgb' not exist.")
end

local brightness = 20 -- 0-100 [%]
local contrast = 60 -- 0-100 [%]

local function init()
    led_rgb.init(2, 3, 4, 500)
    led_rgb.change_to(brightness, "r", 100)

    --local fun_boot = { draw_boot }
    local fun_list = { draw_HelloWorld, draw_sensor_temp, draw_heap }
    local fun_wifi = { draw_wifi, draw_clear }

    tmr.register(0, 2000, tmr.ALARM_AUTO, function() oled.start(fun_list) end)
    print("1111")

    tmr.register(1, 500, tmr.ALARM_AUTO, function() oled.start(fun_wifi) end)
    print("2222")
end

function draw_HelloWorld()
    disp:drawStr(30, 22, "Hello World")
    disp:drawDisc(5, 6, 3)
    disp:drawCircle(14, 6, 3)
    disp:drawCircle(23, 6, 3)
end

function draw_sensor_temp()
    disp:drawStr(10, 22, "-- Temp sensor --")
    disp:drawCircle(5, 6, 3)
    disp:drawDisc(14, 6, 3)
    disp:drawCircle(23, 6, 3)

    if (temp) then disp:drawStr(40, 32, temp .. " C")
    else disp:drawStr(30, 32, "waiting ...")
    end
end

function draw_heap()
    disp:drawStr(30, 22, "Heap: " .. node.heap())
    disp:drawCircle(5, 6, 3)
    disp:drawCircle(14, 6, 3)
    disp:drawDisc(23, 6, 3)
end

function draw_clear()
    disp:setColorIndex(0)
    disp:drawBox(0, 0, 128, 64)
    disp:setColorIndex(1)
end

function draw_boot()
    disp:setColorIndex(1)
    disp:drawBox(0, 0, 128, 16)
    disp:setColorIndex(0)
    disp:drawStr(30, 4, "- WELCOME -")
    disp:setColorIndex(1)
end

function draw_wifi()
    disp:drawStr(25, 32, "Wifi info ...")
end


function start_oled()
    if (tmr.state(0) == nil) then
        init()
        disp = function() oled.init_hw_spi(8, 6, 0, contrast) end -- CS, D/C, RES
        tmr.alarm(tmr.create(), 30, tmr.ALARM_SINGLE, function() oled.start({ draw_boot }) end)

        tmr.alarm(tmr.create(), 1000, tmr.ALARM_SINGLE, function()
            led_rgb.change_to(brightness, "y", 20)
            if not tmr.start(0) then print("timer 0 not started") end
            print(">>> OLED starting")
            led_rgb.change_to(brightness, "g", 1900)
            print(">>> OLED started")
        end)
    else
        local running, _ = tmr.state(0)
        if (running == true) then
            if not tmr.stop(0) then print("timer 0 not stopped, not registered?") end
            if not tmr.start(1) then print("timer 1 not started") end

            led_rgb.change_to(brightness, "r", 20)
        else
            if not tmr.stop(1) then print("timer 1 not stopped, not registered?") end
            if not tmr.start(0) then print("timer 0 not started") end

            led_rgb.change_to(brightness, "g", 20)
        end
    end
end

server_working = false
temp = nil
function start_server()
    if not server_working then
        print("+ Server starting...")
        wifi.setmode(wifi.STATIONAP);
        wifi.ap.config({ ssid = "test", pwd = "12345678" });
        print("Server IP Address:", wifi.ap.getip())

        local sv = net.createServer(net.TCP)
        sv:listen(80, function(conn)
            conn:on("receive", function(conn, receivedData)
                if (string.find(receivedData, "#temp#")) then
                    print("+ Received: temp")
                    print(receivedData)
                    temp = receivedData:sub(7)
                else
                    print("Received unexpected data !")
                end
                collectgarbage()
            end)
            conn:on("sent", function(conn)
                collectgarbage()
            end)
        end)
        server_working = true
    end
end

debouncer.debounce(1, 50, start_server, start_oled)
