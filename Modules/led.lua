led = {};

local function gpio_pin_valid(pin)
    if pin < 0 or pin > 12 then
        return false
    end
    return true
end

function led.new(pin_gpio)
    package.loaded[led] = nil
    local new_obj = {}

    if not gpio_pin_valid(pin_gpio) then
        return nil
    end

    new_obj.pin = pin_gpio

    gpio.mode(new_obj.pin, gpio.OUTPUT)
    gpio.write(new_obj.pin, gpio.LOW)

    return new_obj
end

function led.turn_on(obj)
    package.loaded[led] = nil
    gpio.write(obj.pin, gpio.HIGH)
end

function led.turn_off(obj)
    package.loaded[led] = nil
    gpio.write(obj.pin, gpio.LOW)
end

return led
