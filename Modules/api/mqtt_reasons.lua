local Reasons = {}

function Reasons.get_mqtt_connect_fail_reason(c)
    if c == -5 then
        return "no broker"
    elseif c == -4 then
        return "bad resp."
    elseif c == -3 then
        return "dns fail"
    elseif c == -2 then
        return "ack tmout"
    elseif c == -1 then
        return "con tmout"
    elseif c == 0 then
        return "no error"
    elseif c == 1 then
        return "broker v."
    elseif c == 2 then
        return "cl id rej"
    elseif c == 3 then
        return "serv unav"
    elseif c == 4 then
        return "bad creds"
    elseif c == 5 then
        return "not auth"
    else
        return "Unkn. err"
    end
end

return Reasons
