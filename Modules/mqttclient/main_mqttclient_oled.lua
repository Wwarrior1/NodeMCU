if file.exists("debouncer.lc") then debouncer = require("debouncer")
else print("(!) Module 'debouncer' not exist.")
end
if file.exists("SSD1306.lc") then oled = require("SSD1306")
else print("(!) Module 'SSD1306' not exist.")
end
if file.exists("led_rgb.lc") then led_rgb = require("led_rgb")
else print("(!) Module 'led_rgb' not exist.")
end
if file.exists("mqttclient.lc") then mqttclient = require("mqttclient")
else print("(!) Module 'mqttclient' not exist.")
end

local brightness = 20 -- 0-100 [%]
local contrast = 60 -- 0-100 [%]
ip_status_ = ""
mqtt_status_ = ""
topic_ = ""
data_ = ""

local function init()
    led_rgb.init(2, 3, 4, 500)
    led_rgb.change_to(brightness, "r", 100)

    --local fun_boot = { draw_boot }
    local fun_list = { draw_mqtt }
    local fun_wifi = { draw_wifi }

    tmr.register(0, 200, tmr.ALARM_AUTO, oled.start(fun_list))
    tmr.register(1, 200, tmr.ALARM_AUTO, oled.start(fun_wifi))
end

function draw_boot()
    disp:setColorIndex(1)
    disp:drawBox(0, 0, 128, 16)
    disp:setColorIndex(0)
    disp:drawStr(30, 4, "- WELCOME -")
    disp:setColorIndex(1)
end

function draw_mqtt()
    disp:drawStr(28, 4, "MQTT Client")
    disp:drawStr(0, 18, topic_)
    disp:drawStr(0, 30, data_)
end

function draw_wifi()
    disp:drawStr(28, 4, "Wifi status")
    disp:drawStr(0, 18, ip_status_)
    disp:drawStr(0, 30, mqtt_status_)
    disp:drawStr(0, 42, node.heap())
end

function start_oled()
    if (tmr.state(0) == nil) then
        init()
        disp = oled.init_hw_spi(8, 6, 0, contrast) -- CS, D/C, RES
        tmr.alarm(tmr.create(), 30, tmr.ALARM_SINGLE, oled.start({ draw_boot }))

        tmr.alarm(tmr.create(), 1500, tmr.ALARM_SINGLE, function()
            led_rgb.change_to(brightness, "y", 20)
            if not tmr.start(0) then print("timer 0 not started") end
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

mqttclient_working = false
function start_mqttclient()
    if not mqttclient_working then

        local function callback(type, ...)
        end

        mqttclient.config(2,
            "ClientNokia",
            "192.168.43.224",
            1000000,
            callback)

        mqttclient.start()



        --        mqttclient.config(function(wifi_status) print(wifi_status) end,
        --            function(ip_status)
        --                ip_status_ = ip_status
        --                print(" >> ip_status : " .. ip_status)
        --            end,
        --            function(mqtt_status)
        --                mqtt_status_ = mqtt_status
        --                print(" >> mqtt_status : " .. mqtt_status)
        --                if (mqtt_status == "Connected") then
        --                    led_rgb.change_to(brightness, "g", 20)
        --                end
        --            end,
        --            function(topic, data)
        --                topic_ = topic
        --                data_ = data
        --                print("rcv: " .. topic)
        --                print("data: " .. data)
        --                tmr.alarm(tmr.create(), 100, tmr.ALARM_SINGLE, function()
        --                    led_rgb.change_to(brightness, "b", 80)
        --                end)
        --                tmr.alarm(tmr.create(), 650, tmr.ALARM_SINGLE, function()
        --                    led_rgb.change_to(brightness, "g", 20)
        --                end)
        --            end,
        --            "My message",
        --            2,
        --            "Myoled :)",
        --            "192.168.43.224",
        --            "/mytopic",
        --            1000000)

        mqttclient_working = true
    end
end

debouncer.debounce(1, 50, start_oled, start_mqttclient)