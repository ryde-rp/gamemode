local inBed = {}
local totalBeds = 9

local hospitalBeds = {
	["viceroy"] = {
		{pos = vec4(-797.14, -1231.29, 7.25, 142.96), model = 1631638868}, -- spital viceroy
		{pos = vec4(-800.99, -1227.95, 7.25, 142.96), model = 1631638868}, -- spital viceroy
		{pos = vec4(-805.52, -1224.05, 7.25, 142.96), model = 1631638868}, -- spital viceroy
		{pos = vec4(-809.12, -1221.04, 7.25, 142.96), model = 1631638868}, -- spital viceroy
		{pos = vec4(-812.11, -1224.56, 7.25, 317.26), model = 1631638868}, -- spital viceroy
		{pos = vec4(-809.66, -1226.70, 7.25, 317.26), model = 1631638868}, -- spital viceroy
		{pos = vec4(-806.74, -1228.98, 7.25, 317.26), model = 1631638868}, -- spital viceroy
		{pos = vec4(-804.08, -1231.26, 7.25, 317.26), model = 1631638868}, -- spital viceroy
		{pos = vec4(-800.06, -1234.67, 7.25, 317.26), model = 1631638868}, -- spital viceroy
	},

	["wantedoras"] = {
		{pos = vec4(807.56939697266,-495.62817382813,31.517963409424, 317.26), model = 1631638868}, -- spital mafioti
	},

	["paleto"] = {
	    {pos = vec4(-257.46575927734,6321.9848632813,33.351661682129, 317.26), model = 1631638868}, -- spital paleto
	    {pos = vec4(-259.99957275391,6324.3681640625,33.351680755615, 317.26), model = 1631638868}, -- spital paleto
	    {pos = vec4(-262.28866577148,6326.5458984375,33.35164642334, 317.26), model = 1631638868}, -- spital paleto
	    {pos = vec4(-258.87515258789,6329.9672851563,33.351676940918, 317.26), model = 1631638868}, -- spital paleto
	    {pos = vec4(-256.58660888672,6327.7080078125,33.351676940918, 317.26), model = 1631638868}, -- spital paleto
	},

	["sandy"] = {
	    {pos = vec4(1823.4969482422,3680.6811523438,35.19938659668, 317.26), model = 1631638868}, -- spital sandy
	    {pos = vec4(1821.7219238281,3679.748046875,35.199352264404, 317.26), model = 1631638868}, -- spital sandy
	    {pos = vec4(1820.0728759766,3678.7434082031,35.199394226074, 317.26), model = 1631638868}, -- spital sandy
	    {pos = vec4(1818.2397460938,3677.6772460938,35.199394226074, 317.26), model = 1631638868}, -- spital sandy
	    {pos = vec4(1817.3293457031,3674.6315917969,35.199390411377, 317.26), model = 1631638868}, -- spital sandy
	    {pos = vec4(1818.2847900391,3673.0400390625,35.199398040771, 317.26), model = 1631638868}, -- spital sandy
	    {pos = vec4(1819.1676025391,3671.4086914063,35.199371337891, 317.26), model = 1631638868}, -- spital sandy
	    {pos = vec4(1820.0487060547,3669.564453125,35.199356079102, 317.26), model = 1631638868}, -- spital sandy
	    {pos = vec4(1823.2470703125,3672.212890625,35.199329376221, 317.26), model = 1631638868}, -- spital sandy
	    {pos = vec4(1822.3280029297,3674.0485839844,35.199333190918, 317.26), model = 1631638868}, -- spital sandy
	},

	["wantedout"] = {
		{pos = vec4(2811.4189453125,5975.4194335938,351.84210205078, 317.26), model = 1631638868}, -- spital maafioti in afara orasului
	},
}

local documentLocations = {
	{vec3(-817.57824707032,-1236.7119140625,7.337423324585), "viceroy"}, -- spital viceroy
	{vec3(806.83288574219,-493.33157348633,30.688301086426), "wantedoras"}, -- spital mafioti oras
	{vec3(1832.7424316406,3677.0402832031,34.274871826172), "sandy"}, -- spital sandy
	{vec3(-251.97573852539,6334.1850585938,32.427181243896), "paleto"}, -- spital paleto
	{vec3(2809.8732910156,5977.9755859375,350.91870117188), "wantedout"}, -- spital mafioti in afara orasului
}

function tvRP.getHospitalBed(hospitalType)
	local freeIndx = 0

	for _, bedId in pairs(inBed) do
		freeIndx = freeIndx + 1
	end
	
	if freeIndx >= #hospitalBeds[hospitalType] then
		return false
	end

	return freeIndx + 1
end

function tvRP.canReviveAtHospital()
	local user_id = vRP.getUserId(source)
	return vRP.tryPayment(user_id, 200, true)
end

RegisterServerEvent("hospital$joinBed", function()
	local user_id = vRP.getUserId(source)
	inBed[user_id] = true
end)

RegisterServerEvent("hospital$leaveLastBed", function()
	local user_id = vRP.getUserId(source)
	inBed[user_id] = nil
end)

AddEventHandler("vRP:playerSpawn", function(uid, src, first_spawn)
	if first_spawn then
		TriggerClientEvent("vRP:setHospitalBeds", src, hospitalBeds, documentLocations)
	end
end)