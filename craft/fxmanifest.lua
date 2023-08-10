



fx_version 'adamant'

game 'gta5'

author 'rege'
description 'CRAFTING'

ui_page_preload "yes"

ui_page 'web/ui.html'

files {
	'web/*.*',
	'web/icons/*.png'
}

shared_script 'config.lua'

client_scripts {
	"@vrp/client/Tunnel.lua",
	"@vrp/client/Proxy.lua",
	'client.lua'
}

server_scripts {
	"@vrp/lib/utils.lua",
	'server.lua'
}