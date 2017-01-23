-- || ===== INIT ===== ||
-- Welcome info
print("#### Welcome :) ####")

--- COMPILATION
-- Commented as it's SUPPORTED BY 'UPLOAD' TOOL. Other solution is to uncomment below code.

--if file.exists("basic_compile.lc") or file.exists("basic_compile.lua") then
--    require("basic_compile").compile()
--    collectgarbage()
--else
--    print("(!) Module 'basic_compile' not exist.")
--end

-- Run MAIN files
--ls = file.list();
--ls_main = {}

tmr.alarm(tmr.create(), 1000, tmr.ALARM_SINGLE, function()
    if file.exists("main_mqtt_client_oled_1.lc") or file.exists("main_mqtt_client_oled_1.lua") then
        require("main_mqtt_client_oled_1")
        print("+ > Module 'main_mqtt_client_oled_1' loaded correctly.")
    end
    if file.exists("main_mqtt_client_oled_2.lc") or file.exists("main_mqtt_client_oled_2.lua") then
        require("main_mqtt_client_oled_2")
        print("+ > Module 'main_mqtt_client_oled_2' loaded correctly.")
    end
    if file.exists("main_mqtt_client_temp.lc") or file.exists("main_mqtt_client_temp.lua") then
        require("main_mqtt_client_temp")
        print("+ > Module 'main_mqtt_client_temp' loaded correctly.")
    end
end)

--tmr.alarm(tmr.create(), 100, tmr.ALARM_SINGLE, function()
--    if file.exists("main_mqtt_client_oled_old.lc") or file.exists("main_mqtt_client_oled_old.lua") then
--        require("main_mqtt_client_oled_old")
--        print("+ > Module 'main_mqtt_client_oled_old' loaded correctly.")
--    elseif file.exists("main_mqtt_client_temp.lc") or file.exists("main_mqtt_client_temp.lua") then
--        require("main_mqtt_client_temp")
--        print("+ > Module 'main_mqtt_client_temp' loaded correctly.")
--    end
--end)

--print("+ Modules to be loaded:")
--for name, _ in pairs(ls) do
--    if (string.match(name, '^main.*.lc$')) then
--        table.insert(ls_main, name)
--        print("  > " .. name)
--    end
--end
--
--table.sort(ls_main)
--
--for _, name in pairs(ls_main) do
--    if file.exists(name) then
--        print("+ Running module '" .. name:sub(1,-4) .. "' ...")
--        tmr.alarm(tmr.create(), 100, tmr.ALARM_SINGLE, function() dofile(name) end)
--        print("+ > Module '" .. name:sub(1,-4) .. "' loaded correctly.")
--    end
--end

-- Cleanup
--ls, ls_main = nil, nil
--collectgarbage()
