local vRP = Proxy.getInterface("vRP")
vRPC = {}
Tunnel.bindInterface("vrp_roullete",vRPC)

local coords = {977.51873779297,50.005790710449,74.681137084961}
local open = false
local inMenu = true

local CreateThread = Citizen.CreateThread
local GetEntityCoords = GetEntityCoords
local IsControlJustPressed = IsControlJustPressed
local StartScreenEffect = StartScreenEffect
local DisableAllControlActions = DisableAllControlActions
local StopScreenEffect = StopScreenEffect
local SendNUIMessage = SendNUIMessage
local RegisterNUICallback = RegisterNUICallback
local SetNuiFocus = SetNuiFocus
local blip = vRP.addBlip({977.51873779297,50.005790710449,74.681137084961,266,5,"Lucky Roulette"})

local fontsLoaded = false

local fontId

Citizen.CreateThread(function()
  Citizen.Wait(1000)
  RegisterFontFile('wmk')
  fontId = RegisterFontId('Freedom Font')
    
  fontsLoaded = true
end)

local function togglePrizes()
	open = not open
	SendNUIMessage({type = "toggle"})
    SetNuiFocus(open, open)
end

RegisterNetEvent("prizes:setPrice")
AddEventHandler("prizes:setPrice", function(rollPrice, dmdPrice)
	SendNUIMessage({type = "setPrice", price = rollPrice, dmdPrice = dmdPrice})
end)

RegisterNetEvent("prizes:winSomething")
AddEventHandler("prizes:winSomething", function(winName)
	Wait(600)
	SendNUIMessage({type = "spinTo", itemId = winName})
end)

RegisterNUICallback('tryGetPrize', function(data, cb)
	if open then
		TriggerServerEvent("prizes:doPayment", data.withDmd)
	else
		vRP.notify({'Eroare: Ceau'})
	end
end)
RegisterNetEvent('prizes:exit')
AddEventHandler('prizes:exit',function()
	SendNUIMessage({type = "noteng"})
end)
RegisterNUICallback('NUIFocusOff', function()
	open = false
	SetNuiFocus(false, false)
	SendNUIMessage({type = 'closeAll'})
end)

RegisterNUICallback('exit', function()
	open = not open
	SetNuiFocus(open, open)
	StopScreenEffect("MenuMGHeistIn")
	StartScreenEffect("MenuMGHeistOut", 800, false)
	DisplayRadar(true)
end)

CreateThread(function()
	while true do
		local ped = PlayerPedId()
		local distance = #(GetEntityCoords(ped) - vector3(coords[1],coords[2],coords[3]))
		if distance <= 10 and not open then
			ticks = 1
		end
		if distance <= 6 and not open then
			ticks = 0
			drawText("~w~Apasa ~p~E ~w~pentru a juca la ~r~Lucky Roulette",2,11,0.5,0.9,0.35,255, 255, 255,255)
			if IsControlJustPressed(0,38) then
				StartScreenEffect("MenuMGHeistIn", 0, true)
				togglePrizes()
				DisplayRadar(false)
			end
		else
			ticks = 2000
		end
		Wait(ticks)
	end
end)


function drawText(text,font,centre,x,y,scale,r,g,b,a)
	SetTextFont(fontId)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(1, 5, 5, 5,255)
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end