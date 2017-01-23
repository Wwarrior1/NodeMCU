local Status = {}

function Status.get_mode_string(mode)
    if mode == wifi.STATION then
        return "Sta"
    elseif mode == wifi.SOFTAP then
        return "AP"
    elseif mode == wifi.STATIONAP then
        return "Sta & AP"
    elseif mode == wifi.NULLMODE then
        return "Off"
    else
        return "Unknown"
    end
end

return Status
