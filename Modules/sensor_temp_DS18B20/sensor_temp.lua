-- | ===== MODULE ===== |
local M = {}
-- http://www.esp8266.com/viewtopic.php?f=19&t=752#p4189
-- http://www.esp8266.com/viewtopic.php?f=19&t=752&sid=3d3a891c01afc07dc1ef5095b4435bcb&start=16#p6821
-- Temperature sensor (model ds18b20)

temps = {} -- variable for storing temps. It's GLOBAL to be easily used by other modules

local function bxor(a, b)
    local r = 0
    for i = 0, 31 do
        if (a % 2 + b % 2 == 1) then
            r = r + 2 ^ i
        end
        a = a / 2
        b = b / 2
    end
    return r
end

function M.getTemps(pin)
    ow.setup(pin)

    if ow.reset(pin) == 1 then
        -- Select all devices on the owbus and start conversion on all devices
        -- power the bus during conversion
        ow.skip(pin)
        ow.write(pin, 0x44, 1) -- (1 for power)

        --        tmr.wdclr() -- ??? - keep the watchdog happy
        tmr.alarm(tmr.create(), 900, tmr.ALARM_SINGLE, -- wait min 750 ms (optimum = 1000 ms) for conversion to complete
            function()
                -- start searching ds18b20 (0x28) devices only (0x10 for ds18s20)
                ow.reset_search(pin)
                ow.target_search(pin, 0x28)

                -- search the first device
                local addr = ow.search(pin)

                -- and loop through all devices
                while addr do
                    --                    tmr.wdclr() -- ???
                    local crc = ow.crc8(string.sub(addr, 1, 7))

                    if (crc == addr:byte(8)) then
                        local sensor = ""
                        for j = 1, 8 do
                            sensor = sensor .. string.format("%02x", addr:byte(j))
                        end

                        -- READ TEMPERATURE
                        ow.reset(pin)
                        ow.select(pin, addr) -- select the found sensor
                        ow.write(pin, 0xBE, 0) -- READ_SCRATCHPAD (0 for nopower)

                        local data = string.char(ow.read(pin))
                        for i = 1, 8 do
                            data = data .. string.char(ow.read(pin))
                        end
                        crc = ow.crc8(string.sub(data, 1, 8))
                        if (crc == data:byte(9)) then

                            -- READ IN CORRECT WAY
                            local t = (data:byte(1) + data:byte(2) * 256)
                            if (t > 32768) then
                                t = (bxor(t, 0xffff)) + 1
                                t = (-1) * t
                            end
                            t = t * 625
                            if (addr:byte(1) == 0x10) then
                                -- we have DS18S20, the measurement must change
                                t = t * 8; -- compensating for the 9-bit resolution only
                                t = t - 2500 + ((10000 * (data:byte(8) - data:byte(7))) / data:byte(8))
                            end

                            -- CONVERT TO FLOAT
                            local tH = t / 10000
                            local tL = (t % 10000) / 10000
                            t = tH + tL
                            temps[sensor] = t
                            --print(sensor .. " : " .. t)
                        end

                        -- search next device
                        addr = ow.search(pin)
                    end
                end
                return temps
            end)
    else
        print("No device on the 1-Wire bus.")
        return temps
    end
end

-- | ===== MODULE ===== |
return M