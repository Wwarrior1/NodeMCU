-- show files
function file_list()
    l = file.list();
    print("-- Files: --")
    for k,v in pairs(l) do
        print(""..k.." \t"..v.." \tB \t("..(v/1024).." \tKB)")
    end
end

-- get file system info
function file_fsinfo()
    remaining, used, total = file.fsinfo()
    print("-- File system info: --")
    print(" Total : "..total.." \tB \t("..(total/(1024)).." \tKB)")
    print(" Used  : "..used.." \tB \t("..(used/(1024)).." \tKB)")
    print(" Remain: "..remaining.." \tB \t("..(remaining/(1024)).." \tKB)")
end

-- show heap size
function node_heap()
    heap = node.heap()
    print("-- Heap size: --")
    print(" "..heap.." B \t("..(heap/1024).." \tKB)")
end

-- show info about nodeMCU
function node_info()
    majorVer, minorVer, devVer, chipID, flashID, flashSize, flashMode, flashSpeed = node.info()
    print("-- Node basic info: --")
    print(" Version : "..majorVer.."."..minorVer.."."..devVer)
    print(" Chip ID : "..chipID)
    print(" Flash ID: "..flashID)
    print(" Flash size : "..flashMode)
    print(" Flash speed: "..(flashSpeed/1000/1000).." MHz")
end

function info()
    node_info()
    node_heap()
    file_fsinfo()
    file_list()
end

info()