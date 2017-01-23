-- Your client implementation via callback functions
brokerIP = "192.168.0.14"
clientName = "Sonic"

start_time = tmr.now()
D = require("n5110d")
sonic = require("sonic_sensor")

D.setup(4, 3, 7, 5)
D.clear()
D.printString("Hello", 0, 0)

sonic_d = "/sonic/data"
sonic_r = "/sonic/request"
temp_d = "/temp/data"
temp_r = "/temp/request"

last_sonic = "-1"
measuring = false

tmr.alarm(tmr.create(), 2000, tmr.ALARM_AUTO, function() Client.publish(sonic_r, "please answer") end)

local function get_time()
    local result, _ = tostring((tmr.now() - start_time)):gsub(("(.*)(%d%d%d)(%d%d%d)"), "%1s %2ms")
    return result
end

local function cb_msg_rcv(topic, data)
    print("received message on topic \"" .. topic .. "\" data: \"" .. data .. "\"")
    if topic == sonic_r then
        if measuring then
            Client.publish(sonic_d, last_sonic)
        else
            measuring = true
            print("measuring")
            sonic.measureAverage(2, 1, 3, function(distance)
                measuring = false
                last_sonic = tostring(distance)
                print("Measured")
                print("Distance: " .. last_sonic)
                Client.publish(sonic_d, last_sonic)
                D.clearLine(2)
                D.printString(last_sonic:sub(0, 13), 0, 2)
            end)
        end
        D.printString("         ", 5, 1)
        D.printString(get_time():sub(0, 8), 5, 1)
        D.clearLine(2)
        D.printString(last_sonic:sub(0, 13), 0, 2)
    elseif topic == temp_r then
        D.printString("         ", 5, 3)
        D.printString(get_time():sub(0, 8), 5, 3)
        Client.publish(temp_d, "Temp data")
    end
end

local function cb_mqtt_conn()
    print("connected to mqtt broker")
    D.clearLine(5)
    D.printString(get_time():sub(0, 13), 0, 5)
    Client.subscribe(sonic_r)
    tmr.alarm(tmr.create(), 100, tmr.ALARM_SINGLE, function() Client.subscribe(temp_r) end)
end

local function cb_mqtt_conn_fail(reason)
    print("connect to broker failed: " .. reason)
    D.clearLine(0)
    D.printString(mqtt_fail_reasons(reason):sub(0, 13), 0, 0)
end

local function cb_publish_success(topic, data)
    print("published on topic \"" .. topic .. "\" data: \"" .. data .. "\"")
    D.clearLine(5)
    D.printString(get_time():sub(0, 13), 0, 5)
end

local function cb_subscribed(topic)
    print("subscribed to: " .. topic)
    if topic == sonic_r then
        D.clearLine(1)
        D.printString("son. ", 0, 1)
    elseif topic == temp_r then
        D.clearLine(3)
        D.printString("tem. ", 0, 3)
    end
end

local function cb_wifi_mode_changed(mode)
    print("wifi mode changed to: " .. mode)
    D.clearLine(0)
    D.printString(mode:sub(0, 13), 0, 0)
end

local function cb_ip_changed(ip)
    print("ip changed to: " .. ip)
    D.clearLine(0)
    D.printString(ip:sub(0, 13), 0, 0)
end

local function cb_mqtt_offline()
    print("mqtt offline")
end


-- Common API - leave it be ***

Client = {
    clientID = clientName,
    serverIP = brokerIP,
    mqtt_connected = false,
    qos = 2,
    user = "user",
    password = "",
    client = nil,
    connecting = false
}

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
