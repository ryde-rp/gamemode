fx_version("cerulean")
game("gta5")

ui_page("web/index.html")

description([[
	Buna dragutule, sa stii ca nu este frumos sa furi. Daca totusi
	esti decis sa furi, iti recomand sa bagi la cap ce scrie aici ca
	altfel o sa ramai la fel de prost cum esti acum, te pup ! ❤ - Semnat Robert.#3454
]])

client_scripts({
	"@vrp/client/Tunnel.lua",
	"@vrp/client/Proxy.lua",
	"client.lua",
	"utils-c.lua",
})

server_scripts {
    '@vrp/lib/utils.lua',
    'server.lua',
}

shared_scripts {
	'config.lua'
}


files({
	"web/**/*"
})


