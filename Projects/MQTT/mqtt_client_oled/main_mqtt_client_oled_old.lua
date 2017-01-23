local debouncer = require("debouncer")
local oled = require("SSD1306")
led_rgb = require("led_rgb")

local brightness = 10 -- 0-100 [%]
local contrast = 60 -- 0-100 [%]

local temp_d_A = "/temp_A/data"
local temp_r_A = "/temp_A/request"
local temp_d_B = "/temp_B/data"
local temp_r_B = "/temp_B/request"
local light_d_A = "/light_A/data"
local light_r_A = "/light_A/request"

local oled_ip_status = "WiFi: disconnected"
local oled_mqtt_status = "MQTT: disconnected"
local oled_data_temp_A = "..."
local oled_data_temp_B = "..."
local oled_data_light_A = "..."
--local oled_data_sonic = "..."

local function init()
    led_rgb.init(2, 3, 4, 500)
    led_rgb.change_to(brightness, "r", 20)

    --local fun_boot = { draw_boot }
    local fun_list = { draw_mqtt_temp, draw_mqtt_light }
    local fun_wifi = { draw_wifi }

    tmr.register(0, 1000, tmr.ALARM_AUTO, oled.start(fun_list))
    tmr.register(1, 200, tmr.ALARM_AUTO, oled.start(fun_wifi))
end

function draw_boot()
    disp:setColorIndex(1)
    disp:drawBox(0, 0, 128, 16)
    disp:setColorIndex(0)
    disp:drawStr(30, 4, "- WELCOME -")
    disp:setColorIndex(1)
end

function draw_mqtt_temp()
    disp:drawDisc(3, 8, 3)
    disp:drawCircle(12, 8, 3)
    disp:drawCircle(21, 8, 3)
    disp:drawStr(8 + 30, 4, "Temperature")

    --    if oled_data_temp_A == "..." then
    --        disp:drawStr(0, 18, "A) " .. oled_data_temp_A)
    --    else
    disp:drawStr(0, 18, "A) " .. oled_data_temp_A .. " C")
    --    end

    --    if oled_data_temp_B == "..." then
    --        disp:drawStr(0, 30, "B) " .. oled_data_temp_B)
    --    else
    disp:drawStr(0, 30, "B) " .. oled_data_temp_B .. " C")
    --    end
end

function draw_mqtt_light()
    local percent = ""
    if oled_data_light_A ~= "..." then percent = math.floor(oled_data_light_A / 65535 * 100) end
    disp:drawCircle(3, 8, 3)
    disp:drawDisc(12, 8, 3)
    disp:drawCircle(21, 8, 3)
    disp:drawStr(8 + 30, 4, "Light")
    disp:drawStr(0, 18, "A) " .. oled_data_light_A .. " lx - " .. percent .. " %")
end

--function draw_mqtt_sonic()
--    disp:drawCircle(3, 8, 3)
--    disp:drawCircle(12, 8, 3)
--    disp:drawDisc(21, 8, 3)
--    disp:drawStr(8 + 30, 4, "Sonar")
--    disp:drawStr(0, 18, "A) " .. oled_data_sonic)
--end

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

local mqttclient_working = false
function start_mqttclient()
    if not mqttclient_working then
        --- MQTT IMPLEMENTATION HERE ---

        -- To set
        local brokerIP = "192.168.43.224"
        local clientName = "Oled"

        -- Do not touch
        local Client = {
            clientID = clientName,
            serverIP = brokerIP,
            mqtt_connected = false,
            qos = 2,
            user = "user",
            password = "",
            client = nil,
            connecting = false
        }

        -- Client implementation via callback functions
        local function cb_msg_rcv(topic, data)
            print("received message on topic \"" .. topic .. "\" data: \"" .. data .. "\"")
            if topic == temp_d_A then
                print("Received /temp_d_A/ : " .. data)
                oled_data_temp_A = data
            elseif topic == temp_d_B then
                print("Received /temp_d_B/ : " .. data)
                oled_data_temp_B = data
            elseif topic == light_d_A then
                print("Received /light_d_A/ : " .. data)
                oled_data_light_A = math.floor(data)
            end
        end

        local function cb_mqtt_conn()
            print("connected to mqtt broker")
            led_rgb.change_to(brightness, "g", 20)
            oled_mqtt_status = "MQTT: OK"

            tmr.alarm(tmr.create(), 100, tmr.ALARM_SINGLE, function() Client.subscribe(temp_d_A) end)
            tmr.alarm(tmr.create(), 200, tmr.ALARM_SINGLE, function() Client.subscribe(temp_d_B) end)
            tmr.alarm(tmr.create(), 300, tmr.ALARM_SINGLE, function() Client.subscribe(light_d_A) end)
        end

        local function cb_mqtt_conn_fail(reason)
            print("connect to broker failed: " .. reason)
            led_rgb.change_to(brightness, "r", 20)
        end

        local function cb_publish_success(topic, data)
            print("published on topic \"" .. topic .. "\" data: \"" .. data .. "\"")
        end

        local function cb_subscribed(topic)
            print("subscribed to: " .. topic)
            if topic == temp_d_A then
                tmr.alarm(tmr.create(), 1000, tmr.ALARM_AUTO, function() Client.publish(temp_r_A, "temp_r_A") end)
            elseif topic == temp_d_B then
                tmr.alarm(tmr.create(), 1000, tmr.ALARM_AUTO, function() Client.publish(temp_r_B, "temp_r_B") end)
            elseif topic == light_d_A then
                tmr.alarm(tmr.create(), 1000, tmr.ALARM_AUTO, function() Client.publish(light_r_A, "light_r_A") end)
            end
        end

        local function cb_wifi_mode_changed(mode)
            print("wifi mode changed to: " .. mode)
        end

        local function cb_ip_changed(ip)
            print("ip changed to: " .. ip)
            oled_ip_status = "WiFi: " .. ip
        end

        local function cb_mqtt_offline()
            print("mqtt offline")
            led_rgb.change_to(brightness, "y", 20)
        end

        -- Common API - leave it be ***
        local function connect_mqtt(...)
            tmr.alarm(tmr.create(), 1000, tmr.ALARM_AUTO, function(timer)
                if not Client.connecting then
                    Client.connecting = true
                    Client.client:connect(Client.serverIP, 1883, 0, 1, function()
                        timer:unregister()
                        Client.mqtt_connected = true
                        cb_mqtt_conn()
                    end, function(_, reason)
                        Client.connecting = false
                        cb_mqtt_conn_fail(require("mqtt_reasons").get_mqtt_connect_fail_reason(reason))
                    end)
                end
            end)
        end

        function Client.publish(topic, data)
            if Client.mqtt_connected then
                Client.client:publish(topic, data, Client.qos, 0, function()
                    cb_publish_success(topic, data)
                end)
            end
        end

        function Client.subscribe(topic)
            tmr.alarm(tmr.create(), 500, tmr.ALARM_AUTO, function(timer)
                if Client.mqtt_connected then
                    timer:unregister()
                    Client.client:subscribe(topic, Client.qos, function()
                        cb_subscribed(topic)
                    end)
                end
            end)
        end

        function Client.start()
            Client.client = mqtt.Client(Client.ClientId, 120, Client.user, Client.password)
            Client.client:on("message", function(_, topic, data) cb_msg_rcv(topic, data) end)
            Client.client:on("offline", function()
                Client.mqtt_connected = false
                cb_mqtt_offline()
                connect_mqtt()
            end)

            local credentials = require("wifi_credentials")
            local ssid = credentials.ssid
            local password = credentials.password
            credentials = nil
            wifi.setmode(wifi.STATION)
            wifi.sta.disconnect()
            wifi.sta.config(ssid, password)
            wifi.sta.autoconnect(1)

            local last_mode = nil
            local last_ip = nil
            tmr.alarm(tmr.create(), 500, tmr.ALARM_AUTO, function(timer)
                local current_mode = wifi.getmode()
                if (current_mode ~= last_mode) then
                    last_mode = current_mode
                    cb_wifi_mode_changed(require("wifi_status").get_mode_string(current_mode))
                end
                if (wifi.sta.getip() ~= nil) then
                    local ip, _, _ = wifi.sta.getip()
                    if (ip ~= last_ip) then
                        last_ip = ip
                        if not Client.mqtt_connected and not Client.connecting then
                            connect_mqtt()
                        end
                        cb_ip_changed(ip)
                    end
                else
                    if last_ip ~= nil then cb_ip_changed("no ip") end
                    last_ip = nil
                end
            end)
        end

        Client.start()

        --- MQTT (END) ---
        mqttclient_working = true
    end
end

debouncer.debounce(1, 50, start_oled, start_mqttclient)
