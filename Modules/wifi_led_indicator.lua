wifi_led_indicator = {}

-- 'static' method for wifi_led_indicator configuretion
-- pin_sta, pin_ap, pin_ip - pins for indicating wifi status:
-- wifi.STATION, wifi.AP, wifi.STATIONAP and if IP address is present
-- delay: refresh interval in ms
function wifi_led_indicator.new(pin_sta, pin_ap, pin_ip, delay, timer_id)
    package.loaded[wifi_led_indicator] = nil

    local led = require("led")

    if delay < 50 then
        delay = 50
    end

    local new_obj = {}

    new_obj.led_sta = led.new(pin_sta)
    new_obj.led_ap = led.new(pin_ap)
    new_obj.led_ip = led.new(pin_ip)
    new_obj.delay = delay
    new_obj.tmr_id = timer_id

    return new_obj
end

function wifi_led_indicator.stop(obj)
    package.loaded[wifi_led_indicator] = nil

    tmr.unregister(obj.tmr_id)
    local led = require("led")

    led.turn_off(obj.led_sta)
    led.turn_off(obj.led_ap)
    led.turn_off(obj.led_ip)
end

function wifi_led_indicator.start(obj)
    package.loaded[wifi_led_indicator] = nil
    local led_ip = obj.led_ip
    local led_sta = obj.led_sta
    local led_ap = obj.led_ap
    local delay = obj.delay

    if (led_ip == nil and led_sta == nil and led_ap == nil) or delay < 1 then
        return
    end

    tmr.alarm(obj.tmr_id, delay, tmr.ALARM_AUTO, function()
        local led = require("led")

        local mode = wifi.getmode()
        if mode == wifi.STATION then
            led.turn_on(led_sta)
            led.turn_off(led_ap)
            if (wifi.sta.getip() ~= nil) then
                led.turn_on(led_ip)
            else
                led.turn_off(led_ip)
            end
        elseif mode == wifi.SOFTAP then
            led.turn_on(led_ap)
            led.turn_off(led_sta)
            if (wifi.ap.getip() ~= nil) then
                led.turn_on(led_ip)
            else
                led.turn_off(led_ip)
            end
        elseif mode == wifi.STATIONAP then
            led.turn_on(led_ap)
            led.turn_on(led_sta)
            if (wifi.ap.getip() ~= nil or wifi.sta.getip() ~= nil) then
                led.turn_on(led_ip)
            else
                led.turn_off(led_ip)
            end
        else
            led.turn_off(led_ap)
            led.turn_off(led_sta)
            led.turn_off(led_ip)
        end
    end)
end

return wifi_led_indicator
