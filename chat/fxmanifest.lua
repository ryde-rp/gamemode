fx_version 'cerulean'
game 'gta5'
description 'chat management stuff'
ui_page 'html/index.html'
ui_page_preload 'yes'
lua54 'yes'

client_scripts {
  'cl_chat.lua',
}

server_script{
  "@vrp/lib/utils.lua",
  'sv_chat.lua',
}

files {
  'html/**/*',
}
