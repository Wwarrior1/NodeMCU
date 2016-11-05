-- +---------------------+
-- |   USEFUL COMMANDS   |
-- +---------------------+
--   file.remove("init.lua")
--   node.compile("basic.lua")
---  require("basic") == dofile("basic.lc")
--   package.loaded['filename']=nil | only with require()
--   collectgarbage()

function startup()
    if file.open("init.lua") == nil then
        print("### init.lua deleted or renamed ###")
    else
        print("### Working ###")
        file.close("init.lua")
    end
end

function initCompile()
    l = file.list();
    print("### Compiling")
    for k, v in pairs(l) do
        if string.find(k, ".lua") then
            node.compile(k)
            print("# > Compiled: "..k)
        end
    end
end

startup()
initCompile()

-- Type in console:
--   require("basic")