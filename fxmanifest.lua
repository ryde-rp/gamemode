

fx_version "cerulean"
game "gta5"
lua54 "yes"
description "RP module/framework"

ui_page "gui/index.html"
ui_page_preload "yes"

resource_type "map" {
	gameTypes = {
		["Roleplay"] = true
	}
}

resource_type2 "gametype" {
	name = "Roleplay"
}

map "cfx/map.lua"

shared_scripts {
	"cfx/mapmanager_shared.lua",
	"cfg/jobs.lua",
} 


server_scripts{ 
	"cfx/hardcap_sv.lua",
	"cfx/mapmanager_server.lua",

	"lib/utils.lua",
	"base.lua",

	"modules/gui.lua",
	"modules/group.lua",
	"modules/admin.lua",
	"modules/vip.lua",
	"modules/factions.lua",
	"modules/jobs.lua",

	"modules/aptitude.lua",
	"modules/survival.lua",
	"modules/player_state.lua",
	"modules/cloakroom.lua",
	
	"modules/money.lua",
	"modules/inventory.lua",
	"modules/identity.lua",

	"modules/soundmanager.lua",
	"modules/map.lua",
	"modules/basic_garage.lua",
	"modules/basic_market.lua",
	"modules/police.lua",

	"scripts_sv/*.lua",
	"modules/jobs/ilegale/*.lua",
	"modules/jobs/legale/*.lua",
}

client_scripts{
	"cfx/spawnmanager.lua",
	"cfx/gamemode.lua",
	"cfx/hardcap_cl.lua",
	"cfx/mapmanager_client.lua",

	"lib/utils.lua",
	"client/Tunnel.lua",
	'@PolyZone/client.lua',
	"client/Proxy.lua",
	"client/base.lua",
	"client/npc.lua",
	
	"client/iplloader.lua",
	"client/gui.lua",
	"client/admin.lua",

  	"client/identity.lua",
	"client/player_state.lua",
	"client/survival.lua",

	"client/map.lua",
	"client/basic_garage.lua",
	"client/police.lua",

	"client/missions.lua",  	
	"scripts_cl/*",
	"client/jobs/ilegale/*.lua",
	"client/jobs/legale/*.lua",
}

files{
	"tattoosList.json",
	
	"cfg/base.lua",
	"cfg/client.lua",
	"cfg/cars.lua",

	"gui/**/*",
	"gui/modules/**/*",
}