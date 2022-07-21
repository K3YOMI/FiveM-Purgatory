sv_config = {}
sv_config.AllowedPermission = "FiveM.Admin" -- Permission required to use the command (/timeout [ID] [Seconds])
sv_config.AutoSendPurgatory = true -- If true, the player will be automatically sent to the purgatory server when being sent for rule violation.
sv_config.DiscordWebhook = ""
sv_config.PurgatoryPermissions = {
    DisableAllEntityCreation = true, -- Disables all entity creation.
    LogLeaves = true, -- When a player leaves the server, it will log the player's purgatory history.
}




_PurgatoryPlayers = {} -- Stores the players who have been sent to the purgatory server.
function _isAcePermissionsAllowed(source) -- Returns true if the player is allowed to use the permission system.
    if IsPlayerAceAllowed(source, sv_config['AllowedPermission']) then
        return true
    end
    return false
end
function _disableEntity()
   if sv_config.PurgatoryPermissions.DisableAllEntityCreation == true then
        SetRoutingBucketEntityLockdownMode(666, 'strict')
    else
        SetRoutingBucketEntityLockdownMode(666, 'inactive')
    end
end
function _logLeave(reason) -- Logs the player's purgatory history when they leave the server.
    if sv_config.PurgatoryPermissions.LogLeaves == true then
        local _data = getPlayerData(source)
        if _data ~= "NULL" then
        local _Format = {Staff_Member = _data['Staff Member'],Player_Sent = _data['Target'],Violation_Reason = _data['Reason'],Total_Time = _data['TotalTime'],Time_Remaining = _data['Time'],Leave_Reason = reason,}
        _discordLog("[LEFT-DURING-TIMEOUT]", '```'.._convertTables(json.encode((_Format)))..'```')
    end end
end
function _discordLog(title, description) -- Logs the message to the Discord webhook.
    local _embedStyle = {{["color"] = 16777215,["title"] = title,["description"] = description,["footer"] = {  ["text"] = "Logged : " ..os.date("%Y-%m-%d %H:%M:%S"),},}}
    PerformHttpRequest(sv_config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = "Auto-Purgatory by K3YOMI@Github", embeds = _embedStyle}), { ['Content-Type'] = 'application/json' })
end
function getPlayerData(id) -- Returns the player's data.
    for k,v in pairs(_PurgatoryPlayers) do
        if v.ID == id then
            return v
        end
    end
    return "NULL"
end
function _convertTables(_data) -- Converts the tables to a string. [Easier to read]
    local string = string.gsub(_data, ",","\n")
    local string2 = string
    local string3 = string.gsub(string2, '{',"")
    local string4 = string.gsub(string3, '}',"")
    local string5 = string.gsub(string4, ':'," : ")
    return string5
end
Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1 * 1000)
        local players = GetPlayers()
        for k,v in pairs(_PurgatoryPlayers) do
            if v['Time'] then
                if v['Time'] > 0 and GetPlayerName(v['ID']) then
                    v['Time'] = v['Time'] - 1
                elseif v['Time'] == 0 and GetPlayerName(v['ID']) then
                    SetPlayerRoutingBucket(tonumber(v['ID']), 0)
                    local _Name = GetPlayerName(v['ID']) .. " [ " .. v['ID'] .. " ]" 
                    local _Format = {Staff_Member = v['Staff Member'],Player_Sent = v['Target'],Violation_Reason = v['Reason'],Total_Time = v['TotalTime'],Time_Remaining = v['Time'],}
                    _discordLog("[FINISHED]", '```'.._convertTables(json.encode((_Format)))..'```')
                    _PurgatoryPlayers[k] = nil
                else
                    _PurgatoryPlayers[k] = nil
                end
            end
        end
    end
end)

_disableEntity()
AddEventHandler("playerDropped", _logLeave) -- Logs the player's leave.
RegisterCommand('timeout-remove', function(source, args, raw)
    if _isAcePermissionsAllowed(source) then
        _target = tonumber(args[1])
        _reason = table.concat(args, ' ', 2)
        if GetPlayerPing(_target) > 1 then
            _TargetString = GetPlayerName(_target) .. " [ " .. _target .. " ]"
            _StaffString = GetPlayerName(source) .. " [ " .. source .. " ]"
            TriggerClientEvent('_ForceRemovePunishment', _target)
            if sv_config.AutoSendPurgatory == true then 
                SetPlayerRoutingBucket(_target, 0)
            end
            local _data = {['ID'] = _target,['Staff Member'] = _StaffString,['Target'] = _TargetString,['Reason'] = _reason,}
            local _Format = {Staff_Member = _data['Staff Member'],Player_Sent = _data['Target'],Violation_Reason = _data['Reason'],}
            _discordLog("[FORCE REMOVED]", '```'.._convertTables(json.encode((_Format)))..'```')
            for k,v in pairs(_PurgatoryPlayers) do
                if v.ID == _target then
                    _PurgatoryPlayers[k] = nil
                end
            end
        end 
    end
end)


RegisterCommand('timeout', function(source, args, raw)
    if _isAcePermissionsAllowed(source) then
        _target = tonumber(args[1])
        _time = tonumber(args[2])
        _reason = table.concat(args, ' ', 3)
        if GetPlayerPing(_target) > 1 and GetPlayerRoutingBucket(_target) ~= 666 then
            _TargetString = GetPlayerName(_target) .. " [ " .. _target .. " ]"
            _StaffString = GetPlayerName(source) .. " [ " .. source .. " ]"
            if _time and _time < 999999 then 
                if _reason ~= "" then 
                    TriggerClientEvent('_ForcePunishment', _target, _time, _reason, _StaffString)
                    if sv_config.AutoSendPurgatory == true then 
                        SetPlayerRoutingBucket(_target, 666)
                    end
                    local _data = {['ID'] = _target,['Staff Member'] = _StaffString,['Target'] = _TargetString,['Time'] = _time,['TotalTime'] = _time,['Reason'] = _reason,}
                    local _Format = {Staff_Member = _data['Staff Member'],Player_Sent = _data['Target'],Violation_Reason = _data['Reason'],Total_Time = _data['TotalTime'],Time_Remaining = _data['Time'],}
                    _discordLog("[SENT]", '```'.._convertTables(json.encode((_Format)))..'```')
                    table.insert(_PurgatoryPlayers, _data)
                else 
                    TriggerClientEvent('_ForcePunishment', _target, _time, "No Reason Given", _StaffString)
                    if sv_config.AutoSendPurgatory == true then 
                        SetPlayerRoutingBucket(_target, 666)
                    end
                    local _data = {['ID'] = _target,['Staff Member'] = _StaffString,['Target'] = _TargetString,['Time'] = _time,['TotalTime'] = _time,['Reason'] = _reason,}
                    local _Format = {Staff_Member = _data['Staff Member'],Player_Sent = _data['Target'],Violation_Reason = _data['Reason'],Total_Time = _data['TotalTime'],Time_Remaining = _data['Time'],}
                    _discordLog("[SENT]", '```'.._convertTables(json.encode((_Format)))..'```')
                    table.insert(_PurgatoryPlayers, _data)
                end
            end
        end
    end 
end)


