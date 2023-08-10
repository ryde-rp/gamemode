

vRP = Proxy.getInterface("vRP") -- vRPclient
vRPqb = Tunnel.getInterface("vRP_qbphone", "vRP_qbphone")


local PlayerJob = {}
PhoneData = {
	MetaData = {},
	isOpen = false,
	focus = false,
	PlayerData = nil,
	Contacts = {},
	CallData = {},
	RecentCalls = {},
	Mails = {},
	Tweets = {},
	UserTweets = {},
	AnimationData = {
		lib = nil,
		anim = nil
	},
	SuggestedContacts = {},
	Images = {}
}


exports("isOpen", function()
	return PhoneData.isOpen
end)

-- Functions

function string:split(delimiter)
	local result = { }
	local from  = 1
	local delim_from, delim_to = string.find( self, delimiter, from  )
	while delim_from do
	  table.insert( result, string.sub( self, from , delim_from-1 ) )
	  from  = delim_to + 1
	  delim_from, delim_to = string.find( self, delimiter, from  )
	end
	table.insert( result, string.sub( self, from  ) )
	return result
end

local function checkIfContact(num)
	local retval = num
	for _, v in pairs(PhoneData.Contacts) do
		if num == v.number then
			retval = v.name
		end
	end
	return retval
end

RegisterNetEvent("qb-phone:client:updatePlayerStatus", function(phoneNumber, isOnline)
	SendNUIMessage({
		action = "UpdatePlayerStatus",
		number = phoneNumber,
		isOnline = isOnline
	})
end)

RegisterNUICallback("getContactName", function(data, cb)
	if data.number then
		cb(checkIfContact(data.number))
	end
end)

RegisterNetEvent("vRP:setTime", function(hour, minute)
	if minute <= 9 then
		minute = "0" .. minute
	end

	SendNUIMessage({
		action = "UpdateTime",
		hour = hour,
		minute = minute
	})
end)

local function LoadPhone()
	Citizen.Wait(100)

	vRPqb.getPhoneData({}, function(pData)

		PhoneData.MetaData = pData.PhoneMeta

		if pData.InstalledApps ~= nil and next(pData.InstalledApps) ~= nil then
			for k, v in pairs(pData.InstalledApps) do
				local AppData = Config.StoreApps[v.app]
				Config.PhoneApplications[v.app] = {
					app = v.app,
					color = AppData.color,
					icon = AppData.icon,
					tooltipText = AppData.title,
					tooltipPos = "right",
					job = AppData.job,
					blockedjobs = AppData.blockedjobs,
					slot = AppData.slot,
					Alerts = 0,
				}
			end
		end

		if pData.Applications ~= nil and next(pData.Applications) ~= nil then
			for k, v in pairs(pData.Applications) do
				Config.PhoneApplications[k].Alerts = v
			end
		end


		if pData.PlayerContacts ~= nil and next(pData.PlayerContacts) ~= nil then
			PhoneData.Contacts = pData.PlayerContacts
		end

		if pData.Images ~= nil and next(pData.Images) ~= nil then
			PhoneData.Images = pData.Images
		end
		
		if pData.wappFrontMessages ~= nil and next(pData.wappFrontMessages) ~= nil then
			PhoneData.wappFrontMessages = pData.wappFrontMessages

			for _, data in pairs(PhoneData.wappFrontMessages) do
				data[3] = checkIfContact(data[1])
			end
		else
			PhoneData.wappFrontMessages = {}
		end

		PhoneData.Mails = pData.Mails

		PhoneData.Tweets = pData.Tweets

		PhoneData.UserTweets = pData.UserTweets

		SendNUIMessage({
			action = "LoadPhoneData",
			PhoneData = PhoneData,
			PlayerData = PhoneData.PlayerData,
			applications = Config.PhoneApplications
		})
	end)
end

local function OpenPhone()
	vRPqb.hasPhone({}, function(HasPhone, myPhone, myIdentity)
		if HasPhone then
			PhoneData.PlayerData = {
				phone = myPhone
			}

			if myIdentity.firstname then
				PhoneData.PlayerData.firstname = myIdentity.firstname
				PhoneData.PlayerData.name = myIdentity.name
			end

			PhoneData.focus = true
			SetNuiFocus(true, true)
			SendNUIMessage({
				action = "open",
				AppData = Config.PhoneApplications,
				CallData = PhoneData.CallData,
				PlayerData = PhoneData.PlayerData,
			})
			PhoneData.isOpen = true

			CreateThread(function()
				while PhoneData.isOpen do
					if not PhoneData.focus then
						DisableControlAction(0, 25, true) -- disable aim
					else
						DisableControlAction(0, 1, true) -- disable mouse look
						DisableControlAction(0, 2, true) -- disable mouse look
						DisableControlAction(0, 3, true) -- disable mouse look
						DisableControlAction(0, 4, true) -- disable mouse look
						DisableControlAction(0, 5, true) -- disable mouse look
						DisableControlAction(0, 6, true) -- disable mouse look
						DisableControlAction(0, 263, true) -- disable melee
						DisableControlAction(0, 264, true) -- disable melee
						DisableControlAction(0, 257, true) -- disable melee
						DisableControlAction(0, 140, true) -- disable melee
						DisableControlAction(0, 141, true) -- disable melee
						DisableControlAction(0, 142, true) -- disable melee
						DisableControlAction(0, 143, true) -- disable melee
						DisableControlAction(0, 177, true) -- disable escape
						DisableControlAction(0, 200, true) -- disable escape
						DisableControlAction(0, 202, true) -- disable escape
						DisableControlAction(0, 322, true) -- disable escape
						DisableControlAction(0, 245, true) -- disable chat
					end
					Citizen.Wait(1)
				end
			end)

			if not PhoneData.CallData.InCall then
				DoPhoneAnimation('cellphone_text_in')
			else
				DoPhoneAnimation('cellphone_call_to_text')
			end

			Citizen.SetTimeout(250, function()
				newPhoneProp()
			end)
		else
			vRP.notify({"Nu ai un telefon mobil!", "error", false, "fas fa-mobile-retro"})
		end
	end)
end

local function GenerateCallId(caller, target)
	caller, target = tostring(caller), tostring(target)
	if caller:find("-") then
		caller = caller:gsub("-", "")
	end

	if target:find("-") then
		target = target:gsub("-", "")
	end

	local CallId = math.ceil(((tonumber(caller) + tonumber(target)) / 100 * 1))
	return CallId
end

local serviceCall = false

local function CancelCall()
	TriggerServerEvent('qb-phone:server:CancelCall', PhoneData.CallData)
	if PhoneData.CallData.CallType == "ongoing" then
		exports['pma-voice']:removePlayerFromCall(PhoneData.CallData.CallId)
	end

	if serviceCall then
		serviceCall = false
		ExecuteCommand("cancelservice")
	end

	PhoneData.CallData.CallType = nil
	PhoneData.CallData.InCall = false
	PhoneData.CallData.AnsweredCall = false
	PhoneData.CallData.TargetData = {}
	PhoneData.CallData.CallId = nil

	if not PhoneData.isOpen then
		StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
		deletePhone()
		PhoneData.AnimationData.lib = nil
		PhoneData.AnimationData.anim = nil
	else
		PhoneData.AnimationData.lib = nil
		PhoneData.AnimationData.anim = nil
	end

	TriggerServerEvent('qb-phone:server:SetCallState', false)

	if not PhoneData.isOpen then
		SendNUIMessage({
			action = "PhoneNotification",
			PhoneNotify = {
				title = "Phone",
				text = "Apelul a fost incheiat",
				icon = "fas fa-phone",
				color = "#e84118"
			}
		})
	else
		SendNUIMessage({
			action = "PhoneNotification",
			PhoneNotify = {
				title = "Phone",
				text = "Apelul a fost incheiat",
				icon = "fas fa-phone",
				color = "#e84118"
			}
		})

		SendNUIMessage({
			action = "CancelOutgoingCall"
		})
	end
end

local function AnswerCall()
	if (PhoneData.CallData.CallType == "incoming" or PhoneData.CallData.CallType == "outgoing") and PhoneData.CallData.InCall and not PhoneData.CallData.AnsweredCall then
		PhoneData.CallData.CallType = "ongoing"
		PhoneData.CallData.AnsweredCall = true
		PhoneData.CallData.CallTime = 0

		SendNUIMessage({ action = "AnswerCall", CallData = PhoneData.CallData})
		SendNUIMessage({ action = "SetupHomeCall", CallData = PhoneData.CallData})

		TriggerServerEvent('qb-phone:server:SetCallState', true)

		TriggerServerEvent('qb-phone:server:AddRecentCall', false, {
			number = PhoneData.CallData.number,
			anonymous = PhoneData.CallData.anonymous
		})

		if PhoneData.isOpen then
			DoPhoneAnimation('cellphone_text_to_call')
		else
			DoPhoneAnimation('cellphone_call_listen_base')
		end

		CreateThread(function()
			while true do
				if PhoneData.CallData.AnsweredCall then
					PhoneData.CallData.CallTime = PhoneData.CallData.CallTime + 1
					SendNUIMessage({
						action = "UpdateCallTime",
						Time = PhoneData.CallData.CallTime,
						Name = PhoneData.CallData.TargetData.name,
					})
				else
					break
				end

				Citizen.Wait(1000)
			end
		end)

		TriggerServerEvent('qb-phone:server:AnswerCall', PhoneData.CallData)
		exports['pma-voice']:addPlayerToCall(PhoneData.CallData.CallId)
	else
		PhoneData.CallData.InCall = false
		PhoneData.CallData.CallType = nil
		PhoneData.CallData.AnsweredCall = false

		SendNUIMessage({
			action = "PhoneNotification",
			PhoneNotify = {
				title = "Phone",
				text = "Nu ai un apel in asteptare...",
				icon = "fas fa-phone",
				color = "#e84118",
			},
		})
	end
end

local function CallContact(CallData, AnonymousCall)
	local RepeatCount = 0
	PhoneData.CallData.CallType = "outgoing"
	PhoneData.CallData.InCall = true
	PhoneData.CallData.TargetData = CallData
	PhoneData.CallData.AnsweredCall = false
	PhoneData.CallData.CallId = GenerateCallId(PhoneData.PlayerData.phone, CallData.number)

	TriggerServerEvent('qb-phone:server:CallContact', PhoneData.CallData.TargetData, PhoneData.CallData.CallId, AnonymousCall)
	TriggerServerEvent('qb-phone:server:SetCallState', true)

	for i = 1, Config.CallRepeats + 1, 1 do
		if not PhoneData.CallData.AnsweredCall then
			if RepeatCount + 1 ~= Config.CallRepeats + 1 then
				if PhoneData.CallData.InCall then
					RepeatCount = RepeatCount + 1
					TriggerServerEvent("InteractSound_SV:PlayOnSource", "demo", 0.1)
				else
					break
				end
				Wait(Config.RepeatTimeout)
			else
				CancelCall()
				break
			end
		else
			break
		end
	end
end


RegisterNetEvent("qb-phone:notify", function(notificationData)
	if notificationData and type(notificationData) == "table" then
		SendNUIMessage({
			action = "PhoneNotification",
			PhoneNotify = notificationData
		})
	end
end)


local function CellFrontCamActivate(activate)
	return Citizen.InvokeNative(0x2491A93618B7D838, activate)
end

-- Command

RegisterCommand('phone', function()
	if not PhoneData.isOpen then
		OpenPhone()
	end
end)

RegisterKeyMapping('phone', 'Deschide Telefon', 'keyboard', 'L')


RegisterNUICallback("toggleFocus", function() ExecuteCommand('phonefocus') end)
RegisterCommand('phonefocus', function()
	if PhoneData.isOpen then
		if PhoneData.focus then
			PhoneData.focus = false
			SetNuiFocus(false, false)
		else
			PhoneData.focus = true
			SetNuiFocus(true, true)
		end
	end
end)

RegisterKeyMapping('phonefocus', 'Misca Camera', 'MOUSE_BUTTON', 'MOUSE_RIGHT')

-- NUI Callbacks

RegisterNUICallback('CancelOutgoingCall', function()
	CancelCall()
end)

RegisterNUICallback('DenyIncomingCall', function()
	CancelCall()
end)

RegisterNUICallback('CancelOngoingCall', function()
	CancelCall()
end)

RegisterNUICallback('AnswerCall', function()
	AnswerCall()
end)

RegisterNUICallback('ClearRecentAlerts', function(data, cb)
	TriggerServerEvent('qb-phone:server:SetPhoneAlerts', "phone", 0)
	Config.PhoneApplications["phone"].Alerts = 0
	SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
end)

RegisterNUICallback('SetBackground', function(data, cb)
	local background = data.background
	PhoneData.MetaData.background = background
	TriggerServerEvent('qb-phone:server:SaveMetaData', PhoneData.MetaData)
	cb(true)
end)

RegisterNUICallback('GetMissedCalls', function(data, cb)
	cb(PhoneData.RecentCalls)
end)

RegisterNUICallback('GetSuggestedContacts', function(data, cb)
	cb(PhoneData.SuggestedContacts)
end)

RegisterNetEvent('qb-phone:client:newMail')
AddEventHandler('qb-phone:client:newMail', function(newMail, manyMails)
	if manyMails then
		PhoneData.Mails = newMail
	else
		PhoneData.Mails[#PhoneData.Mails + 1] = newMail
	end
    
    SendNUIMessage({
        action = "UpdateMails",
        Mails = PhoneData.Mails
    })
end)

RegisterNUICallback("RemoveMail", function(data, cb)
	TriggerServerEvent("qb-phone:server:RemoveMail", data.deleteAll or data.mailId)
    cb("ok")
end)

RegisterNUICallback("GetMails", function(data, cb)
	cb(PhoneData.Mails or {})
end)

RegisterNUICallback("GetTweets", function(data, cb)
	cb(PhoneData.Tweets or {})
end)

RegisterNUICallback("GetSelfTweets", function(data, cb)
	cb(PhoneData.UserTweets or {})
end)

RegisterNUICallback('PostNewTweet', function(data, cb)
	local oneMsg = data.msg
	local newTweet = {
		firstName = PhoneData.PlayerData.firstname,
		lastName = PhoneData.PlayerData.name,
		msg = oneMsg,
		id = math.random(111, 999) * (GetGameTimer() / 2),
	}

    TriggerServerEvent('qb-phone:server:PostTweet', newTweet)
    cb("ok")
end)

RegisterNUICallback("DeleteTweet", function(data, cb)
	if data.id then
		TriggerServerEvent("qb-phone:server:DeleteTweet", data.id)
	end

	cb("ok")
end)

RegisterNetEvent("qb-phone:client:UpdateTweets", function(utype, updateTbl)
	if utype == "insertOne" then
		table.insert(PhoneData.Tweets, 1, updateTbl)
	elseif utype == "insertSelf" then
		table.insert(PhoneData.UserTweets, 1, updateTbl)
	elseif utype == "deleteOne" then
		for k, tx in pairs(PhoneData.Tweets) do
			if tx.id == updateTbl then
				table.remove(PhoneData.Tweets, k)

				for s, sx in pairs(PhoneData.UserTweets) do
					if sx.id == updateTbl then
						table.remove(PhoneData.UserTweets, s)
						break
					end
				end

				break
			end
		end
	end

	Citizen.Wait(250)
	SendNUIMessage({
        action = "UpdateTweets",
        Tweets = PhoneData.Tweets,
        SelfTweets = PhoneData.UserTweets,
	})
end)

RegisterNUICallback('HasPhone', function(data, cb)
	vRPqb.hasPhone({}, function(HasPhone)
		cb(HasPhone)
	end)
end)


RegisterNUICallback('Close', function()
	if not PhoneData.CallData.InCall or not PhoneData.CallData.AnsweredCall then
		DoPhoneAnimation('cellphone_text_out')
		SetTimeout(400, function()
			StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
			deletePhone()
			PhoneData.AnimationData.lib = nil
			PhoneData.AnimationData.anim = nil
		end)
	elseif PhoneData.CallData.InCall and PhoneData.CallData.AnsweredCall then
		PhoneData.AnimationData.lib = nil
		PhoneData.AnimationData.anim = nil
		DoPhoneAnimation('cellphone_text_to_call')
	end
	PhoneData.focus = false
	SetNuiFocus(false, false)
	SetTimeout(500, function()
		PhoneData.isOpen = false
	end)
end)

RegisterNUICallback('AddNewContact', function(data, cb)
	PhoneData.Contacts[#PhoneData.Contacts+1] = {
		name = data.ContactName,
		number = data.ContactNumber
	}
	Citizen.Wait(100)
	cb(PhoneData.Contacts)
	TriggerServerEvent('qb-phone:server:AddNewContact', data.ContactName, data.ContactNumber)
end)

RegisterNetEvent("qb-phone:addMessage", function(number, theMsg)

	for index, data in pairs(PhoneData.wappFrontMessages) do
		if data[1] == number then
			table.remove(PhoneData.wappFrontMessages, index)
		end
	end

	local textInFront = theMsg[1]
    if theMsg[4] == 1 then
        textInFront = "<i class='fas fa-map-marker'></i> Locatie distribuita"
    elseif theMsg[4] == 2 then
        textInFront = "<i class='fas fa-images'></i> Fotografie"
    end

    if theMsg[3] then
        textInFront = "Dvs.: "..textInFront
    end

	table.insert(PhoneData.wappFrontMessages, 1, {number, false, checkIfContact(number), textInFront, theMsg[2]})

	SendNUIMessage({
		action = "AddMessage",
		number = number,
		msg = theMsg
	})
end)

RegisterNUICallback('SendMessage', function(data, cb)
	if data.msgType == 1 then
		local pos = GetEntityCoords(PlayerPedId())
		data.msg = {
			x = pos.x,
			y = pos.y
		}
	end
	TriggerServerEvent("qb-phone:sendMessage", data.to, data.msg, data.msgType or false)
end)

RegisterNUICallback("pwGetFrontMessages", function(data, cb)
	cb(PhoneData.wappFrontMessages)
end)

RegisterNUICallback("pwGetMessages", function(data, cb)
	vRPqb.getMessages({data.number, data.skip}, function(messages)
		cb(messages)
	end)
end)


RegisterNetEvent("fp-phone:setGPS", function(x, y)
	local currentPos = GetEntityCoords(PlayerPedId())
	local vectorPos = vector3(x, y, currentPos.z)

	SetNewWaypoint(x, y)
	SendNUIMessage({
		action = "PhoneNotification",
		PhoneNotify = {
			title = "Hărți",
			text = "Locatia a fost setata (<b>"..math.floor(#(currentPos - vectorPos)).."m</b>)",
			icon = "fas fa-location-arrow",
			color = "#257acf",
			timeout = 3000,
		},
	})
end)

RegisterNUICallback('SharedLocation', function(data, cb)
	local x = data.coords.x
	local y = data.coords.y

	TriggerEvent("fp-phone:setGPS", x, y)
	cb("ok")
end)

RegisterNUICallback("workAtJob", function(data, cb)
	if data.job then
		TriggerServerEvent(data.job)
	end

	cb("ok")
end)

RegisterNUICallback('EditContact', function(data, cb)
	local NewName = data.CurrentContactName
	local NewNumber = data.CurrentContactNumber
	local OldNumber = data.OldContactNumber

	for k, v in pairs(PhoneData.Contacts) do
		if v.number == OldNumber then
			v.name = NewName
			v.number = NewNumber
		end
	end
	Citizen.Wait(100)
	cb(PhoneData.Contacts)
	TriggerServerEvent('qb-phone:server:EditContact', NewName, NewNumber, OldNumber)
end)

RegisterNUICallback('GetGalleryData', function(data, cb)
    local data = PhoneData.Images
    cb(data)
end)

RegisterNUICallback('DeleteImage', function(image,cb)
	TriggerServerEvent('qb-phone:server:RemoveImageFromGallery',image)
	Citizen.Wait(400)
	TriggerServerEvent('qb-phone:server:getImageFromGallery')
	cb(true)
end)

RegisterNUICallback('DeleteContact', function(data, cb)
	local Number = data.CurrentContactNumber

	for k, v in pairs(PhoneData.Contacts) do
		if v.number == Number then
			table.remove(PhoneData.Contacts, k)
			--if PhoneData.isOpen then
				SendNUIMessage({
					action = "PhoneNotification",
					PhoneNotify = {
						title = "Phone",
						text = "Contactul a fost sters!",
						icon = "fa fa-phone-alt",
						color = "#04b543",
						timeout = 1500,
					},
				})
			break
		end
	end
	Citizen.Wait(100)
	cb(PhoneData.Contacts)
	TriggerServerEvent('qb-phone:server:RemoveContact', Number)
end)


RegisterNUICallback('SetupStoreApps', function(data, cb)
	local PlayerData = QBCore.Functions.GetPlayerData()
	local data = {
		StoreApps = Config.StoreApps,
		PhoneData = PlayerData.metadata["phonedata"]
	}
	cb(data)
end)

RegisterNUICallback('ClearGeneralAlerts', function(data)
	SetTimeout(400, function()
		Config.PhoneApplications[data.app].Alerts = 0
		SendNUIMessage({
			action = "RefreshAppAlerts",
			AppData = Config.PhoneApplications
		})
		TriggerServerEvent('qb-phone:server:SetPhoneAlerts', data.app, 0)
		SendNUIMessage({ action = "RefreshAppAlerts", AppData = Config.PhoneApplications })
	end)
end)



RegisterNUICallback('CallContact', function(data, cb)
	vRPqb.getCallState({data.ContactData}, function(CanCall, IsOnline)
		local status = {
			CanCall = CanCall,
			IsOnline = IsOnline,
			InCall = PhoneData.CallData.InCall,
		}
		cb(status)
		if CanCall and not status.InCall and (data.ContactData.number ~= PhoneData.PlayerData.phone) then
			CallContact(data.ContactData, data.Anonymous)
		end
	end)
end)

RegisterNUICallback("TakePhoto", function(data, cb)
    PhoneData.focus = false
    SetNuiFocus(false, false)
    CreateMobilePhone(1)
    CellCamActivate(true, true)
    takePhoto = true
    local photoTaken = false

    while takePhoto do
        if IsControlJustPressed(1, 27) then 
            frontCam = not frontCam
            CellFrontCamActivate(frontCam)
        elseif IsControlJustPressed(1, 177) then 
            DestroyMobilePhone()
            CellCamActivate(false, false)
            cb(json.encode({ url = nil }))
            takePhoto = false
            break
        elseif IsControlJustPressed(1, 176) then 
            vRPqb.getWebhook({}, function(hook)
                if hook and not photoTaken then
                    photoTaken = true

                    exports['screenshot-basic']:requestScreenshotUpload(tostring(hook), "files[]", function(data)

                        local image = json.decode(data)

                        if image and image.attachments and #image.attachments > 0 then
                            local imageUrl = image.attachments[1].proxy_url


                            DestroyMobilePhone()
                            CellCamActivate(false, false)
                            takePhoto = false

                            TriggerServerEvent('qb-phone:server:addImageToGallery', imageUrl)
                            Citizen.Wait(400)
                            TriggerServerEvent('qb-phone:server:getImageFromGallery')
                            cb(json.encode(imageUrl))
                        else
                            DestroyMobilePhone()
                            CellCamActivate(false, false)
                            takePhoto = false
                            cb(json.encode({ url = nil }))
                        end
                    end)
                elseif photoTaken then
                    DestroyMobilePhone()
                    CellCamActivate(false, false)
                    takePhoto = false
                    cb(json.encode({ url = nil }))
                else
                    DestroyMobilePhone()
                    CellCamActivate(false, false)
                    takePhoto = false
                    cb(json.encode({ url = nil }))
                end
            end)
        end

        HideHudComponentThisFrame(7)
        HideHudComponentThisFrame(8)
        HideHudComponentThisFrame(9)
        HideHudComponentThisFrame(6)
        HideHudComponentThisFrame(19)
        HideHudAndRadarThisFrame()
        EnableAllControlActions(0)
        Citizen.Wait(0)
    end

    Citizen.Wait(1000)
    OpenPhone()
end)


-- Handler Events

RegisterNetEvent('playerSpawned', function()
	LoadPhone()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
	PhoneData = {
		MetaData = {},
		isOpen = false,
		PlayerData = nil,
		Contacts = {},
		CallData = {},
		RecentCalls = {},
		AnimationData = {
			lib = nil,
			anim = nil,
		},
		SuggestedContacts = {}
	}
end)

-- Events

RegisterNetEvent("qb-phone:client:loadRecentCalls", function(recentCalls)
	for _, recentCall in pairs(recentCalls) do
		table.insert(PhoneData.RecentCalls, {
			name = checkIfContact(recentCall[1].number),
			time = recentCall[2],
			type = recentCall[3],
			number = recentCall[1].number,
			anonymous = recentCall[1].anonymous
		})
	end
end)

RegisterNetEvent('qb-phone:client:AddRecentCall', function(data, time, type)
	PhoneData.RecentCalls[#PhoneData.RecentCalls+1] = {
		name = checkIfContact(data.number),
		time = time,
		type = type,
		number = data.number,
		anonymous = data.anonymous
	}
	TriggerServerEvent('qb-phone:server:SetPhoneAlerts', "phone")
	Config.PhoneApplications["phone"].Alerts = Config.PhoneApplications["phone"].Alerts + 1
	SendNUIMessage({
		action = "RefreshAppAlerts",
		AppData = Config.PhoneApplications
	})
end)

RegisterNetEvent('qb-phone:client:CancelCall', function()
	if PhoneData.CallData.CallType == "ongoing" then
		SendNUIMessage({
			action = "CancelOngoingCall"
		})
		exports['pma-voice']:removePlayerFromCall(PhoneData.CallData.CallId)
	end
	PhoneData.CallData.CallType = nil
	PhoneData.CallData.InCall = false
	PhoneData.CallData.AnsweredCall = false
	PhoneData.CallData.TargetData = {}

	if not PhoneData.isOpen then
		StopAnimTask(PlayerPedId(), PhoneData.AnimationData.lib, PhoneData.AnimationData.anim, 2.5)
		deletePhone()
		PhoneData.AnimationData.lib = nil
		PhoneData.AnimationData.anim = nil
	else
		PhoneData.AnimationData.lib = nil
		PhoneData.AnimationData.anim = nil
	end

	TriggerServerEvent('qb-phone:server:SetCallState', false)

	if not PhoneData.isOpen then
		SendNUIMessage({
			action = "PhoneNotification",
			NotifyData = {
				title = "Phone",
				content = "Apelul s-a incheiat",
				icon = "fas fa-phone",
				timeout = 3500,
				color = "#e84118",
			},
		})
	else
		SendNUIMessage({
			action = "PhoneNotification",
			PhoneNotify = {
				title = "Phone",
				text = "Apelul s-a incheiat",
				icon = "fas fa-phone",
				color = "#e84118",
			},
		})

		SendNUIMessage({
			action = "SetupHomeCall",
			CallData = PhoneData.CallData,
		})

		SendNUIMessage({
			action = "CancelOutgoingCall",
		})
	end
end)

RegisterNetEvent("qb-phone:client:autoAnswer", function()
	SendNUIMessage({
		action = "AutoAnswerPhoneCall"
	})
end)

RegisterNetEvent('qb-phone:client:GetCalled', function(CallerNumber, CallId, AnonymousCall)
	local RepeatCount = 0
	local CallData = {
		number = CallerNumber,
		name = checkIfContact(CallerNumber),
		anonymous = AnonymousCall
	}

	if AnonymousCall then
		CallData.name = "Număr Ascuns"
	end

	PhoneData.CallData.CallType = "incoming"
	PhoneData.CallData.InCall = true
	PhoneData.CallData.AnsweredCall = false
	PhoneData.CallData.TargetData = CallData
	PhoneData.CallData.CallId = CallId

	TriggerServerEvent('qb-phone:server:SetCallState', true)

	for i = 1, Config.CallRepeats + 1, 1 do
		if not PhoneData.CallData.AnsweredCall then
			if RepeatCount + 1 ~= Config.CallRepeats + 1 then
				if PhoneData.CallData.InCall then
					vRPqb.hasPhone({}, function(HasPhone)
						if HasPhone then
							RepeatCount = RepeatCount + 1
							-- TriggerServerEvent("InteractSound_SV:PlayOnSource", "ringing", 0.2)

							-- if not PhoneData.isOpen then
								SendNUIMessage({
									action = "IncomingCallAlert",
									CallData = PhoneData.CallData.TargetData,
									Canceled = false,
									AnonymousCall = AnonymousCall
								})
							-- end
						end
					end)
				else
					SendNUIMessage({
						action = "IncomingCallAlert",
						CallData = PhoneData.CallData.TargetData,
						Canceled = true,
						AnonymousCall = AnonymousCall,
					})
					TriggerServerEvent('qb-phone:server:AddRecentCall', true, {
						number = CallerNumber,
						anonymous = AnonymousCall
					})

					break
				end
				Citizen.Wait(Config.RepeatTimeout)
			else
				SendNUIMessage({
					action = "IncomingCallAlert",
					CallData = PhoneData.CallData.TargetData,
					Canceled = true,
					AnonymousCall = AnonymousCall,
				})
				TriggerServerEvent('qb-phone:server:AddRecentCall', true, {
					number = CallerNumber,
					anonymous = AnonymousCall
				})

				break
			end
		else
			TriggerServerEvent('qb-phone:server:AddRecentCall', false, {
				number = CallerNumber,
				anonymous = AnonymousCall
			})
			break
		end
	end
end)

RegisterNetEvent('qb-phone:RefreshPhone', function()
	LoadPhone()
	SetTimeout(250, function()
		SendNUIMessage({
			action = "RefreshAlerts",
			AppData = Config.PhoneApplications,
		})
	end)
end)


RegisterNetEvent('qb-phone:client:AnswerCall', function()
	if (PhoneData.CallData.CallType == "incoming" or PhoneData.CallData.CallType == "outgoing") and PhoneData.CallData.InCall and not PhoneData.CallData.AnsweredCall then
		PhoneData.CallData.CallType = "ongoing"
		PhoneData.CallData.AnsweredCall = true
		PhoneData.CallData.CallTime = 0

		SendNUIMessage({ action = "AnswerCall", CallData = PhoneData.CallData})
		SendNUIMessage({ action = "SetupHomeCall", CallData = PhoneData.CallData})

		TriggerServerEvent('qb-phone:server:SetCallState', true)

		if PhoneData.isOpen then
			DoPhoneAnimation('cellphone_text_to_call')
		else
			DoPhoneAnimation('cellphone_call_listen_base')
		end

		CreateThread(function()
			while true do
				if PhoneData.CallData.AnsweredCall then
					PhoneData.CallData.CallTime = PhoneData.CallData.CallTime + 1
					SendNUIMessage({
						action = "UpdateCallTime",
						Time = PhoneData.CallData.CallTime,
						Name = PhoneData.CallData.TargetData.name
					})
				else
					break
				end

				Citizen.Wait(1000)
			end
		end)
		exports['pma-voice']:addPlayerToCall(PhoneData.CallData.CallId)
	else
		PhoneData.CallData.InCall = false
		PhoneData.CallData.CallType = nil
		PhoneData.CallData.AnsweredCall = false

		SendNUIMessage({
			action = "PhoneNotification",
			PhoneNotify = {
				title = "Phone",
				text = "Nu ai un apel in asteptare...",
				icon = "fas fa-phone",
				color = "#e84118",
			},
		})
	end
end)

RegisterNetEvent('qb-phone:refreshImages', function(images)
    PhoneData.Images = images
end)

-- service ---

RegisterNUICallback("callForTaxi", function(data, cb)
	TriggerServerEvent("vrp-taxi:addServiceCall", data[1])
	
	cb("ok")
end)

RegisterNUICallback("callService", function(data, cb)
	print(data.service)
	if data and data.service then
		if data.service == "Politie" then
			data.service = 'Politia Romana'
			TriggerServerEvent("vRP:factionCall", "Politia Romana")
		elseif data.service == 'Politia Romana' then
			TriggerServerEvent("vRP:factionCall", "Politia Romana")
		elseif data.service == "Smurd" then
			TriggerServerEvent("vRP:factionCall", "Smurd")
		else
			vRPqb.hasActiveCall({data.service}, function(has)
				if not has then
					PhoneData.CallData.CallType = "outgoing"
					PhoneData.CallData.InCall = true
					PhoneData.CallData.AnsweredCall = false
					PhoneData.CallData.TargetData = {
						name = data.service
					}
					if data.service == 'Politie' then
						data.service = 'Politia Romana'
					end
					serviceCall = data.service
					TriggerServerEvent("fp-services:addCall", data.service)
				end
				cb(has)
			end)
		end
	end
end)

RegisterNetEvent("fp-services:generateCall", function(uid, phoneNo, serviceName)
	serviceCall = false

	PhoneData.CallData.CallType = "outgoing"
	PhoneData.CallData.InCall = true
	PhoneData.CallData.AnsweredCall = false
	PhoneData.CallData.TargetData = {
		name = serviceName,
		number = phoneNo
	}
	PhoneData.CallData.CallId = GenerateCallId(PhoneData.PlayerData.phone, uid*1000)

	TriggerServerEvent('qb-phone:server:CallService', uid, PhoneData.CallData.CallId)
	TriggerServerEvent('qb-phone:server:SetCallState', true)
end)

----

-- bank --

RegisterNUICallback("GetBankMoney", function(data, cb)
	vRPqb.getBankMoney({}, function(amount)
		cb(amount)
	end)
end)

RegisterNUICallback("transferMoney", function(data, cb)
	TriggerServerEvent("qb-phone:server:tryTransferMoney", data)
end)

----

-- blocked contacts --

local blockedContacts = {}

RegisterNetEvent("qb-phone:client:setBlockedContacts", function(blockedList)
	blockedContacts = blockedList
end)

RegisterNUICallback("blockContact", function(data)
	table.insert(blockedContacts, data.number)
	TriggerServerEvent("qb-phone:server:blockContact", data.number)
end)

RegisterNUICallback("unblockContact", function(data)
	for index, nr in pairs(blockedContacts) do
		if nr == data.number then
			table.remove(blockedContacts, index)
		end
	end
	TriggerServerEvent("qb-phone:server:unblockContact", data.number)
end)

RegisterNUICallback("getBlockedContacts", function(data, cb)
	cb(blockedContacts)
end)

RegisterNUICallback("isContactBlockedMe", function(data, cb)
	vRPqb.isContactBlockedMe({data.number}, function(hasBlockedMe)
		cb(hasBlockedMe)
	end)
end)

----

-- RoAlert --

RegisterNetEvent("vRP:onRoAlert", function(msg)
	SendNUIMessage({
		action = "RoAlert",
		msg = msg
	})
end)

----

-- Premium Shop --

RegisterNUICallback("openPremiumShop", function(none, cb)
	ExecuteCommand("shop")
	cb("ok")
end)


-- Threads

Citizen.CreateThread(function()
	Citizen.Wait(500)
	LoadPhone()
end)



