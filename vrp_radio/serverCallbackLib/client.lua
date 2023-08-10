--  ██▓███  ▓█████     ▄▄▄       ██▓ ▄████▄   ██▓    ▄▄▄         ▄▄▄█████▓ ██▀███  ▓█████  ▄████▄   █    ██ ▄▄▄█████▓   ▒███████▒▓█████ ▓█████  ███▄    █ 
--  ▓██░  ██▒▓█   ▀    ▒████▄    ▓██▒▒██▀ ▀█  ▓██▒   ▒████▄       ▓  ██▒ ▓▒▓██ ▒ ██▒▓█   ▀ ▒██▀ ▀█   ██  ▓██▒▓  ██▒ ▓▒   ▒ ▒ ▒ ▄▀░▓█   ▀ ▓█   ▀  ██ ▀█   █ 
--  ▓██░ ██▓▒▒███      ▒██  ▀█▄  ▒██▒▒▓█    ▄ ▒██▒   ▒██  ▀█▄     ▒ ▓██░ ▒░▓██ ░▄█ ▒▒███   ▒▓█    ▄ ▓██  ▒██░▒ ▓██░ ▒░   ░ ▒ ▄▀▒░ ▒███   ▒███   ▓██  ▀█ ██▒
--  ▒██▄█▓▒ ▒▒▓█  ▄    ░██▄▄▄▄██ ░██░▒▓▓▄ ▄██▒░██░   ░██▄▄▄▄██    ░ ▓██▓ ░ ▒██▀▀█▄  ▒▓█  ▄ ▒▓▓▄ ▄██▒▓▓█  ░██░░ ▓██▓ ░      ▄▀▒   ░▒▓█  ▄ ▒▓█  ▄ ▓██▒  ▐▌██▒
--  ▒██▒ ░  ░░▒████▒    ▓█   ▓██▒░██░▒ ▓███▀ ░░██░    ▓█   ▓██▒     ▒██▒ ░ ░██▓ ▒██▒░▒████▒▒ ▓███▀ ░▒▒█████▓   ▒██▒ ░    ▒███████▒░▒████▒░▒████▒▒██░   ▓██░
--  ▒▓▒░ ░  ░░░ ▒░ ░    ▒▒   ▓▒█░░▓  ░ ░▒ ▒  ░░▓      ▒▒   ▓▒█░     ▒ ░░   ░ ▒▓ ░▒▓░░░ ▒░ ░░ ░▒ ▒  ░░▒▓▒ ▒ ▒   ▒ ░░      ░▒▒ ▓░▒░▒░░ ▒░ ░░░ ▒░ ░░ ▒░   ▒ ▒ 
--  ░▒ ░      ░ ░  ░     ▒   ▒▒ ░ ▒ ░  ░  ▒    ▒ ░     ▒   ▒▒ ░       ░      ░▒ ░ ▒░ ░ ░  ░  ░  ▒   ░░▒░ ░ ░     ░       ░░▒ ▒ ░ ▒ ░ ░  ░ ░ ░  ░░ ░░   ░ ▒░
--  ░░          ░        ░   ▒    ▒ ░░         ▒ ░     ░   ▒        ░        ░░   ░    ░   ░         ░░░ ░ ░   ░         ░ ░ ░ ░ ░   ░      ░      ░   ░ ░ 
--              ░  ░         ░  ░ ░  ░ ░       ░           ░  ░               ░        ░  ░░ ░         ░                   ░ ░       ░  ░   ░  ░         ░ 
--                                   ░                                                     ░                             ░                                 

radio = {}
radio.CurrentRequestId          = 0
radio.ServerCallbacks           = {}

radio.TriggerServerCallback = function(name, cb, ...)
	radio.ServerCallbacks[radio.CurrentRequestId] = cb

	TriggerServerEvent('radio:triggerServerCallback', name, radio.CurrentRequestId, ...)

	if radio.CurrentRequestId < 65535 then
		radio.CurrentRequestId = radio.CurrentRequestId + 1
	else
		radio.CurrentRequestId = 0
	end
end

RegisterNetEvent('radio:serverCallback')
AddEventHandler('radio:serverCallback', function(requestId, ...)
	radio.ServerCallbacks[requestId](...)
	radio.ServerCallbacks[requestId] = nil
end)