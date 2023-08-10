local wormsAreas = {
	vec3(-2032.7327880859,2579.5544433594,3.2153236865997),
	vec3(-1989.3514404297,2619.1096191406,2.4598224163055),
	vec3(-1973.5017089844,2625.6213378906,2.8955934047699),
	vec3(-1982.2094726563,2640.5043945313,2.7563672065735),
	vec3(-2024.3325195313,2574.8977050781,3.2034060955048),
	vec3(-2033.0997314453,2580.7585449219,3.234183549881),
	vec3(-2022.6160888672,2596.4672851563,1.7896817922592),
	vec3(-1966.3800048828,2593.0424804688,2.7236592769623),
	vec3(-1930.6479492188,2608.8068847656,1.6230727434158),
	vec3(-1913.3424072266,2613.7473144531,3.3237926959991),
	vec3(-1929.4725341797,2632.3959960938,3.2984654903412),
	vec3(-1950.1020507813,2652.7661132813,2.8752472400665),
	vec3(-2015.0523681641,2571.0471191406,2.7963798046112),
}

local wormsLocation = vec3(-1987.1396484375,2596.4577636718,1.5778241157532)
local sellingLocation = vec3(-675.04931640625,5834.380859375,17.331401824951)
local theJob = "Pescar"
local missionData = {}
local IsFishing = false;

local function createWormsAreas()
	local inWormsTask = false
	local onCollecting = false
	local lastArea = vec3(0,0,0)
	local wormsZoneBlip = nil

	while theJob == "Pescar" do
		while #(wormsLocation - pedPos) <= 25 do
			if not inWormsTask then
				inWormsTask = true
				wormsZoneBlip = AddBlipForRadius(wormsLocation, 25.0)
				SetBlipAlpha(wormsZoneBlip, 115)
				SetBlipColour(wormsZoneBlip, 38)

				TriggerEvent("vRP:requestKey", {key = "E", text = "Cauta momeala"})
			end
			if IsControlJustPressed(0, 51) then
				if IsPedInAnyVehicle(PlayerPedId()) then 
					return tvRP.notify("Nu poti face asta dintr-un vehicul!")
				end
				if not onCollecting then
					onCollecting = true
					if #(lastArea - pedPos) <= 1 then
						tvRP.notify("Ai sapat deja aici..", "warning")
						onCollecting = false
					else
						lastArea = pedPos
						TriggerEvent("vRP:progressBar", {
							duration = 10500,
							text = "🦐 Cauti momeala...",
							anim = {
								scenario = "world_human_gardener_plant",
							}
						}, function()
							onCollecting = false
							vRPserver.collectOneWorm({})
						end)
					end
				end
			end
			Wait(1)
		end
		if inWormsTask then
			TriggerEvent("vRP:requestKey", false)
			if DoesBlipExist(wormsZoneBlip) then
				RemoveBlip(wormsZoneBlip)
				wormsZoneBlip = nil
			end
			inWormsTask = false
		end
		Wait(1000)
	end
end

local serverCall = function(str, data)
    local toret = {}
    local p = promise.new()
    vRPserver[str](data, function(...)
        toret = { ... }
        p:resolve()
    end)
    Citizen.Await(p)
    return table.unpack(toret)
end

-- [PESCAR NPCS]

Citizen.CreateThread(function()
    tvRP.createPed("vRP_jobs:fisherStore", {
        position = sellingLocation,
        rotation = 405,
        model = "ig_russiandrunk",
        freeze = true,
        minDist = 3.5,

        name = "Eduardo Sanchez",
        description = "Angajat magazin: Pescar",
        text = "Bine ai venit la noi, cu ce te putem ajuta?!",
        fields = {
            {item = "Vreau sa vand peste.", post = "fp-fisher:vindePestele"},
            {item = "Vreau sa vand momeala.", post = "fp-fisher:vindeMomeala"},
        },
    })
    tvRP.createBlip("vRP_jobs:fisherStoreBlip", sellingLocation.x, sellingLocation.y, sellingLocation.z, 317, 18, "Pescaria Bayview", 0.650)
end)


AddEventHandler('FairPlay:JobChange', function(job, skill)
	if job == "Pescar" then
		createWormsAreas();
	end
end)


RegisterNetEvent("fp-fisher:vindePestele")
AddEventHandler("fp-fisher:vindePestele", function()
	vRPserver.sellTheFish({"fish"})
end)

RegisterNetEvent("fp-fisher:vindeMomeala")
AddEventHandler("fp-fisher:vindeMomeala", function()
	vRPserver.sellTheFish({"worms"})
end)

RegisterNetEvent("fp-fisher:infoMomeala")
AddEventHandler("fp-fisher:infoMomeala", function()
	tvRP.notify("Ti-am setat locatia pe GPS!")
	SetNewWaypoint(wormsLocation.x, wormsLocation.y)
end)
