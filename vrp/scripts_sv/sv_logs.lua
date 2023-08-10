local logsNr = 0
local cacheLogs = {}

function vRP.createLog(user_id, details, lType, data, icon, target_player, status)
	target_player = target_player or 0;
	data = data or 'none'	
	status = status or 'info'

	local log = {
		user_id = user_id,
		target = target_player,
		status = status,
		text = details,
		type = lType,
		data = data,
		icon = icon,
		time = os.time(),
		date = os.date("%d/%m/%Y %H:%M")
	}

	cacheLogs[#cacheLogs + 1] = log
	logsNr = logsNr + 1

	if logsNr >= 10 then
		exports.oxmysql:execute("INSERT INTO serverLogs (user_id,target,status,text,type,data,icon,time,date) VALUES(@user_id,@target,@status,@text,@type,@data,@icon,@time,@date)",{
			['@user_id'] = log.user_id,
			['@target'] = log.target,
			['@status'] = log.status,
			['@text'] = json.encode(log.text),
			['@type'] = json.encode(log.type),
			['@data'] = log.data,
			['@icon'] = json.encode(log.icon),
			['@time'] = log.time,
			['@date'] = log.date
		})
		cacheLogs = {}
		logsNr = 0
	end
end

function vRP.pushLogs()
	if logsNr > 0 then
		exports.oxmysql:execute("INSERT INTO serverLogs (cacheLogs) VALUES(@cacheLogs)",{
			['@cacheLogs'] = json.encode(cacheLogs)
		})
		cacheLogs = {}
		logsNr = 0
		print("RV SYSTEM: LOGURILE AU FOST SALVATE IN DB")
	end
end

RegisterCommand("pushlogs", function(player)
	if player == 0 then
		vRP.pushLogs()
	end                                                                                                                                                                                                                                                                                                    
end)