local userReports = {}

function tvRP.verifyPoliceReports()
	local source = source
	local user_id = vRP.getUserId(source)
	local uReports = userReports[user_id]

	if not uReports then
		return vRPclient.notify(source, {"A intervenit o problema la comunicarea cu serverul Politiei Romane, va rugam sa reveniti mai tarziu!", "warning"})
	end

	if not table.notEmpty(uReports) then
		return vRPclient.notify(source, {"Cazierul tau judiciar este curat!", "info", false, "fas fa-folder-open"})
	end

	vRP.buildMenu("selfPoliceReports", {player = source}, function(menu)
		local closeAll = false
		menu.onclose = function(player)
			vRPclient.executeCommand(source, {"e c"})
		end

		local totalUserReports = table.len(uReports)
		vRPclient.executeCommand(source, {"e jstandingt"})

		for reportNum, reportData in pairs(uReports) do
			local reportTime = os.date("%d/%m/%Y %H:%M", reportData.time)

			menu["#"..reportNum.." - Cazier "..reportTime] = {function()
				vRP.buildMenu("selfPoliceReports", {player = source}, function(reportInfo)
					reportInfo.onclose = function(player)
						if not closeAll then
							vRP.openMenu(player, menu)
						end
					end

					reportInfo["1. 📆 Data emiterii: "..reportTime] = {}
					reportInfo["2. 👮🏻‍♂️ Emis de: "..reportData.author] = {}
					reportInfo["3. 📃 Motiv: "..reportData.reason] = {}

					reportInfo["💵 Plateste cazierele 💵"] = {function()
						local totalPrice = totalUserReports * 50000

						if vRP.tryPayment(user_id, totalPrice, true) then
							userReports[user_id] = {}
							closeAll = true
							vRP.closeMenu(source)

							Citizen.CreateThread(function()
								Citizen.Wait(500)

								exports.oxmysql:execute("UPDATE users SET userCazier = @userCazier WHERE id = @id",{
									['@id'] = user_id,
									['@userCazier'] = 0
								})

								vRPclient.notify(source, {"Ai platit $"..vRP.formatMoney(totalPrice), "success"})
								vRPclient.notify(source, {"Ti-ai platit toate cazierele!", "info", false, "fas fa-folder-open"})
								vRPclient.executeCommand(source, {"e c"})
							end)
						end
					end}

					vRP.openMenu(source,reportInfo)

					Citizen.CreateThread(function()
						Citizen.Wait(250)
						vRPclient.executeCommand(source, {"e jstandingt"})
					end)
				end)
			end}
		end

		menu["⚠️ 5 CAZIERE NEPLATITE = PUSCARIE PE VIATA ⚠️"] = {}
		menu["💶 1 CAZIER = 50.000$ 💶"] = {}

		vRP.openMenu(source,menu)
	end)
end

function vRP.getPoliceReportsNum(user_id, cbr)
	local task = Task(cbr, {0})
	local uReports = userReports[user_id]

	if uReports then
		local n = table.len(uReports)

		task({n})
	else
		task({0})
	end
end

function vRP.addPoliceReport(user_id, author, reason)
	if userReports[user_id] then
		local theReport = {
			time = os.time(),
			reason = reason,
			author = author,
		}

		Citizen.CreateThread(function()
			Citizen.Wait(250)
			exports.oxmysql:execute("UPDATE users SET userCazier = @userCazier WHERE id = @id",{
				['@id'] = user_id,
				['@userCazier'] = theReport
			}, function(success)
				if success then
					local source = vRP.getUserSource(user_id)
					
					if source then
						vRPclient.notify(source, {"Ai primit un cazier judiciar!", "warning", false, "fas fa-folder-open"})
					end

					exports.oxmysql:query("SELECT userCazier FROM users WHERE id = @id",{['@id'] = user_id},function(result)
						userReports[user_id] = result[1].userCazier
					end)
				end
			end)
		end)
	end
end

function vRP.removePoliceReport(user_id)
	local uReports = userReports[user_id]

	if uReports then
		local minTime = 0
		local minIndx = 1

		for i, v in ipairs(uReports) do
			if i == 1 then
				minTime = v.time
			else
				if v.time > minTime then
					minTime = v.time
					minIndx = i
				end
			end
		end

		if uReports[minIndx] then
			userReports[user_id][minIndx] = nil

			Citizen.CreateThread(function()
				Citizen.Wait(250)
				
				exports.oxmysql:execute("UPDATE users SET userCazier = @userCazier WHERE id = @id",{
					['@id'] = user_id,
					['@userCazier'] = {time = minTime}
				})
				
			end)

			return true
		end
	end

	return false
end

function vRP.getPoliceReports(user_id)
	local uReports = userReports[user_id]

	if uReports then
		return uReports
	end
end

AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn, dbdata)
	if first_spawn then		
		userReports[user_id] = dbdata.userCazier or {}
	end
end)

AddEventHandler("vRP:playerLeave", function(user_id)
	if userReports[user_id] then
		userReports[user_id] = nil
	end
end)