_config = {}
_config.inviteDiscord = "https://discord.gg/XXXXX" -- Discord invite link
_config.ForceDiscordInvite = true -- If true, the player will be forced to show an invite on their discord client to the directed discord server



RegisterNetEvent('_ForcePunishment')
AddEventHandler('_ForcePunishment', function(__punishmentSecond, _reason, staffmember)
	SendNUIMessage({type = 'open',seconds = tonumber(__punishmentSecond),reason = _reason, staff = staffmember})
end)

RegisterNetEvent('_ForceRemovePunishment')
AddEventHandler('_ForceRemovePunishment', function()
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

