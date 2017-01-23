-- Add following code into init.lua
-- ...

-- Append this inside run() in "RUN" section
function run()
    tmr.alarm(4, 600, tmr.ALARM_SINGLE, function()
        if file.exists("lcd_1.lc") then
            print("# > Starting: startLCD()")
            startLCD()
        else
            print("Module 'lcd_1' not exist.")
        end
    end)
end

-- Append this in "FUNCTIONS" section
function startLCD()
    i2c.setup(0, 3, 4, i2c.SLOW)
    require("lcd_1").begin("3", "4")
    require("lcd_1").setBacklight("1")
    require("lcd_1").print("-- Hello --", 2, 0)
    require("lcd_1").print("Heap " .. node.heap() .. "", 0, 1)

    tmr.alarm(1, 500, 1, function()
        require("lcd_1").print("      ", 5, 1)
        require("lcd_1").print("" .. node.heap() .. "", 5, 1)
    end)

    -- tmr.alarm(2, 200, tmr.ALARM_SINGLE, function () require("lcd_1").print("|", 14, 1); end)
    state = 0
    tmr.alarm(2, 250, 1, function()
        if state == 0 then
            require("lcd_1").print(".    ", 11, 1)
            state = 1
        elseif state == 1 then
            require("lcd_1").print(" .   ", 11, 1)
            state = 2
        elseif state == 2 then
            require("lcd_1").print("  .  ", 11, 1)
            state = 3
        elseif state == 3 then
            require("lcd_1").print("   . ", 11, 1)
            state = 4
        elseif state == 4 then
            require("lcd_1").print("    .", 11, 1)
            state = 5
        elseif state == 5 then
            require("lcd_1").print("   . ", 11, 1)
            state = 6
        elseif state == 6 then
            require("lcd_1").print("  .  ", 11, 1)
            state = 7
        elseif state == 7 then
            require("lcd_1").print(" .   ", 11, 1)
            state = 0
        end
    end)
end