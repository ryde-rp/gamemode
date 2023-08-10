




fx_version 'cerulean'
game 'gta5'

ui_page_preload "yes"

lua54 'on'

ui_page 'client/ui/index.html'
files {
	'client/ui/index.html',
	'client/ui/js/**/*.js',
	'client/ui/css/**/*.css',
	'client/ui/img/**/*.png',
	'client/ui/sounds/**/*.ogg',
	'client/ui/fonts/FugazOne.ttf'
}

client_scripts {
	'@vrp/client/Proxy.lua',
	'@vrp/client/Tunnel.lua',
	'config/core.lua',
	'config/prices.lua',
	
	'client/menus.lua',
	'client/labels.lua',
	'client/helper.lua',
	'client/core.lua'
}

server_scripts {
	'@vrp/lib/utils.lua',
	'config/core.lua',
	'server/core.lua'
}



-- client_script '@vrp/client/allResources.lua'