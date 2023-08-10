

--

fx_version "cerulean"
game "gta5"
author "Proxy#4444"
description "Vangelico Robbery"
ui_page "html/index.html"

client_scripts({
	"cl_*.lua",
})

server_scripts({
	"@vrp/lib/utils.lua",
	"sv_*.lua",
})

files({
	"html/*",
})