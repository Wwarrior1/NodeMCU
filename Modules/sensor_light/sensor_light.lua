-- ***************************************************************************
-- BH1750 module for ESP8266 with nodeMCU
-- BH1750 compatible tested 2015-1-22
--
-- Written by xiaohu
--
-- MIT license, http://opensource.org/licenses/MIT
-- ***************************************************************************
local M = {}
local i2c = i2c

function M.init(sda, scl)
    i2c.setup(0, sda, scl, i2c.SLOW)
end

local function read_data(ADDR, commands, length)
    i2c.start(0)
    i2c.address(0, ADDR, i2c.TRANSMITTER)
    i2c.write(0, commands)
    i2c.stop(0)
    i2c.start(0)
    i2c.address(0, ADDR, i2c.RECEIVER)
    return i2c.read(0, length)
end

local function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function M.get_lux()
    local dataT = read_data(0x23, 0x10, 2) -- I2C slave address of GY-30 / CMD = 0x10
    local UT = dataT:byte(1) * 256 + dataT:byte(2) -- Make it more faster
    return round(UT * 1000 / 12 / 100, 2)
end

function M.get_percentage()
    return round(M.get_lux() / 65535 * 100, 2)
end

return M