local Debouncer = {}

function Debouncer.debounce(pin, delay, onPressFunction, onReleaseFunction)
    local function debounce(state)
        return function(level)
            if level == gpio.HIGH then
                if not state.pressed then
                    state.pressed = true
                    onPressFunction()
                else
                    if state.timer ~= nil then
                        tmr.unregister(state.timer)
                        state.timer = nil
                    end
                end
            else
                local timer = tmr.create()
                state.timer = timer
                tmr.alarm(timer, state.delay / 1000, tmr.ALARM_SINGLE,
                    function(t)
                        state.pressed = false
                        onReleaseFunction()
                        t:unregister()
                    end)
            end;
        end
    end

    local state = {
        pressed = false,
        delay = delay * 1000,
        timer = nil
    }
    gpio.mode(pin, gpio.INT, gpio.PULLUP)
    gpio.trig(pin, 'both', debounce(state))
end

return Debouncer
