local font = {
    default = { 0x7F, 0x41, 0x41, 0x41, 0x7F },
    array = {
        0x00, 0x00, 0x00, 0x00, 0x00, -- space
        0x00, 0x00, 0x5F, 0x00, 0x00, -- !
        0x00, 0x07, 0x00, 0x07, 0x00, -- "
        0x14, 0x7F, 0x14, 0x7F, 0x14, -- #
        0x24, 0x2A, 0x7F, 0x2A, 0x12, -- $
        0x23, 0x13, 0x08, 0x64, 0x62, -- %
        0x36, 0x49, 0x55, 0x22, 0x50, -- &
        0x00, 0x05, 0x03, 0x00, 0x00, -- '
        0x00, 0x1C, 0x22, 0x41, 0x00, -- (
        0x00, 0x41, 0x22, 0x1C, 0x00, -- )
        0x08, 0x2A, 0x1C, 0x2A, 0x08, -- *
        0x08, 0x08, 0x3E, 0x08, 0x08, -- +
        0x00, 0x50, 0x30, 0x00, 0x00, -- ,
        0x08, 0x08, 0x08, 0x08, 0x08, -- -
        0x00, 0x60, 0x60, 0x00, 0x00, -- .
        0x20, 0x10, 0x08, 0x04, 0x02, -- /
        0x3E, 0x51, 0x49, 0x45, 0x3E, -- 0
        0x00, 0x42, 0x7F, 0x40, 0x00, -- 1
        0x42, 0x61, 0x51, 0x49, 0x46, -- 2
        0x21, 0x41, 0x45, 0x4B, 0x31, -- 3
        0x18, 0x14, 0x12, 0x7F, 0x10, -- 4
        0x27, 0x45, 0x45, 0x45, 0x39, -- 5
        0x3C, 0x4A, 0x49, 0x49, 0x30, -- 6
        0x01, 0x71, 0x09, 0x05, 0x03, -- 7
        0x36, 0x49, 0x49, 0x49, 0x36, -- 8
        0x06, 0x49, 0x49, 0x29, 0x1E, -- 9
        0x00, 0x36, 0x36, 0x00, 0x00, -- :
        0x00, 0x56, 0x36, 0x00, 0x00, -- ;
        0x00, 0x08, 0x14, 0x22, 0x41, -- <
        0x14, 0x14, 0x14, 0x14, 0x14, -- =
        0x41, 0x22, 0x14, 0x08, 0x00, -- >
        0x02, 0x01, 0x51, 0x09, 0x06, -- ?
        0x32, 0x49, 0x79, 0x41, 0x3E, -- @
        0x7E, 0x11, 0x11, 0x11, 0x7E, -- A
        0x7F, 0x49, 0x49, 0x49, 0x36, -- B
        0x3E, 0x41, 0x41, 0x41, 0x22, -- C
        0x7F, 0x41, 0x41, 0x22, 0x1C, -- D
        0x7F, 0x49, 0x49, 0x49, 0x41, -- E
        0x7F, 0x09, 0x09, 0x01, 0x01, -- F
        0x3E, 0x41, 0x41, 0x51, 0x32, -- G
        0x7F, 0x08, 0x08, 0x08, 0x7F, -- H
        0x00, 0x41, 0x7F, 0x41, 0x00, -- I
        0x20, 0x40, 0x41, 0x3F, 0x01, -- J
        0x7F, 0x08, 0x14, 0x22, 0x41, -- K
        0x7F, 0x40, 0x40, 0x40, 0x40, -- L
        0x7F, 0x02, 0x04, 0x02, 0x7F, -- M
        0x7F, 0x04, 0x08, 0x10, 0x7F, -- N
        0x3E, 0x41, 0x41, 0x41, 0x3E, -- O
        0x7F, 0x09, 0x09, 0x09, 0x06, -- P
        0x3E, 0x41, 0x51, 0x21, 0x5E, -- Q
        0x7F, 0x09, 0x19, 0x29, 0x46, -- R
        0x46, 0x49, 0x49, 0x49, 0x31, -- S
        0x01, 0x01, 0x7F, 0x01, 0x01, -- T
        0x3F, 0x40, 0x40, 0x40, 0x3F, -- U
        0x1F, 0x20, 0x40, 0x20, 0x1F, -- V
        0x7F, 0x20, 0x18, 0x20, 0x7F, -- W
        0x63, 0x14, 0x08, 0x14, 0x63, -- X
        0x03, 0x04, 0x78, 0x04, 0x03, -- Y
        0x61, 0x51, 0x49, 0x45, 0x43, -- Z
        0x00, 0x00, 0x7F, 0x41, 0x41, -- [
        0x02, 0x04, 0x08, 0x10, 0x20, -- \
        0x41, 0x41, 0x7F, 0x00, 0x00, -- ]
        0x04, 0x02, 0x01, 0x02, 0x04, -- ^
        0x40, 0x40, 0x40, 0x40, 0x40, -- _
        0x00, 0x01, 0x02, 0x04, 0x00, -- `
        0x20, 0x54, 0x54, 0x54, 0x78, -- a
        0x7F, 0x48, 0x44, 0x44, 0x38, -- b
        0x38, 0x44, 0x44, 0x44, 0x20, -- c
        0x38, 0x44, 0x44, 0x48, 0x7F, -- d
        0x38, 0x54, 0x54, 0x54, 0x18, -- e
        0x08, 0x7E, 0x09, 0x01, 0x02, -- f
        0x08, 0x14, 0x54, 0x54, 0x3C, -- g
        0x7F, 0x08, 0x04, 0x04, 0x78, -- h
        0x00, 0x44, 0x7D, 0x40, 0x00, -- i
        0x20, 0x40, 0x44, 0x3D, 0x00, -- j
        0x00, 0x7F, 0x10, 0x28, 0x44, -- k
        0x00, 0x41, 0x7F, 0x40, 0x00, -- l
        0x7C, 0x04, 0x18, 0x04, 0x78, -- m
        0x7C, 0x08, 0x04, 0x04, 0x78, -- n
        0x38, 0x44, 0x44, 0x44, 0x38, -- o
        0x7C, 0x14, 0x14, 0x14, 0x08, -- p
        0x08, 0x14, 0x14, 0x18, 0x7C, -- q
        0x7C, 0x08, 0x04, 0x04, 0x08, -- r
        0x48, 0x54, 0x54, 0x54, 0x20, -- s
        0x04, 0x3F, 0x44, 0x40, 0x20, -- t
        0x3C, 0x40, 0x40, 0x20, 0x7C, -- u
        0x1C, 0x20, 0x40, 0x20, 0x1C, -- v
        0x3C, 0x40, 0x30, 0x40, 0x3C, -- w
        0x44, 0x28, 0x10, 0x28, 0x44, -- x
        0x0C, 0x50, 0x50, 0x50, 0x3C, -- y
        0x44, 0x64, 0x54, 0x4C, 0x44, -- z
        0x00, 0x08, 0x36, 0x41, 0x00, -- {
        0x00, 0x00, 0x7F, 0x00, 0x00, -- |
        0x00, 0x41, 0x36, 0x08, 0x00, -- }
        0x10, 0x04, 0x08, 0x10, 0x08 -- ~
    }
}

function font.getCharacterVerticalBytes(character)
    local asciiCode = string.byte(character)
    if asciiCode < 32 or asciiCode > 126 then
        return font.default
    end
    local i = (asciiCode - string.byte(" ")) * 5 + 1
    local a = font.array
    return { a[i], a[i + 1], a[i + 2], a[i + 3], a[i + 4] }
end

local mode_data = 1
local mode_command = 0
local mode_uninitialized = -1
local ID_SPI = 1
local Display = { mode = mode_uninitialized }

local function sendCmd(cmd_byte)
    if Display.mode == mode_uninitialized then return end
    if Display.mode ~= mode_command then
        gpio.write(Display.dc_pin, gpio.LOW)
        Display.mode = mode_command
    end
    spi.send(ID_SPI, cmd_byte)
end

local function sendData(data_byte)
    if Display.mode == mode_uninitialized then return end
    if Display.mode ~= mode_data then
        gpio.write(Display.dc_pin, gpio.HIGH)
        Display.mode = mode_data
    end
    spi.send(ID_SPI, data_byte)
end

local function sendByteArray(bytes_arr)
    if Display.mode == mode_uninitialized then
        return
    end
    if Display.mode ~= mode_data then
        gpio.write(Display.dc_pin, gpio.HIGH)
        Display.mode = mode_data
    end
    for i = 1, table.getn(bytes_arr) do
        spi.send(ID_SPI, bytes_arr[i])
    end
end

local function setPosition(x, y)
    sendCmd(0x80 + x)
    sendCmd(0x40 + y)
end

function Display.clear()
    for _ = 1, 504, 1 do sendData(0x00) end
end

-- Display.printString(text [, x, y])
function Display.printString(text, ...)
    if table.getn(arg) == 2 then setPosition(arg[1] * 5, arg[2]) end
    for i = 1, string.len(text), 1 do
        sendByteArray(font.getCharacterVerticalBytes(text:sub(i, i)))
        sendData(0)
    end
end

function Display.clearLine(lineno)
    Display.printString("              ", 0, lineno)
end

function Display.setup(...)
    Display.reset_pin = arg[1]
    Display.dc_pin = arg[2]
    Display.mosi_pin = arg[3]
    Display.sclk_pin = arg[4]
    gpio.mode(Display.reset_pin, gpio.OUTPUT)
    gpio.mode(Display.dc_pin, gpio.OUTPUT)
    gpio.mode(Display.mosi_pin, gpio.OUTPUT)
    gpio.mode(Display.sclk_pin, gpio.OUTPUT)
    spi.setup(ID_SPI, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8, 20, spi.HALFDUPLEX)
    gpio.write(Display.reset_pin, gpio.LOW)
    gpio.write(Display.reset_pin, gpio.HIGH)
    gpio.write(Display.dc_pin, gpio.LOW)
    Display.mode = mode_command
    sendCmd(0x21)
    sendCmd(0xB8)
    sendCmd(0x04)
    sendCmd(0x14)
    sendCmd(0x20)
    sendCmd(0x0C)
end

return Display
