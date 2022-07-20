# Purgatory and Auto-Discord Invite | FiveM
[![Typing SVG](https://readme-typing-svg.herokuapp.com?font=Inconsolata&duration=3000&color=D404F7&vCenter=true&height=25&lines=Have+questions%3F;Feel+free+to+DM+me+on+Discord!)](https://git.io/typing-svg)

## Contact Information 
<a href="mailto:chevybot123@gmail.com"><img src="https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white"></a>
<a href="https://discordapp.com/users/359794704847601674"><img src="https://img.shields.io/badge/Discord-7289DA?style=for-the-badge&logo=discord&logoColor=white" alt="Kiyomi#9081" ></a>

## ❌ Description
Timeout-based system to punish players that are being disruptive in your server. [Includes auto-discord Invite]

## 🔨 Languages Used
![LUA](https://custom-icon-badges.herokuapp.com/badge/Lua-black.svg?logo=lua&logoColor=blue)
![LUA](https://custom-icon-badges.herokuapp.com/badge/HTML5-black.svg?logo=html5&logoColor=blue)
![LUA](https://custom-icon-badges.herokuapp.com/badge/Javascript-black.svg?logo=js&logoColor=blue)
![LUA](https://custom-icon-badges.herokuapp.com/badge/CSS-black.svg?logo=css3&logoColor=blue)


## ⚙️ Configuration
**Client**
```lua
_config = {}
_config.inviteDiscord = "https://discord.gg/XXXXX" -- Discord invite link
_config.ForceDiscordInvite = true -- If true, the player will be forced to show an invite on their discord client to the directed discord server
```
**Server**
```lua
sv_config = {}
sv_config.AllowedPermission = "FiveM.Admin" -- Permission required to use the command (/timeout [ID] [Seconds])
sv_config.AutoSendPurgatory = true -- If true, the player will be automatically sent to the purgatory server when being sent for rule violation.
sv_config.DiscordWebhook = ""
sv_config.PurgatoryPermissions = {
    DisableAllEntityCreation = true, -- Disables all entity creation.
    LogLeaves = true, -- When a player leaves the server, it will log the player's purgatory history.
}
```

## ❌ Requirments
- Discord Webhook
