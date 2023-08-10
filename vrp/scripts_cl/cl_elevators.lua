local theElevators = {
	-- Spital Viceroy --
	{
		coordsFrom = vec3(-794.09753417969,-1245.7696533203,7.3374242782593),
		coordsTo = vec3(-773.96173095703,-1207.5109863281,51.147033691406),
		name = "Helipad Spital",
	},

	{
		coordsFrom = vec3(-774.00628662109,-1207.4738769531,51.147033691406),
		coordsTo = vec3(-794.09753417969,-1245.7696533203,7.3374242782593),
		name = "Helipad Spital",
	},

	-- Organizatie: Vespucci --
	{
		coordsFrom = vec3(895.80267333984,-3167.9411621094,-97.123641967773),
		coordsTo = vec3(-1275.7790527344,312.58657836914,65.511772155762),
		name = "Intrare oras",
	},

	{
		coordsFrom = vec3(-1582.6141357422,-558.87725830078,108.52296447754),
		coordsTo = vec3(-1537.4006347656,-578.23681640625,25.707794189453),
		name = "Sediu Organizatie",
	},
	{
		coordsFrom = vec3(-1574.0327148438,-565.42761230469,108.52286529541),
		coordsTo = vec3(-1560.7314453125,-569.32550048828,114.44839477539),
		name = "Helipad",
	},
	{
	    coordsFrom = vec3(-1560.7314453125,-569.32550048828,114.44839477539),
		coordsTo = vec3(-1574.0327148438,-565.42761230469,108.52286529541),
		name = "Sediu Organizatie",
	},

	-- Organizatie: Maze Bank --
	{
		coordsFrom = vec3(-84.140808105469,-821.86798095703,36.028038024902),
		coordsTo = vec3(-72.327072143555,-813.46148681641,285.00033569336),
		name = "Garaj Organizatie",
	},

	{
		coordsFrom = vec3(-72.327072143555,-813.46148681641,285.00033569336),
		coordsTo = vec3(-84.140808105469,-821.86798095703,36.028038024902),
		name = "Iesire",
	},

    {
    	coordsFrom = vec3(-69.540069580078,-828.08575439453,285.0002746582),
    	coordsTo = vec3(-78.864273071289,-833.02764892578,243.38578796387),
    	name = "Sediu Organizatie",
    },

    {
    	coordsFrom = vec3(-78.864273071289,-833.02764892578,243.38578796387),
    	coordsTo = vec3(-69.540069580078,-828.08575439453,285.0002746582),
    	name = "Garaj Organizatie",
    },
	{
		coordsFrom = vec3(-78.441040039063,-822.23883056641,243.38584899902),
		coordsTo = vec3(-74.93187713623,-824.23303222656,321.29214477539),
		name = "Helipad",
	},
	{
		coordsFrom = vec3(-74.93187713623,-824.23303222656,321.29214477539),
		coordsTo = vec3(-78.441040039063,-822.23883056641,243.38584899902),
		name = "Sediu Organizatie",
	},

	-- Organizatie: Vizavi Maze Bank --
	{
		coordsFrom = vec3(-143.7552947998,-575.53527832031,32.424510955811),
		coordsTo = vec3(-141.39794921875,-590.23760986328,167.00004577637),
		name = "Garaj Organizatie",
	},

	{
		coordsFrom = vec(-141.39794921875,-590.23760986328,167.00004577637),
		coordsTo = vec(-143.7552947998,-575.53527832031,32.424510955811),
		name = "Iesire",
	},

	{
		coordsFrom = vec3(-146.06356811523,-604.40393066406,167.00004577637),
		coordsTo = vec3(-141.12707519531,-614.18377685547,168.82054138184),
		name = "Sediu Organizatie",
	},
	{
		coordsFrom = vec3(-141.12707519531,-614.18377685547,168.82054138184),
		coordsTo = vec3(-146.06356811523,-604.40393066406,167.00004577637),
		name = "Garaj Organizatie",
	},
	{
		coordsFrom = vec3(-136.73017883301,-624.10717773438,168.82034301758),
		coordsTo = vec3(-134.03407287598,-584.50695800781,201.73522949219),
		name = "Helipad",
	},
	{
		coordsFrom = vec3(-134.03407287598,-584.50695800781,201.73522949219),
		coordsTo = vec3(-136.73017883301,-624.10717773438,168.82034301758),
		name = "Sediu Organizatie",
	},
    -- Club Bahamas --
	{
		coordsFrom = vec3(406.90145874023,243.39389038086,93.194137573242),
		coordsTo = vec3(323.35543823242,265.96044921875,104.39552307129),
		name = "Iesire Garaj",
	},
	{
		coordsFrom = vec3(323.35543823242,265.96044921875,104.39552307129),
		coordsTo = vec3(406.90145874023,243.39389038086,93.194137573242),
		name = "Intrare Garaj",
	},	
}

CreateThread(function()
	local entered = false
	while true do
		local eTicks = 800

		for _, v in pairs(theElevators) do
			local coordsFrom = v.coordsFrom

			if #(coordsFrom - pedPos) <= 10 then
				eTicks = 1

				DrawMarker(30, coordsFrom, 0, 0, 0, 0, 0, 0, 0.55, 0.55, 0.55, 116, 193, 255, 95, true, true, false, true)
				DrawText3D(coordsFrom.x, coordsFrom.y, coordsFrom.z, "Elevator~n~~HC_4~"..(v.name or ""), 0.5)

				local minDst = (GVEHICLE ~= 0) and 2.5 or 0.5

				if #(coordsFrom - pedPos) <= minDst and not entered then
					entered = true
					DoScreenFadeOut(1000)
					SetTimeout(1400,function()
						local cdsTo = v.coordsTo
						local veh = GVEHICLE

						if veh ~= 0 then
							local tmpFuel = GetVehicleFuelLevel(veh)

							SetEntityCoords(veh, cdsTo.x+0.0001, cdsTo.y+0.0001, cdsTo.z+0.0001, 1, 0, 0, 1)
							SetVehicleOnGroundProperly(veh)
							SetVehicleFuelLevel(veh, tmpFuel)
						end

						tvRP.teleport(cdsTo.x, cdsTo.y, cdsTo.z)
						if veh ~= 0 then
							TaskWarpPedIntoVehicle(tempPed, veh, -1)
						end

						DoScreenFadeIn(1000)
						Citizen.Wait((veh ~= 0) and 6500 or 2500)
						entered = false
					end)
				end
			end
		end

		Wait(eTicks)
	end
end)