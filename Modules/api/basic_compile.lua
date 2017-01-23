-- | ===== MODULE ===== |
local M = {}

function M.compile()
    local l = file.list()
    print("### Compile All Files ###")
    for k, _ in pairs(l) do
        if string.find(k, ".lua") then
            node.compile(k)
            print("+ compiled: " .. k)
            -- EXPERIMENTAL - remove .lua after compilation
            if not (string.find(k, "init.lua") or string.find(k, "basic_compile.lua") or string.find(k, "flashmod.lua")) then
                file.remove(k)
                print("+ (-) removed: " .. k)
            end
        end
    end
end

-- | ===== MODULE ===== |
return M
