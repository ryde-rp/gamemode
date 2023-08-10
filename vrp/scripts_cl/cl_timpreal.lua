local CreateThread = Citizen.CreateThread
local Wait = Citizen.Wait
local p = print
local ora = 12
local minut = 0
local secunde = 0
RegisterNetEvent('trimiteTimp')
AddEventHandler('trimiteTimp',function(theTime)
	if theTime == 'Day' then
		ora = 12
	elseif theTime == 'Night' then
		ora = 22
	elseif theTime == 'Noon' then
		ora = 18
	end
end)
CreateThread(function()
    while true do
        Wait(250) -- Wait 0 seconds to prevent crashing.
        NetworkOverrideClockTime(ora,minut,secunde)
    end
end)