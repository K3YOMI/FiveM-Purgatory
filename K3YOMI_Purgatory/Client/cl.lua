

-- Also if you are a cheating reading this, you can change the config to your liking but the server uses this mostly. lol
_config = {}
_config.inviteDiscord = "https://discord.gg/" -- Discord invite link
_config.ForceDiscordInvite = false -- If true, the player will be forced to show an invite on their discord client to the directed discord server




-- Variables --
local isDead = false -- If the player is dead.
Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(0) -- Wait 0ms
        local _ped = PlayerPedId() -- Get the player's ped.
        local _state = IsEntityDead(_ped) -- Check if the player is dead.
        local _car = GetVehiclePedIsIn(_ped, false) -- Get the player's vehicle.
        if _state == (1) and isDead == (false) then 
            Citizen.Wait(500)
            TriggerServerEvent('Purgatory:Server:PlayerDeathRecordTime')
            isDead = true 
            local getPedKiller = GetPedSourceOfDeath(_ped)
            local getPedCauseOfDeath = GetPedCauseOfDeath(_ped)
            if getPedCauseOfDeath == -1553120962 and IsEntityAVehicle(getPedKiller) then 
                getKillerID = GetPlayerServerId(NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(getPedKiller, -1))) 
                TriggerServerEvent("Purgatory:Server:PlayerDeathRecorded", getKillerID, "VDM")
            else
                getKillerID = GetPlayerServerId(NetworkGetPlayerIndexFromPed(getPedKiller))
                TriggerServerEvent("Purgatory:Server:PlayerDeathRecorded", getKillerID, "RDM")
            end
        end
        if not IsEntityDead(_ped) then 
            isDead = false
        end
    end
end)



RegisterNetEvent('Purgatory:Client:DataReply')
AddEventHandler('Purgatory:Client:DataReply', function(__punishmentSecond, _reason, staffmember)
	SendNUIMessage({type = 'open',seconds = tonumber(__punishmentSecond),reason = _reason, staff = staffmember})
end)

RegisterNetEvent('Purgatory:Client:SendData')
AddEventHandler('Purgatory:Client:SendData', function()
	SendNUIMessage({type = 'close'})
end)

RegisterNUICallback('_CloseRules', function(data, cb)
	SendNUIMessage({type = 'close'})
end)
function _autoInvite()
    if _config.ForceDiscordInvite then
        local txd = CreateRuntimeTxd("duiTxd1")
        local duiObj = CreateDui(_config.inviteDiscord, 1024, 512)
        local dui = GetDuiHandle(duiObj)
        local tx = CreateRuntimeTextureFromDuiHandle(txd, "duiTex", dui)
        AddReplaceTexture("cs4_09_bilbrd_01", "bills_foreclosure_billboard_1024", "duiTxd1", "duiTex")
    end
end
_autoInvite()

