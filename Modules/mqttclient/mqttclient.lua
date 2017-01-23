-- To set
local brokerIP = require("broker_ip").ip
local clientName = "Sonic"

-- do not touch
local Client = {
    clientID = clientName,
    serverIP = brokerIP,
    mqtt_connected = false,
    qos = 0,
    user = "user",
    password = "",
    client = nil,
    connecting = false
}

-- Your client implementation via callback functions


local function cb_msg_rcv(topic, data)
    print("received message on topic \"" .. topic .. "\" data: \"" .. data .. "\"")
end

local function cb_mqtt_conn()
    print("connected to mqtt broker")
end

local function cb_mqtt_conn_fail(reason)
    print("connect to broker failed: " .. reason)
end

local function cb_publish_success(topic, data)
    print("published on topic \"" .. topic .. "\" data: \"" .. data .. "\"")
end

local function cb_subscribed(topic)
    print("subscribed to: " .. topic)
end

local function cb_wifi_mode_changed(mode)
    print("wifi mode changed to: " .. mode)
end

local function cb_ip_changed(ip)
    print("ip changed to: " .. ip)
end

local function cb_mqtt_offline()
    print("mqtt offline")
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
    tmr.alarm(tmr.create(), 2000, tmr.ALARM_AUTO, function(timer)
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