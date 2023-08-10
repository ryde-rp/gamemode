
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", "vRP_qbphone")

vRPqb = {}
Tunnel.bindInterface("vRP_qbphone", vRPqb)

local phoneNumbers = {}
local phoneOwners = {}
local phoneIdentities = {}

local QBPhone = {}
local AppAlerts = {}
local Calls = {}
local WebHook = "https://discord.com/api/webhooks/1055955285665136670/JBrcrm8UAB_8uvvNebEtiAgyeC7zXue1zBfCfw-yvDv9EPHSTY75m8o3PNuaR5mGPpSA"

-- Functions


local function initPlayer(user_id, player)
    vRP.getUserIdentity({user_id, function(identity)

        if identity.phone == 0 or identity.phone == "0" then
            Citizen.Wait(5000)
            return initPlayer(user_id, player)
        end

        phoneNumbers[user_id] = identity.phone
        phoneOwners[identity.phone] = user_id
        phoneIdentities[user_id] = {firstname = identity.firstname, name = identity.name}
        TriggerClientEvent("qb-phone:client:updatePlayerStatus", -1, phoneNumbers[user_id], true)

        exports.oxmysql:query("SELECT * FROM phone_blockedContacts WHERE user_id = @user_id",{['@user_id'] = user_id}, function(res)
            local list = res[1] and res[1].list or {}
            Citizen.Wait(5000)
            TriggerClientEvent("qb-phone:client:setBlockedContacts", player, list)
        end)

        exports.oxmysql:query('SELECT * FROM phone_recentcalls WHERE `from` = ? OR `to` = ? ORDER BY time DESC LIMIT 20', {identity.phone, identity.phone}, function(result)
            local userRecentCalls = {}
            for _, data in pairs(result) do
                if data.from == identity.phone then
                    table.insert(userRecentCalls, {
                        {number = data.to, anonymous = data.anonymous}, data.time, data.missed and "missed" or "outgoing"
                    })
                else
                    table.insert(userRecentCalls, {
                        {number = data.from, anonymous = data.anonymous}, data.time, data.missed and "missed" or "incoming"
                    })
                end
            end

            Citizen.Wait(15000)
            TriggerClientEvent("qb-phone:client:loadRecentCalls", player, userRecentCalls)
        end)
    end})
end

AddEventHandler("vRP:playerSpawn", function(user_id, player, first_spawn)
    if first_spawn then
        initPlayer(user_id, player)
    end
end)

AddEventHandler("vRP:playerLeave", function(user_id)
    if phoneNumbers[user_id] then
        TriggerClientEvent("qb-phone:client:updatePlayerStatus", -1, phoneNumbers[user_id], false)
    end
end)

AddEventHandler("onResourceStart", function(res)
    if res == GetCurrentResourceName() then
        local users = vRP.getUsers({})
        for uid, src in pairs(users) do
            initPlayer(uid, src)
        end
    end
end)

exports("getPhoneNumber", function(user_id)
    return phoneNumbers[user_id] or false
end)

exports("sendPhoneError", function(player, msg)
    TriggerClientEvent("qb-phone:notify", player, {
        title = "Eroare",
        text = msg,
        icon = "fa-solid fa-triangle-exclamation",
        color = "#eb1313",
        timeout = 3000
    })
end)

exports("sendPhoneIncome", function(player, msg, jobName)
    TriggerClientEvent("qb-phone:notify", player, {
        title = jobName or "Ai primit",
        text = msg,
        icon = "fa-solid fa-circle-dollar",
        color = "#34cf60",
        timeout = 3000
    })
end)

exports("sendPhoneInfo", function(player, msg, title)
    TriggerClientEvent("qb-phone:notify", player, {
        title = title or "Info",
        text = msg,
        icon = "fa-solid fa-circle-info",
        color = "#00aaff",
        timeout = 3000
    })
end)

exports("sendPhoneNotify", function(player, msg, title, icon, colour)
    TriggerClientEvent("qb-phone:notify", player, {
        title = title or "Notificare",
        text = msg,
        icon = icon,
        color = colour,
        timeout = 3000
    })
end)

local function round(num, numDecimalPlaces)
    if numDecimalPlaces and numDecimalPlaces > 0 then
        local mult = 10 ^ numDecimalPlaces
        return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end

function QBPhone.SetPhoneAlerts(user_id, app, alerts)
    if user_id ~= nil and app ~= nil then
        if AppAlerts[user_id] == nil then
            AppAlerts[user_id] = {}
            if AppAlerts[user_id][app] == nil then
                if alerts == nil then
                    AppAlerts[user_id][app] = 1
                else
                    AppAlerts[user_id][app] = alerts
                end
            end
        else
            if AppAlerts[user_id][app] == nil then
                if alerts == nil then
                    AppAlerts[user_id][app] = 1
                else
                    AppAlerts[user_id][app] = 0
                end
            else
                if alerts == nil then
                    AppAlerts[user_id][app] = AppAlerts[user_id][app] + 1
                else
                    AppAlerts[user_id][app] = AppAlerts[user_id][app] + 0
                end
            end
        end
    end
end

-- Callbacks

function vRPqb.getCallState(ContactData)

    -- return canCall, isOnline

    local target_id = phoneOwners[ContactData.number]
    local target_src = vRP.getUserSource({target_id})

    if target_src then
        if Calls[target_id] then
            if Calls[target_id].inCall then
                return false, true
            else
                return true, true
            end
        else
            return true, true
        end
    else
        return false, false
    end
end


function vRPqb.getPhoneData()

    local player = source
    local user_id = vRP.getUserId({player})

    if user_id then
        local ready = 0

        local PhoneData = {
            Applications = {},
            PlayerContacts = {},
            Images = {},
            InstalledApps = {}, -- userTable["phonedata"] and userTable["phonedata"].InstalledApps or {},
            PhoneMeta = {},
            Mails = {},
            Tweets = {},
            UserTweets = {},
        }

        ready = ready + 1
        vRP.getUData({user_id, "phone:metadata", function(metaData)
            if metaData then
                local decoded = json.decode(metaData) or {}
                PhoneData.PhoneMeta = decoded
                ready = ready - 1
            end
        end})

        ready = ready + 1
        exports.oxmysql:query("SELECT * FROM phone_contacts WHERE user_id = @user_id",{['@user_id'] = user_id}, function(result)
            local Contacts = {}
            for k, v in pairs(result) do
                v.status = phoneOwners[v.number] or false
            end
            PhoneData.PlayerContacts = result
            ready = ready - 1
        end)

        ready = ready + 1
        PhoneData.wappFrontMessages = {}
        exports.oxmysql:query("SELECT wappFront FROM users WHERE id = @id",{['@id'] = user_id}, function(res)
            local wappFrontMessages = res[1].wappFront or {}
            for i, number in pairs(wappFrontMessages) do
                ready = ready + 1
                exports.oxmysql:query("SELECT * FROM phone_messages WHERE from = @from AND to = @to",{['@from'] = number, ['@to'] = number}, function(result)
                    
                    if result[1] then

                        local theMsg = result[1].msg
                        if result[1].msgType == 1 then
                            theMsg = "<i class='fas fa-map-marker'></i> Locatie distribuita"
                        elseif result[1].msgType == 2 then
                            theMsg = "<i class='fas fa-images'></i> Fotografie"
                        end

                        if result[1].from ~= number then
                            theMsg = "Dvs.: "..theMsg
                        end

                        PhoneData.wappFrontMessages[i] = {number, false, false, theMsg, result[1].time}

                    else
                        PhoneData.wappFrontMessages[i] = nil
                    end

                    ready = ready - 1
                end)
            end
            ready = ready - 1
        end)

        if AppAlerts[user_id] ~= nil then
            PhoneData.Applications = AppAlerts[user_id]
        end

        ready = ready + 1
        exports.oxmysql:query("SELECT * FROM phone_mails WHERE user_id = @user_id",{['@user_id'] = user_id}, function(result)
            PhoneData.Mails = result or {}
            ready = ready - 1
        end)

        ready = ready + 1
        exports.oxmysql:query("SELECT * FROM phone_tweets WHERE user_id = @user_id",{['@user_id'] = user_id}, function(result)
            PhoneData.Tweets = result or {}
            ready = ready - 1
        end)

        ready = ready + 1
        exports.oxmysql:query("SELECT * FROM phone_tweets WHERE user_id = @user_id",{['@user_id'] = user_id}, function(result)
            PhoneData.UserTweets = result or {}
            ready = ready - 1
        end)

        ready = ready + 1
        exports.oxmysql:query("SELECT image,date FROM phone_gallery WHERE user_id = @user_id",{['@user_id'] = user_id}, function(images)
            if images ~= nil and next(images) ~= nil then
                PhoneData.Images = images
            end
            ready = ready - 1
        end)

        local i = 0
        while ready > 0 or i < 50 do
            Citizen.Wait(50)
            i = i + 1
        end

        return PhoneData
    end
end

RegisterNetEvent("qb-phone:sendMessage", function(targetNumber, msg, msgType)
    local player = source
    local user_id = vRP.getUserId({player})
    local myNumber = phoneNumbers[user_id]
    if user_id then

        local theMessage = {
            from = myNumber,
            to = targetNumber,
            msg = msg,
            time = os.time()
        }

        if msgType then
            theMessage.msgType = msgType
        end

        exports.oxmysql:execute("INSERT INTO phone_messages (from,to,msg,time,msgType) VALUES('@from','@to','@msg','@time','@msgType')",{
            ['@from'] = theMessage.from,
            ['@to'] = theMessage.to,
            ['@msg'] = theMessage.msg,
            ['@time'] = theMessage.time,
            ['@msgType'] = theMessage.msgType
        }, function()

                TriggerClientEvent("qb-phone:addMessage", player, targetNumber, {msg, theMessage.time, true, msgType or 0})

                local targetQuery = {['phone'] = targetNumber}

                for uid, number in pairs(phoneNumbers) do

                    if number == targetNumber then
                        local target = vRP.getUserSource({uid})

                        if target then
                            TriggerClientEvent("qb-phone:addMessage", target, myNumber, {msg, theMessage.time, false, msgType or 0})
                        end

                        targetQuery = {id = uid}

                        break
                    end

                end

                exports.oxmysql:execute("UPDATE users SET wappFront = @wappFront WHERE id = @id",{
                    ['@id'] = user_id,
                    ['@wappFront'] = targetNumber
                }, function()
                    exports.oxmysql:execute('UPDATE users SET wappFront = JSON_ARRAY_INSERT(wappFront, "$[0]", ?) WHERE id = ?', json.encode(targetNumber), user_id)
                end)

                exports.oxmysql:execute("UPDATE users SET wappFront = @wappFront WHERE id = @id",{
                    ['@id'] = user_id,
                    ['@wappFront'] = myNumber
                }, function()
                    exports.oxmysql:execute('UPDATE users SET wappFront = JSON_ARRAY_INSERT(wappFront, "$[0]", ?) WHERE id = ?', json.encode(myNumber), targetQuery)
                end)

        end)

    end 
end)

function vRPqb.getMessages(number, skipCount)
    local player = source
    local user_id = vRP.getUserId({player})
    local myNumber = phoneNumbers[user_id]
    if user_id then
        local result, ready = {}, false
        exports.oxmysql:execute('SELECT msg, time, from = ? as isFrom, msgType FROM phone_messages WHERE (from = ? AND to = ?) OR (from = ? AND to = ?) ORDER BY _id DESC LIMIT 15 OFFSET ?', { myNumber, myNumber, number, number, myNumber, skipCount }, function(res)
            for _, data in pairs(res) do
                table.insert(result, { data.msg, data.time, (data.isFrom == 1), data.msgType or 0 })
            end
            ready = true
        end)
        local i = 0
        while not ready do
            Citizen.Wait(50)
            i = i + 1
            if i >= 50 then break end
        end
        return result
    end
    return {}
end

function vRPqb.hasPhone()
    local player = source
    local user_id = vRP.getUserId({player})
    if user_id then
        return (vRP.getInventoryItemAmount({user_id, "phone"}) >= 1) or false, phoneNumbers[user_id], phoneIdentities[user_id]
    end
end

function vRPqb.getWebhook()
    return WebHook ~= "" and WebHook or nil
end

RegisterNetEvent('qb-phone:server:SetCallState', function(bool)
    local player = source
    local user_id = vRP.getUserId({player})

    if not Calls[user_id] then
        Calls[user_id] = {}
    end

    Calls[user_id].inCall = bool
end)

RegisterNetEvent('qb-phone:server:CallContact', function(TargetData, CallId, AnonymousCall)

    local player = source
    local user_id = vRP.getUserId({player})
    if user_id then

        local target_id = phoneOwners[TargetData.number]
        local target_src = vRP.getUserSource({target_id})

        if target_src then
            TriggerClientEvent('qb-phone:client:GetCalled', target_src, phoneNumbers[user_id], CallId, AnonymousCall)
        end

    end
end)

RegisterNetEvent('qb-phone:server:CallService', function(target_id, CallId)
    local player = source
    local user_id = vRP.getUserId({player})
    if user_id then
        local target_src = vRP.getUserSource({target_id})
        if target_src then
            TriggerClientEvent('qb-phone:client:GetCalled', target_src, phoneNumbers[user_id], CallId)
        end
    end
end)

RegisterNetEvent('qb-phone:server:SetPhoneAlerts', function(app, alerts)
    local player = source
    local user_id = vRP.getUserId({player})
    QBPhone.SetPhoneAlerts(user_id, app, alerts)
end)


RegisterNetEvent('qb-phone:server:EditContact', function(newName, newNumber, oldNumber)
    local player = source
    local user_id = vRP.getUserId({player})

    exports.oxmysql:execute('UPDATE phone_contacts SET number = ?, name = ? WHERE user_id = ? AND number = ?', {newNumber, newName, user_id, oldNumber})
end)

RegisterNetEvent('qb-phone:server:RemoveContact', function(Number)
    local player = source
    local user_id = vRP.getUserId({player})

    exports.oxmysql:execute('DELETE FROM phone_contacts WHERE user_id = ? AND number = ?', {user_id, Number})
end)

RegisterNetEvent('qb-phone:server:AddNewContact', function(name, number)
    local player = source
    local user_id = vRP.getUserId({player})

    local newContact = {
        user_id = user_id,
        name = name,
        number = number
    }
    exports.oxmysql:execute('INSERT INTO phone_contacts (user_id, name, number) VALUES (?, ?, ?)', {newContact.user_id, newContact.name, newContact.number})
end)



RegisterNetEvent('qb-phone:server:AddRecentCall', function(wasMissed, data)
    local player = source
    local user_id = vRP.getUserId({player})

    local target_id = phoneOwners[data.number]
    local target_src = vRP.getUserSource({target_id})

    if target_src then
        local label = os.date("%d.%m.%Y %H:%M")
        TriggerClientEvent('qb-phone:client:AddRecentCall', player, data, label, wasMissed and "missed" or "outgoing")
        TriggerClientEvent('qb-phone:client:AddRecentCall', target_src, {
            number = phoneNumbers[user_id],
            anonymous = data.anonymous
        }, label, wasMissed and "missed" or "incoming")

        exports.oxmysql:execute('INSERT INTO phone_recentcalls (from, to, time, anonymous, missed) VALUES (?, ?, ?, ?, ?)', {
            phoneNumbers[user_id],
            data.number,
            label,
            data.anonymous,
            wasMissed and 1 or 0
        })
    end
end)


RegisterNetEvent('qb-phone:server:CancelCall', function(ContactData)
    if not ContactData.service then
        local target_id = phoneOwners[ContactData.TargetData.number]
        local target_src = vRP.getUserSource({target_id})

        if target_src then
            TriggerClientEvent("qb-phone:client:CancelCall", target_src)
        end
    end
end)

RegisterNetEvent('qb-phone:server:AnswerCall', function(CallData)
    local target_id = phoneOwners[CallData.TargetData.number]
    local target_src = vRP.getUserSource({target_id})

    if target_src then
        TriggerClientEvent("qb-phone:client:AnswerCall", target_src)
    end
end)

RegisterNetEvent('qb-phone:server:SaveMetaData', function(MData)
    local player = source

    local user_id = vRP.getUserId({player})
    if user_id then
        vRP.setUData({user_id, "phone:metadata", json.encode(MData)})
    end
end)

RegisterNetEvent('fp-phone:addMail', function(mailData, usedSrc, ignoreDb)
    local player = source
    if not GetPlayerName(player) then
        player = usedSrc
    end

    local user_id = vRP.getUserId({player})

    if user_id then 
        local newMail = {
            user_id = user_id,
            sender = mailData.sender,
            subject = mailData.subject,
            message = mailData.message,
            mailid = math.random(111111, 999999),
            date = os.time(),
            button = mailData.button,
        }

        exports['vrp_phone']:sendPhoneNotify(player, "De la "..mailData.sender, "Mail", "fas fa-envelope", "#eb1313")

        if not ignoreDb then
            exports.oxmysql:execute("INSERT INTO phone_mails (user_id, sender, subject, message, mailid, date, button) VALUES (@user_id, @sender, @subject, @message, @mailid, @date, @button)", {
                ['@user_id'] = newMail.user_id,
                ['@sender'] = newMail.sender,
                ['@subject'] = newMail.subject,
                ['@message'] = json.encode(newMail.message),
                ['@mailid'] = newMail.mailid,
                ['@date'] = newMail.date,
                ['@button'] = newMail.button
            })
        end

        TriggerClientEvent("qb-phone:client:newMail", player, newMail)
    else
        print("Eroare: Nu am putut sa iti gasim id-ul")
    end
end)

RegisterNetEvent('qb-phone:server:RemoveMail', function(mailId)
    local player = source
    local user_id = vRP.getUserId({player})

    if type(mailId) == "boolean" then
        exports.oxmysql:query("DELETE FROM phone_mails WHERE user_id = @user_id", {['@user_id'] = user_id})
        TriggerClientEvent("qb-phone:client:newMail", player, {}, true)
        return
    end

    exports.oxmysql:query("DELETE FROM phone_mails WHERE user_id = @user_id AND mailid = @mailid", {['@user_id'] = user_id, ['@mailid'] = mailid})
    Citizen.Wait(500)

    exports.oxmysql:query("SELECT * FROM phone_mails WHERE user_id = @user_id",{['@user_id'] = user_id}, function(result)
        TriggerClientEvent("qb-phone:client:newMail", player, result or {}, true)
    end)
end)

local function updateTweetsForNow(src, utype, updateTbl)
    TriggerClientEvent("qb-phone:client:UpdateTweets", src, utype, updateTbl)
end

RegisterNetEvent("qb-phone:server:PostTweet", function(tweetTbl)
    local player = source
    local user_id = vRP.getUserId({player})

    if type(tweetTbl) == "table" then
        tweetTbl.user_id = user_id
        tweetTbl.time = os.time()

        exports.oxmysql:execute("INSERT INTO phone_tweets (user_id,message,time,firstName,lastName) VALUES(@user_id, @message, @time,@firstName,@lastName)", {
            ["@user_id"] = tweetTbl.user_id,
            ["@firstName"] = tweetTbl.firstName,
            ["@lastName"] = tweetTbl.lastName,
            ["@message"] = tweetTbl.msg,
            ["@time"] = tweetTbl.time
        })
        updateTweetsForNow(-1, "insertOne", tweetTbl)
        updateTweetsForNow(player, "insertSelf", tweetTbl)
    end
end)


RegisterNetEvent("qb-phone:server:DeleteTweet", function(oneTweet)
    local player = source
    local user_id = vRP.getUserId({player})

    if oneTweet then
        exports.oxmysql:execute('DELETE FROM phone_tweets WHERE id = @tweetid AND user_id = @user_id', {
            ['@tweetid'] = oneTweet,
            ['@user_id'] = user_id
        })
        updateTweetsForNow(-1, "deleteOne", oneTweet)
    end
end)

RegisterNetEvent('qb-phone:server:addImageToGallery', function(image)
    local player = source
    local user_id = vRP.getUserId({player})
    local currentDate = os.date("%Y-%m-%d %H:%M:%S") -- Formatare data și oră

    exports.oxmysql:execute("INSERT INTO phone_gallery (user_id, image, date) VALUES (@user_id, @image, @date)", {
        ['@user_id'] = user_id,
        ['@image'] = image,
        ['@date'] = currentDate
    }, function(rowsAffected)
        print("Rows affected: " .. tostring(rowsAffected))
    end)
end)

RegisterNetEvent('qb-phone:server:getImageFromGallery', function()
    local player = source
    local user_id = vRP.getUserId({player})

    exports.oxmysql:query("SELECT image,date FROM phone_gallery WHERE user_id = @user_id", {['@user_id'] = user_id}, function(images)

        TriggerClientEvent("qb-phone:refreshImages", player, images)
    end)
end)

RegisterNetEvent('qb-phone:server:RemoveImageFromGallery', function(data)
    local player = source
    local user_id = vRP.getUserId({player})

    exports.oxmysql:query("DELETE FROM phone_gallery WHERE user_id = @user_id AND image = @image",{['@user_id'] = user_id,['@image'] = data.image})
end)

-- Service --

function vRPqb.hasActiveCall(serviceName)

    local player = source
    local user_id = vRP.getUserId({player})
    if user_id then
        -- local activeCall = exports['vrp']:hasActiveCall(user_id)
        local activeCall = {}
        return activeCall and true or false
    end

end

----

-- Bank

function vRPqb.getBankMoney()
    local player = source
    local user_id = vRP.getUserId({player})
    if user_id then
        local bankMoney = vRP.getBankMoney({user_id})
        return bankMoney
    end
end

RegisterNetEvent("qb-phone:server:tryTransferMoney", function(data)
    local player = source
    local user_id = vRP.getUserId({player})
    if user_id then
        local amm = tonumber(data.amount)
        if type(data) == "table" and data.number and amm then
            if vRP.tryBankPayment({user_id, amm, false}) then



                local target_id = phoneOwners[data.number]
                if target_id then
                    local target_src = vRP.getUserSource({target_id})
                    
                    amm = math.ceil(amm * 0.95)

                    TriggerClientEvent("qb-phone:notify", target_src, {
                        title = "+"..vRP.formatMoney({amm}).." $",
                        text = "De la "..phoneNumbers[user_id],
                        icon = "fa-solid fa-money-check-dollar",
                        color = "#10b516",
                        timeout = 3000
                    })

                    TriggerClientEvent("qb-phone:notify", player, {
                        title = "-"..vRP.formatMoney({amm}).." $",
                        text = "Către "..data.number,
                        icon = "fa-solid fa-money-check-dollar",
                        color = "#10b516",
                        timeout = 3000
                    })


                    vRP.giveBankMoney({target_id, amm, "Transfer from "..user_id})
                    vRP.logMoney({user_id, target_id, amm})

                else
                    exports.oxmysql:execute("UPDATE users SET bankMoney = @bankMoney WHERE phone = @phone",{['@phone'] = data.number,['@bankMoney'] = math.ceil(amm * 0.95)}, function()
                        exports.oxmysql:query("SELECT * FROM users WHERE phone = @phone",{['@phone'] = data.number}, function(result)
                            if result[1] and result[1].id then
                                local target_id = result[1].id
                                vRP.logMoney({user_id, target_id, math.ceil(amm * 0.95)})

                                TriggerClientEvent("qb-phone:notify", player, {
                                    title = "-"..vRP.formatMoney({math.ceil(amm * 0.95)}).." $",
                                    text = "Către "..data.number,
                                    icon = "fa-solid fa-money-check-dollar",
                                    color = "#10b516",
                                    timeout = 3000
                                })

                            else
                                TriggerClientEvent("qb-phone:notify", player, {
                                    title = "Numar invalid",
                                    text = "Tranzactie anulata",
                                    icon = "fa-solid fa-triangle-exclamation",
                                    color = "#eb1313",
                                    timeout = 5000
                                })
                                vRP.giveBankMoney({user_id, amm, "Transfer Invalid Return"})
                            end
                        end)
                    end)
                end

            else
                TriggerClientEvent("qb-phone:notify", player, {
                    title = "Transfer",
                    text = "Fonduri insuficiente",
                    icon = "fa-solid fa-money-check-dollar",
                    color = "#f01d20",
                    timeout = 3000,
                })
            end

        end
    end
end)

----


-- blocked contacts --


RegisterNetEvent("qb-phone:server:blockContact", function(number)
    local player = source
    local user_id = vRP.getUserId({player})
    if user_id then
        exports.oxmysql:execute("UPDATE phone_blockedContacts SET list = @list WHERE user_id = @user_id",{['@user_id'] = user_id,['@list'] = number})
    end
end)

RegisterNetEvent("qb-phone:server:unblockContact", function(number)
    local player = source 
    local user_id = vRP.getUserId({player})
    if user_id then
        exports.oxmysql:execute("UPDATE phone_blockedContacts SET list = @list WHERE user_id = @user_id",{['@user_id'] = user_id,['@list'] = number})
    end
end)

local function isUserHasBlockedNumber(user_id, number)
    local result = -1
    exports.oxmysql:query("SELECT * FROM phone_blockedContacts WHERE user_id = @user_id AND list = @list",{['@user_id'] = user_id, ['@list'] = number}, function(amm)
        result = amm
    end)
    while result == -1 do
        Citizen.Wait(100)
    end

    return (result == 1)
end

function vRPqb.isContactBlockedMe(number)

    local player = source
    local user_id = vRP.getUserId({player})

    if user_id then
        local myNumber = phoneNumbers[user_id]
        local target_id = phoneOwners[number] or false
        if target_id then
            return isUserHasBlockedNumber(target_id, myNumber)
        else
            exports.oxmysql:query("SELECT * FROM users WHERE phone = @phone",{['@phone'] = number}, function(result)
                target_id = result[1] and result[1].id or 1
            end)
            while not target_id do
                Citizen.Wait(100)
            end

            if target_id == 1 then
                return false
            end

            return isUserHasBlockedNumber(target_id, myNumber)
        end

    end

end

----

-- RoAlert --

exports("addRoAlert", function(msg)
    TriggerClientEvent("vRP:onRoAlert", -1, msg)
end)