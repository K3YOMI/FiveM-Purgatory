sv_config = {}
sv_config.AllowedPermission = "FiveM.Admin" -- Permission required to use the command (/timeout [ID] [Seconds])
sv_config.AutoSendPurgatory = true -- If true, the player will be automatically sent to the purgatory server when being sent for rule violation.
sv_config.DiscordWebhook = ""
sv_config.AntiRD_AND_VDM = true -- If true, the anti rdm/vdm system will automatically enable per server/resource restart.
sv_config.TotalAmount = 1 -- The amount of times a player can kill before being sent to purgatory.
sv_config.PurgatoryPermissions = {
    DisableAllEntityCreation = true, -- Disables all entity creation.
    LogLeaves = true, -- When a player leaves the server, it will log the player's purgatory history.
}


LAST_TIME_KILLED_TABLE = {}
KILLERS_TOTAL_KILLS = {}
_PurgatoryPlayers = {} -- Stores the players who have been sent to the purgatory server.
function _isAcePermissionsAllowed(source) -- Returns true if the player is allowed to use the permission system.
    if source == 0 or IsPlayerAceAllowed(source, sv_config['AllowedPermission']) then
        return true
    end
    return true
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
        end
    end
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
        Citizen.Wait(60 * 1000)
        KILLERS_TOTAL_KILLS = {}
    end
end)

Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(1 * 1000)
        local players = GetPlayers()
        for k,v in pairs(_PurgatoryPlayers) do
            if v['Time'] then
                if v['Time'] > 0 and GetPlayerName(v['ID']) then
                    v['Time'] = v['Time'] - 1
                elseif v['Time'] == 0 and GetPlayerName(v['ID']) then
                    _hasVehicle = GetVehiclePedIsIn(GetPlayerPed(v['ID']), false)
                    if _hasVehicle == 0 then 
                        SetPlayerRoutingBucket(tonumber(v['ID']), 0)
                    else 
                        SetPlayerRoutingBucket(tonumber(v['ID']), 0)
                        SetEntityRoutingBucket(_hasVehicle, 0)
                    end

                    local _Name = GetPlayerName(v['ID']) .. " [ " .. v['ID'] .. " ]" 
                    local _Format = {Staff_Member = v['Staff Member'],Player_Sent = v['Target'],Violation_Reason = v['Reason'],Total_Time = v['TotalTime'],Time_Remaining = v['Time'],}
                    _discordLog("[FINISHED]", '```'.._convertTables(json.encode((_Format)))..'```')
                    _PurgatoryPlayers[k] = nil
                    KILLERS_TOTAL_KILLS[k] = nil
                else
                    _PurgatoryPlayers[k] = nil
                    KILLERS_TOTAL_KILLS[k] = nil
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
        _hasVehicle = GetVehiclePedIsIn(GetPlayerPed(_target), false)
        if GetPlayerPing(_target) > 1 then
            _TargetString = GetPlayerName(_target) .. " [ " .. _target .. " ]"
            _StaffString = GetPlayerName(source) .. " [ " .. source .. " ]"
            TriggerClientEvent('Purgatory:Client:SendData', _target)
            if sv_config.AutoSendPurgatory == true then 
                if _hasVehicle == 0 then 
                    SetPlayerRoutingBucket(_target, 0)
                else 
                    SetPlayerRoutingBucket(_target, 0)
                    SetEntityRoutingBucket(_hasVehicle, 0)
                end
            end
            local _data = {['ID'] = _target,['Staff Member'] = _StaffString,['Target'] = _TargetString,['Reason'] = _reason,}
            local _Format = {Staff_Member = _data['Staff Member'],Player_Sent = _data['Target'],Violation_Reason = _data['Reason'],}
            _discordLog("[FORCE REMOVED]", '```'.._convertTables(json.encode((_Format)))..'```')
            for k,v in pairs(_PurgatoryPlayers) do
                if v.ID == _target then
                    _PurgatoryPlayers[k] = nil
                    KILLERS_TOTAL_KILLS[k] = nil
                end
            end
        end 
    end
end)

RegisterCommand("toggle_auto", function(source, args, raw)
    if _isAcePermissionsAllowed(source) then
        if sv_config.AntiRD_AND_VDM == true then
            sv_config.AntiRD_AND_VDM = false
            TriggerClientEvent('chat:addMessage', -1, {args = {"^1[Auto-Purgatory] ^0Anti-RDM & VDM has been ^1disabled^0."}})
        else
            sv_config.AntiRD_AND_VDM = true
            TriggerClientEvent('chat:addMessage', -1, {args = {"^1[Auto-Purgatory] ^0Anti-RDM & VDM has been ^2enabled^0."}})
        end
    end
end)


RegisterCommand('timeout', function(source, args, raw)
    if _isAcePermissionsAllowed(source) then
        _target = tonumber(args[1])
        _time = tonumber(args[2])
        _reason = table.concat(args, ' ', 3)
        _hasVehicle = GetVehiclePedIsIn(GetPlayerPed(_target), false)
        if GetPlayerPing(_target) > 1 and GetPlayerRoutingBucket(_target) ~= 666 then
            _TargetString = GetPlayerName(_target) .. " [ " .. _target .. " ]"
            _StaffString = GetPlayerName(source) .. " [ " .. source .. " ]"
            if _time and _time < 999999 then 
                if _reason ~= "" then 
                    TriggerClientEvent('Purgatory:Client:DataReply', _target, _time, _reason, _StaffString)
                    if sv_config.AutoSendPurgatory == true then 
                        if _hasVehicle == 0 then 
                            SetPlayerRoutingBucket(_target, 666)
                        else 
                            SetPlayerRoutingBucket(_target, 666)
                            SetEntityRoutingBucket(_hasVehicle, 666)
                        end
                    end
                    local _data = {['ID'] = _target,['Staff Member'] = _StaffString,['Target'] = _TargetString,['Time'] = _time,['TotalTime'] = _time,['Reason'] = _reason,}
                    local _Format = {Staff_Member = _data['Staff Member'],Player_Sent = _data['Target'],Violation_Reason = _data['Reason'],Total_Time = _data['TotalTime'],Time_Remaining = _data['Time'],}
                    _discordLog("[SENT]", '```'.._convertTables(json.encode((_Format)))..'```')
                    table.insert(_PurgatoryPlayers, _data)
                else 
                    TriggerClientEvent('Purgatory:Client:DataReply', _target, _time, "No Reason Given", _StaffString)
                    if sv_config.AutoSendPurgatory == true then 
                        if _hasVehicle == 0 then 
                            SetPlayerRoutingBucket(_target, 666)
                        else 
                            SetPlayerRoutingBucket(_target, 666)
                            SetEntityRoutingBucket(_hasVehicle, 666)
                        end
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



function timeoutAuto(target, time, reason)
    local _target = target
    local _time = time
    local _reason = reason
    _hasVehicle = GetVehiclePedIsIn(GetPlayerPed(_target), false)
    if GetPlayerPing(_target) > 1 and GetPlayerRoutingBucket(_target) ~= 666 then
        _TargetString = GetPlayerName(_target) .. " [ " .. _target .. " ]"
        _StaffString = "SERVER [ 0 ]"
        if _time and _time < 999999 then 
            if _reason ~= "" then 
                TriggerClientEvent('Purgatory:Client:DataReply', _target, _time, _reason, _StaffString)
                if sv_config.AutoSendPurgatory == true then 
                    if _hasVehicle == 0 then 
                        SetPlayerRoutingBucket(_target, 666)
                    else 
                        SetPlayerRoutingBucket(_target, 666)
                        SetEntityRoutingBucket(_hasVehicle, 666)
                    end
                end
                local _data = {['ID'] = _target,['Staff Member'] = _StaffString,['Target'] = _TargetString,['Time'] = _time,['TotalTime'] = _time,['Reason'] = _reason,}
                local _Format = {Staff_Member = "SERVER [AUTO]",Player_Sent = _data['Target'],Violation_Reason = _data['Reason'],Total_Time = _data['TotalTime'],Time_Remaining = _data['Time'],}
                _discordLog("[SERVER SENT]", '```'.._convertTables(json.encode((_Format)))..'```')
                table.insert(_PurgatoryPlayers, _data)
            else 
                TriggerClientEvent('Purgatory:Client:DataReply', _target, _time, "No Reason Given", _StaffString)
                if sv_config.AutoSendPurgatory == true then 
                    if _hasVehicle == 0 then 
                        SetPlayerRoutingBucket(_target, 666)
                    else 
                        SetPlayerRoutingBucket(_target, 666)
                        SetEntityRoutingBucket(_hasVehicle, 666)
                    end
                end
                local _data = {['ID'] = _target,['Staff Member'] = _StaffString,['Target'] = _TargetString,['Time'] = _time,['TotalTime'] = _time,['Reason'] = _reason,}
                local _Format = {Staff_Member = "SERVER [AUTO]",Player_Sent = _data['Target'],Violation_Reason = _data['Reason'],Total_Time = _data['TotalTime'],Time_Remaining = _data['Time'],}
                _discordLog("[SERVER SENT]", '```'.._convertTables(json.encode((_Format)))..'```')
                table.insert(_PurgatoryPlayers, _data)
            end
        end
    end
end


function validateDeath(killerDiscovered, victimDiscovered, deathSequence)
    local distanceCheck = false 
    local idCheck = false
    local isKilled = false
    local victimKillerCoords = GetEntityCoords(GetPlayerPed(killerDiscovered))
    local victimCoords = GetEntityCoords(GetPlayerPed(victimDiscovered))
    local distanceTotal = #((victimKillerCoords) - (victimCoords))
    if distanceTotal < 425.0 then 
        distanceCheck = true
    end 
    if GetPlayerName(killerDiscovered) ~= nil then 
        idCheck = true
    end
    if LAST_TIME_KILLED_TABLE[victimDiscovered] ~= nil then 
        calcTime = LAST_TIME_KILLED_TABLE[victimDiscovered]['Time'] - os.time()
        if calcTime < 5 then 
            isKilled = true
        end 
        if LAST_TIME_KILLED_TABLE[victimDiscovered] == nil then 
            isKilled = true
        end
    end
    if distanceCheck == true and idCheck == true and isKilled == true then 
        return true
    else 
        timeoutAuto(victimDiscovered, 120000, "Spoofing Detected // You lil stink...")
        return false
    end
end
RegisterNetEvent('Purgatory:Server:PlayerDeathRecordTime')
AddEventHandler('Purgatory:Server:PlayerDeathRecordTime', function(killedBy, data)
    if sv_config.AntiRD_AND_VDM == true and GetEntityHealth(GetPlayerPed(source)) == 0 then
        LAST_TIME_KILLED_TABLE[source] = {Time = os.time()}
    end
end)



RegisterNetEvent("Purgatory:Server:PlayerDeathRecorded")
AddEventHandler("Purgatory:Server:PlayerDeathRecorded", function(killerID, causeOfDeath)
    if sv_config.AntiRD_AND_VDM == true then
        local victimIDInt = tonumber(source)
        local killerIDInt = tonumber(killerID)
        local causeOfDeath = causeOfDeath
        if killerIDInt == 0 or killerIDInt == victimIDInt then 
            return "Player died by suicide."
        else
            local isWhitelisted = _isAcePermissionsAllowed(killerIDInt)
            local validateDeath = validateDeath(killerIDInt, victimIDInt, causeOfDeath)
            if isWhitelisted == true and validateDeath == true then 
                checkAttackerTable = KILLERS_TOTAL_KILLS[killerIDInt]
                if checkAttackerTable ~= nil then 
                    checkAttackerTable['totalKills'] = checkAttackerTable['totalKills'] + 1
                    if checkAttackerTable['totalKills'] >= sv_config.TotalAmount then 
                        timeoutAuto(killerIDInt, 120, causeOfDeath)
                        KILLERS_TOTAL_KILLS[killerIDInt] = nil
                    end
                else
                    KILLERS_TOTAL_KILLS[killerIDInt] = {totalKills = 1}
                    checkAttackerTable = KILLERS_TOTAL_KILLS[killerIDInt]
                    if checkAttackerTable ~= nil then 
                        if checkAttackerTable['totalKills'] >= sv_config.TotalAmount then 
                            timeoutAuto(killerIDInt, 120, causeOfDeath)
                            KILLERS_TOTAL_KILLS[killerIDInt] = nil
                        end
                    end
                end
            end
        end
    end
end)
