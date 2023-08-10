local lastGroup = false
local function build_equipment_menu(theF)
	vRPserver.getPlayerFaction({}, function(userGroup)
		lastGroup = userGroup
		if userGroup ~= theF then
			return tvRP.notify("Nu poti accesa echipamentul!", "error")
		end

		SendNUIMessage({
			act = "interface",
			target = "factionEquipment",
			group = userGroup,
		})

		TriggerEvent("vRP:interfaceFocus", true)
	end)
end

RegisterNUICallback("fe:takeItem", function(data, _)
	if lastGroup ~= data.group then return end
	
	if string.find(data.item, "body") then
		if data.item == "body_armor" then
			TriggerServerEvent("fp-factions:equipItem","item", data.item)
		else
			TriggerServerEvent("fp-factions:equipItem", "weapon", data.item)
		end
	else
		TriggerServerEvent("fp-factions:equipItem","item", data.item)
	end
	_("discord.gg/ryde")
end)

local policeEquipment = vec3(482.5657043457,-995.3994140625,29.589624786377)
local smurdEquipment = vec3(-820.01013183594,-1242.6434326172,6.3374285697938)

CreateThread(function()
	tvRP.addMarker(policeEquipment.x, policeEquipment.y, policeEquipment.z, 0.50, 0.50, 0.50, 0, 205, 205, 95, 30, 6.5) -- Politia Romana
	tvRP.addMarker(smurdEquipment.x, smurdEquipment.y, smurdEquipment.z, 0.50, 0.50, 0.50, 159, 65, 71, 95, 30, 6.5) -- Smurd

	tvRP.setArea("vrp_fe:Politia_Romana", policeEquipment.x, policeEquipment.y, policeEquipment.z, 1.5, "Apasa tasta ~b~E ~w~pentru a deschide: ~b~Meniu Echipament", function() build_equipment_menu("Politia Romana") end)
	tvRP.setArea("vrp_fe:Smurd", smurdEquipment.x, smurdEquipment.y, smurdEquipment.z, 1.5, "Apasa tasta ~HC_28~E ~w~pentru a deschide: ~HC_28~Meniu Echipament", function() build_equipment_menu("Smurd") end)
end)
