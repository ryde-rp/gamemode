local vRP = Proxy.getInterface("vRP")
local hiringLocation = vector3(87.841934204102,292.52819824219,110.20738983154)

CreateThread(function()
	vRP.createPed({"vRP_jobs:GlovoJob", {
		position = hiringLocation,
		rotation = 240,
		model = "u_m_y_chip",
		freeze = true,
		scenario = {
			name = "WORLD_HUMAN_CLIPBOARD_FACILITY"
		},
		minDist = 3.5,
		
		name = "Vali Glovo",
		description = "Manager job: Glovo",
		text = "Bine ai venit la noi, cu ce te putem ajuta?!",
		fields = {
			{item = "Vreau informatii despre job.", post = "fadeGlovo:OpenMenu", args={"server"}},
			{item = "Vreau sa cumpar licenta", post = "fadeGlovo:BuyLicense", args={"server"}},
			{item = "Vreau sa ma angajez.", post = "fadeGlovo:addGroup"},
			{item = "Nu mai vreau sa lucrez.", post = "fadeGlovo:removeGroup"},
		},
	}})
end)

RegisterNetEvent("fadeglovo:openGlovo", function()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OpenGlovo",
        jobActive = exports["vrp"]:HasGlovoJobActive(), 
    })
end)

RegisterNUICallback("closeGlovo", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("startGlovo", function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('fade:jobs-Glovo')
    cb("ok")
end)

RegisterNetEvent("fadeGlovo:addGroup")
AddEventHandler("fadeGlovo:addGroup", function()
	TriggerServerEvent("vRP:addJob", "Glovo")
end)

RegisterNetEvent("fadeGlovo:removeGroup")
AddEventHandler("fadeGlovo:removeGroup", function()
	TriggerServerEvent("vRP:removeJob", "Glovo")
end)