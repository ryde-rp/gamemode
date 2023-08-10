fx_version 'adamant'

game 'gta5'

description 'RTX ANTICHEAT'

version '0.3'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/config.lua',
	'server/main.lua'
}

client_scripts {
	'client/config.lua',
	'client/main.lua'
}