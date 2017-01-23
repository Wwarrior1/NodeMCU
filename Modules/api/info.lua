-- | ===== MODULE ===== |
local M = {}
local module = ...
function M.init()
    package.loaded[module] = nil
end

-- | ===== FUNCTIONS ===== |
function M.help()
    print("  globals()  -- Show global variables")
    print("  memory()   -- Show flash memory size")
    print("  heap()     -- Heap size")
    print("  about()    -- Info about NodeMCU")
    print("  print_basic() -- Execute upper functions")
    print("  print_wifi()  -- All info about WiFi")
end

-- Show files
function M.ll()
    l = file.list()
    l_lua, l_lc, l_other = {}, {}, {}
    l_items, l_lua_items, l_lc_items, l_other_items = 0, 0, 0, 0

    print("-- Files: --")
    for name, _ in pairs(l) do
        if (string.find(name, ".lua")) then
            table.insert(l_lua, name)
            l_lua_items = l_lua_items + 1
        elseif (string.find(name, ".lc")) then
            table.insert(l_lc, name)
        else
            table.insert(l_other, name)
            l_other_items = l_other_items + 1
        end
        l_items = l_items + 1
    end

    table.sort(l_lua)
    table.sort(l_lc)
    table.sort(l_other)

    for _, name_lua in pairs(l_lua) do
        found = 0
        for _, name_lc in pairs(l_lc) do
            if (name_lc:sub(1, -3) == name_lua:sub(1, -4)) then
                print("  " .. l[name_lua] .. " \t" .. name_lua .. "    \t" .. l[name_lc] .. " \t" .. name_lc)
                l[name_lc] = nil
                l_lc[name_lc] = nil
                found = 1
                break
            end
        end

        if (found == 0) then
            print("  ", l[name], name)
        end
        found = nil
    end
    print("  + Total: " .. l_lua_items)

    for _, name in pairs(l_lc) do
        if (l[name] ~= nil) then
            print("  " .. l[name] .. " \t" .. name)
            l_lc_items = l_lc_items + 1
        end
    end
    print("  + Total: " .. l_lc_items)

    for _, name in pairs(l_other) do
        print("  " .. l[name] .. " \t" .. name)
    end
    print("  + Total: " .. l_other_items .. ")")
    print("  Total all files: " .. "(" .. l_items .. ")")

    -- Cleanup
    l, l_lua, l_lc, l_other = nil, nil, nil, nil
    l_items, l_lua_items, l_lc_items, l_other_items = nil, nil, nil, nil
    collectgarbage()
end

function M.globals()
    print("-- Globals: --")
    for k, v in pairs(_G) do
        print("  k=" .. tostring(k) .. " v=" .. tostring(v))
    end

    -- Cleanup
    collectgarbage()
end

-- Get file system info
function M.memory()
    remaining, used, total = file.fsinfo()
    print("-- File system info: --")
    print("  Total : " .. total .. " \tB \t(" .. (total / (1024)) .. " \tKB)")
    print("  Used  : " .. used .. " \tB \t(" .. (used / (1024)) .. " \tKB)")
    print("  Remain: " .. remaining .. " \tB \t(" .. (remaining / (1024)) .. " \tKB)")

    -- Cleanup
    remaining, used, total = nil, nil, nil
    collectgarbage()
end

-- Show heap size
function M.heap()
    heap = node.heap()
    print("-- Heap size: --")
    print("  " .. heap .. " B \t(" .. (heap / 1024) .. " \tKB)")

    -- Cleanup
    heap = nil
    collectgarbage()
end

-- Show info about nodeMCU
function M.about()
    majorVer, minorVer, devVer, chipID, flashID, flashSize, flashMode, flashSpeed = node.info()
    print("-- Node basic info: --")
    print("  Version : " .. majorVer .. "." .. minorVer .. "." .. devVer)
    print("  Chip ID : " .. chipID)
    print("  Flash ID: " .. flashID)
    print("  Flash size : " .. flashMode)
    print("  Flash speed: " .. (flashSpeed / 1000 / 1000) .. " MHz")

    -- Cleanup
    majorVer, minorVer, devVer, chipID, flashID, flashSize, flashMode, flashSpeed = nil, nil, nil, nil, nil, nil, nil, nil
    collectgarbage()
end

-- Print all basic information about NodeMCU
function M.print_basic()
    M.about()
    M.heap()
    M.globals()
    M.memory()
    M.ls()
end

-- print current WiFi properties
function M.print_wifi()
    print("-- WiFi info: --")
    print("  WiFi channel -------------------------- : ", wifi.getchannel())
    print("  WiFi operation mode ------------------- : ", require("wifi_status").get_mode_string(wifi.getmode()))
    print("  WiFi physical mode -------------------- : ", wifi.getphymode())
    print("  WiFi station configuration ------------ : ", wifi.sta.getconfig())
    print("  RSSI(Received Signal Strength) -------- : ", wifi.sta.getrssi())
    print("  Current station hostname -------------- : ", wifi.sta.gethostname())
    print("  Broadcast address ----------- | Station : ", wifi.sta.getbroadcast())
    print("  MAC address ----------------- | Station : ", wifi.sta.getmac())
    print("  IP, netmask and gateway ----- | Station : ", wifi.sta.getip())
    print("  Current status -------------- | Station : ", wifi.sta.status())
    print("  Broadcast address ---------------- | AP : ", wifi.ap.getbroadcast())
    print("  MAC address ---------------------- | AP : ", wifi.ap.getmac())
    print("  IP address, netmask and gateway -- | AP : ", wifi.ap.getip())
    collectgarbage()
end

-- | ===== MODULE ===== |
return M
