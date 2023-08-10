fx_version 'cerulean'
game 'gta5'

description 'Fairplay Phone'
version '1.0.0'

ui_page_preload "yes"

ui_page 'html/index.html'

shared_scripts {
	'config.lua'
}

client_scripts {
	'@vrp/client/Tunnel.lua',
	'@vrp/client/Proxy.lua',    
	'client/main.lua',
	'client/animation.lua'
}

server_scripts {
	'@vrp/lib/utils.lua',
	'server/main.lua'
}

files {
	'html/*.html',
	'html/js/*.js',
	'html/img/*.png',
	'html/css/*.css',
	'html/fonts/*.ttf',
	'html/fonts/*.otf',
	'html/fonts/*.woff',
	'html/img/backgrounds/*.png',
	'html/img/apps/*.png',
}

-- lua54 'yes'
-- dependency '/assetpacks'