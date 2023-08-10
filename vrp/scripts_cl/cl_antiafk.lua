local lastPos = nil
local playplayTime = 0
local SecondsUntilKick = 1200

local VipLevels = {
	[1] = 1200,
	[2] = 3600,
	[3] = 5400,
}
	
RegisterNetEvent("FP:SetSecondsUntilKick", function(type)
	SecondsUntilKick = VipLevels[type]
end)

Citizen.CreateThread(function()
	local time = SecondsUntilKick
	while true do
		Wait(5000)
		if pedPos ~= lastPos then
			if time > 0 then
				if time == 120 then
					TriggerEvent("chatMessage", "^1[ATENTIE] ^7In curand vei primi kick pentru ^1AFK^7!")
				end
			else
				TriggerServerEvent("vRP:disconnect", "Ai fost AFK prea mult timp!")
			end
		else
			time = SecondsUntilKick
		end
		lastPos = pedPos
	end
end)