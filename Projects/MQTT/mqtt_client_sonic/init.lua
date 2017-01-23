tmr.alarm(tmr.create(), 500, tmr.ALARM_SINGLE, function()
    require("main_mqtt_client_sonic")
end)