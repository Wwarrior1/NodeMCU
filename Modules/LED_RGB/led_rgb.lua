-- | ===== MODULE ===== |
local M = {}

local actual_mode
local PIN_R, PIN_G, PIN_B

-- | ===== FUNCTIONS ===== |
function M.init(r, g, b, freq)
    -- r,g,b: nr of pins
    -- freq:  1-1000 [Hz]
    actual_mode = ""
    PIN_R, PIN_G, PIN_B = r, g, b
    pwm.setup(PIN_R, freq, 0)
    pwm.setup(PIN_G, freq, 0)
    pwm.setup(PIN_B, freq, 0)
    pwm.start(PIN_R)
    pwm.start(PIN_G)
    pwm.start(PIN_B)
end

function M.blink(duty, mode, time)
    local prev_mode = actual_mode
    M.change_to(duty, mode, time)
    M.change_to(duty, prev_mode, time + 500)
end

function M.set_rgb(r_duty, g_duty, b_duty)
    -- r_duty, g_duty, b_duty: 0-100 [%] (mapped to value 0-1023) (brightness)
    pwm.setduty(PIN_R, r_duty * 1023 / 100)
    pwm.setduty(PIN_G, g_duty * 1023 / 100)
    pwm.setduty(PIN_B, b_duty * 1023 / 100)
end

function M.change_to(duty, mode, time)
    -- duty: 0-100 [%] (brightness)
    -- mode: r2g (from Red to Green), g2r, r2b, b2r, ...
    -- TAKES ~1800 Bytes of RAM

    tmr.alarm(tmr.create(), time, tmr.ALARM_SINGLE, function()
        collectgarbage()
        --        print(">> Before >> " .. node.heap())

        local n = 10
        for i = 1, n do
            -- TIME = 300ms = 168+10*(10+sqrt(10))
            tmr.alarm(tmr.create(), 168 + 10 * (i + math.sqrt(i)), tmr.ALARM_SINGLE,
                function()
                    local factor = n / 10 * duty / 10 -- n/10 to scale unit to be 10 as a basic duty
                    local from = (n - i) * factor
                    local to = i * factor

                    if actual_mode == "r" then
                        if mode == "g" then led_rgb.set_rgb(from, to, 0) -- from, to, 0
                        elseif mode == "b" then led_rgb.set_rgb(from, 0, to) -- from, 0, to
                        elseif mode == "y" then led_rgb.set_rgb(n * factor, to / 4, 0) -- ..., to/4, 0
                        end
                    elseif actual_mode == "g" then
                        if mode == "r" then led_rgb.set_rgb(to, from, 0) -- to, from, 0
                        elseif mode == "b" then led_rgb.set_rgb(0, from, to) -- 0, from, to
                        elseif mode == "y" then led_rgb.set_rgb(to, (n - i * 3 / 4) * factor, 0) -- to, ..., 0
                        end
                    elseif actual_mode == "b" then
                        if mode == "r" then led_rgb.set_rgb(to, 0, from) -- to, 0, from
                        elseif mode == "g" then led_rgb.set_rgb(0, to, from) -- 0, to, from
                        end
                    elseif actual_mode == "y" then
                        if mode == "r" then led_rgb.set_rgb(n * factor, from / 4, 0) -- ..., from/4, 0
                        elseif mode == "g" then led_rgb.set_rgb(from, n / 4 + (i * 3 / 4) * factor, 0) -- from, ..., 0
                        end
                    elseif actual_mode == "" then
                        if mode == "r" then led_rgb.set_rgb(to, 0, 0) -- to, 0, 0
                        elseif mode == "g" then led_rgb.set_rgb(0, to, 0) -- 0, to, 0
                        elseif mode == "b" then led_rgb.set_rgb(0, 0, to) -- 0, 0, to
                        elseif mode == "w" then led_rgb.set_rgb(to, to, to) -- to, to, to
                        end
                    end
                end)
        end

        tmr.alarm(tmr.create(), 310, tmr.ALARM_SINGLE, function()
            actual_mode = mode:sub(mode:len(), mode:len() + 1)
        end)

        collectgarbage()
        --        print(">> After >> " .. node.heap())
    end)
end

-- | ===== MODULE ===== |
return M
