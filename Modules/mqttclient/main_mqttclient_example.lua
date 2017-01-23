local Client = require("mqttclient")

Client.config(function(wifi_status)
    print(wifi_status)
end,
    function(ip_status)
        print(ip_status)
    end,
    function(mqtt_status)
        print(mqtt_status)
    end,
    function(topic, data)
        print("rcv: " .. topic)
        print("data: " .. data)
    end,
    "My message",
    2,
    "clientAwesome",
    "192.168.43.224",
    "/mytopic",
    1000000,
    function()
        local topic = "/mytopic"
        Client.subscribe(topic)
        Client.publish(topic, "time " .. tmr.now())
    end)

Client.start()
