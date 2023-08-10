fx_version 'cerulean'
game 'gta5'

description 'QB-Radio'
version '1.0.0'

server_scripts {

  "@vrp/lib/utils.lua",
	"serverCallbackLib/server.lua",
  "server.lua"
}

client_scripts {
	"@vrp/client/Tunnel.lua",
	"@vrp/client/Proxy.lua",
  "serverCallbackLib/client.lua",
  'client.lua',
  'animation.lua'
}

ui_page('html/ui.html')

files {'html/ui.html', 'html/js/script.js', 'html/css/style.css', 'html/img/cursor.png', 'html/img/radio.png'}

--client_script 'xvcRYTsQXOzP.lua'