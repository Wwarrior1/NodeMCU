local M = {}

local tmr = tmr
local print = print
local math = math

local temp_d_A = "/temp_A/data"
local temp_r_A = "/temp_A/request"
local temp_d_B = "/temp_B/data"
local temp_r_B = "/temp_B/request"
local light_d = "/light/data"
local light_r = "/light/request"
local sonic_d = "/sonic/data"
local sonic_r = "/sonic/request"

local mqttclient_working = false
function M.start_mqttclient()
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
            -- print("received message on topic \"" .. topic .. "\" data: \"" .. data .. "\"")
            if topic == temp_d_A then
                -- print("Received /temp_d_A/ : " .. data)
                oled_data_temp_A_online = 1
                oled_data_temp_A = data
            elseif topic == temp_d_B then
                -- print("Received /temp_d_B/ : " .. data)
                oled_data_temp_B_online = 1
                oled_data_temp_B = data
            elseif topic == light_d then
                -- print("Received /light_d/ : " .. data)
                oled_data_light_online = 1
                oled_data_light = math.floor(data)
            elseif topic == sonic_d then
                -- print("Received /sonic_d/ : " .. data)
                oled_data_sonic_online = 1
                oled_data_sonic = math.floor(data)
            end
        end

        local function cb_mqtt_conn()
            print("connected to mqtt broker")
            led_rgb.change_to(brightness, "g", 20)
            oled_mqtt_status = "MQTT: OK"

            tmr.alarm(tmr.create(), 100, tmr.ALARM_SINGLE, function() Client.subscribe(temp_d_A) end)
            tmr.alarm(tmr.create(), 200, tmr.ALARM_SINGLE, function() Client.subscribe(temp_d_B) end)
            tmr.alarm(tmr.create(), 300, tmr.ALARM_SINGLE, function() Client.subscribe(light_d) end)
            tmr.alarm(tmr.create(), 400, tmr.ALARM_SINGLE, function() Client.subscribe(sonic_d) end)
        end

        local function cb_mqtt_conn_fail(reason)
            print("connect to broker failed: " .. reason)
            led_rgb.change_to(brightness, "r", 20)
        end

        local function cb_publish_success(topic, data)
            --            print("published on topic \"" .. topic .. "\" data: \"" .. data .. "\"")
        end

        local function cb_subscribed(topic)
            print("subscribed to: " .. topic)
            if topic == temp_d_A then
                tmr.alarm(tmr.create(), 1000, tmr.ALARM_AUTO, function()
                    oled_data_temp_A_online = 0
                    Client.publish(temp_r_A, "temp_r_A")
                end)
            elseif topic == temp_d_B then
                tmr.alarm(tmr.create(), 1000, tmr.ALARM_AUTO, function()
                    oled_data_temp_B_online = 0
                    Client.publish(temp_r_B, "temp_r_B")
                end)
            elseif topic == light_d then
                tmr.alarm(tmr.create(), 1000, tmr.ALARM_AUTO, function()
                    oled_data_light_online = 0
                    Client.publish(light_r, "light_r")
                end)
            elseif topic == sonic_d then
                tmr.alarm(tmr.create(), 1000, tmr.ALARM_AUTO, function()
                    oled_data_sonic_online = 0
                    Client.publish(sonic_r, "sonic_r")
                end)
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

return M