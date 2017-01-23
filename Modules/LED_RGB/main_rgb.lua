if file.exists("debouncer.lc") then debouncer = require("debouncer")
else print("(!) Module 'debouncer' not exist.")
end
if file.exists("led_rgb.lc") then led_rgb = require("led_rgb")
else print("(!) Module 'led_rgb' not exist.")
end

-- LED Initialization
local r, g, b = 2, 3, 4
led_rgb.init(r, g, b, 500)

-- Functions
local function rgb_animate()
    local prev_r = pwm.getduty(r) / 1023 * 100
    local prev_g = pwm.getduty(g) / 1023 * 100
    local prev_b = pwm.getduty(b) / 1023 * 100

    led_rgb.change_to(10, "g", 500)
    led_rgb.change_to(10, "b", 1000)
    led_rgb.change_to(10, "r", 1500)
    led_rgb.change_to(10, "y", 2000)
    led_rgb.change_to(10, "g", 2500)
    led_rgb.change_to(10, "r", 3000)
    led_rgb.change_to(10, "b", 3500)
    led_rgb.change_to(10, "g", 4000)
    led_rgb.change_to(10, "y", 4500)
    led_rgb.change_to(10, "r", 5000)
    tmr.alarm(tmr.create(), 5500, tmr.ALARM_SINGLE, function() led_rgb.set_rgb(prev_r, prev_g, prev_b) end)
end

-- START
debouncer.debounce(12, 80, function() end, rgb_animate) -- 12 = SD3 = GPIO10 (https://nodemcu.readthedocs.io/en/master/en/modules/gpio/)