local parachuteLocations = {
	vec3(455.27032470704,5571.806640625,781.18359375),
	vec3(429.11569213868,5614.8081054688,766.23840332032),
}

CreateThread(function()
	local radiusBlip = AddBlipForRadius(445.66641235352,5595.0893554688,765.89361572266, 200.0)
	SetBlipAlpha(radiusBlip, 50)
	local switchColor = false

	while true do
		for _, thePos in pairs(parachuteLocations) do
			while #(thePos - pedPos) <= 15.0 do
				DrawMarker(40, thePos, 0, 0, 0, 0, 0, 0, 0.55, 0.55, 0.55, 255, 255, 255, 90, true, true, false, true)
				DrawText3D(thePos.x, thePos.y, thePos.z, "~b~E ~w~- Echipeaza-ti parasuta", 0.5)

				if #(thePos - pedPos) <= 1.5 then
					if IsControlJustPressed(1, 38) then
						ExecuteCommand("e jtrynewc2")
						
						CreateThread(function()
							Wait(500)
							GiveWeaponToPed(tempPed, GetHashKey("GADGET_PARACHUTE"), 150, true, true)
							tvRP.notify("Ti-ai echipat o parasuta!", "info", false, "fas fa-parachute-box")
						end)
					end
				end

				Wait(1)
			end
		end

		switchColor = not switchColor
		if switchColor then
			SetBlipColour(radiusBlip, 18)
		else
			SetBlipColour(radiusBlip, 37)
		end

		Wait(2000)
	end
end)
