-- | ===== MODULE ===== |
local M = {}

-- | ===== FUNCTIONS ===== |
function M.init_hw_spi(cs, dc, res, contrast)
    -- RES   - e.g. D0 (GPIO16) - can be assigned to any available GPIO
    -- D/C   - e.g. D3 (GPIO2)  - can be assigned to any available GPIO
    -- CS    - D8 (GPIO15/HCS) (or pull-down 10k to GND)
    -- CLK   - D5 (GPIO14/HSCLK)
    -- DIN   - D7 (GPIO13/D7/HMOSI)
    -- NC    - not used (D6/GPIO12/HMISO)
    -- VCC   - 3v3

    spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8, 0)
    disp = u8g.ssd1306_128x64_hw_spi(cs, dc, res)

    disp:setFont(u8g.font_6x10)
    disp:setFontRefHeightExtendedText()
    disp:setDefaultForegroundColor()
    disp:setFontPosTop()
    disp:setContrast(contrast * 255 / 100)

    return disp
end

-- Start the draw loop with the draw implementation in the provided funcion callback
local function update_display(fun)
    -- Draws one page and schedules the next page, if there is one
    local function draw_pages()
        fun()
        if (disp:nextPage() == true) then
            node.task.post(draw_pages)
        end
    end

    -- Restart the draw loop and start drawing pages
    disp:firstPage()
    node.task.post(draw_pages)
end

-- Start the draw loop
function M.start(fun_list)
    return function()
        local fun = table.remove(fun_list, 1)
        update_display(fun)
        table.insert(fun_list, fun)
    end
end

-- | ===== MODULE ===== |
return M
