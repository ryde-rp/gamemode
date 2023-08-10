



--
fx_version 'adamant'
game 'gta5'
ui_page 'client/html/index.html'

dependency "vrp"

server_scripts {
    '@vrp/lib/utils.lua',
    'server.lua'
}

client_scripts {
    '@vrp/client/Proxy.lua',
    'client/config.lua',
    'client/tatoos.lua',
    'client/skins.lua',
    'client/client.lua'
}

files {
    'client/html/index.html',
    'client/html/script.js',
    'client/html/style.css',

    'client/html/webfonts/*',
    'client/html/css/all.min.css',
}