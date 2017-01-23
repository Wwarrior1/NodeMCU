local debouncer = require("debouncer")
local oled = require("SSD1306")
led_rgb = require("led_rgb")

local tmr = tmr
local print = print
local disp = disp
local math = math

brightness = 10 -- 0-100 [%]
local contrast = 60 -- 0-100 [%]

oled_ip_status = "WiFi: disconnected"
oled_mqtt_status = "MQTT: disconnected"
oled_data_temp_A = "..."
oled_data_temp_B = "..."
oled_data_light = "..."
oled_data_sonic = "..."

local function init()
    led_rgb.init(2, 3, 4, 500)
    led_rgb.change_to(brightness, "r", 20)

    --local fun_boot = { draw_boot }
    local fun_list = { draw_mqtt_node_A, draw_mqtt_node_B }
    local fun_wifi = { draw_wifi }

    tmr.register(0, 3000, tmr.ALARM_AUTO, oled.start(fun_list))
    tmr.register(1, 200, tmr.ALARM_AUTO, oled.start(fun_wifi))

    oled_data_temp_A_online = 0
    oled_data_temp_B_online = 0
    oled_data_light_online = 0
    oled_data_sonic_online = 0

    tmr.alarm(tmr.create(), 3000, tmr.ALARM_AUTO, function()
        if oled_data_temp_A_online == 0 then oled_data_temp_A = "..." end
        if oled_data_temp_B_online == 0 then oled_data_temp_B = "..." end
        if oled_data_light_online == 0 then oled_data_light = "..." end
        if oled_data_sonic_online == 0 then oled_data_sonic = "..." end
    end)
end

function draw_boot()
    disp:setColorIndex(1)
    disp:drawBox(0, 0, 128, 16)
    disp:setColorIndex(0)
    disp:drawStr(30, 4, "- WELCOME -")
    disp:setColorIndex(1)
end

function draw_mqtt_node_A()
    disp:drawDisc(3, 8, 3)
    disp:drawCircle(12, 8, 3)
    disp:drawStr(8 + 20, 4, "Node A")

    if oled_data_temp_A == "..." then
        disp:drawStr(0, 18, "Temp  | ...")
    else
        disp:drawStr(0, 18, "Temp  | " .. oled_data_temp_A .. " C")
    end

    if oled_data_light == "..." then
        disp:drawStr(0, 30, "Light | ...")
    else
        local percent = math.floor(oled_data_light / 65535 * 100)
        disp:drawStr(0, 30, "Light | " .. oled_data_light .. " lx " .. percent .. " %")
    end
end

function draw_mqtt_node_B()
    disp:drawCircle(3, 8, 3)
    disp:drawDisc(12, 8, 3)
    disp:drawStr(8 + 20, 4, "Node B")

    if oled_data_temp_B == "..." then
        disp:drawStr(0, 18, "Temp  | ...")
    else
        disp:drawStr(0, 18, "Temp  | " .. oled_data_temp_B .. " C")
    end

    if oled_data_sonic == "..." then
        disp:drawStr(0, 30, "Sonic | ...")
    else
        disp:drawStr(0, 30, "Sonic | " .. oled_data_sonic .. " cm")
    end
end

function draw_wifi()
    disp:drawStr(32, 4, "Wifi status")
    disp:drawStr(0, 18, oled_ip_status)
    disp:drawStr(0, 30, oled_mqtt_status)
    disp:drawStr(0, 42, "Heap: " .. node.heap())
end

function start_oled()
    if (tmr.state(0) == nil) then
        init()
        disp = oled.init_hw_spi(8, 6, 9, contrast) -- CS, D/C, RES
        --        disp:setFont(u8g.font_chikita)
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

            led_rgb.blink(brightness, "b", 20)
        else
            if not tmr.stop(1) then print("timer 1 not stopped, not registered?") end
            if not tmr.start(0) then print("timer 0 not started") end

            led_rgb.blink(brightness, "b", 20)
        end
    end
end

function start_mqttclient()
    require("main_mqtt_client_oled_2").start_mqttclient()
end

debouncer.debounce(1, 50, start_oled, start_mqttclient)
