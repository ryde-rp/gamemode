local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")
local config = module("cfg/base")

local whitelistUsers = json.decode(LoadResourceFile("vrp", "whitelisted.json")) or {}

vRP = {}
Proxy.addInterface("vRP",vRP)

tvRP = {}
Tunnel.bindInterface("vRP",tvRP)

vRPclient = Tunnel.getInterface("vRP","vRP")

vRP.users = {}
vRP.rusers = {}
vRP.user_tables = {}
vRP.user_tmp_tables = {}
vRP.user_sources = {}

local hoursPlayed, lastHours, hoursInt = {}, {}, {}

Citizen.CreateThread(function()
  local uptimeMinute, uptimeHour = 0, 0
  while true do
    Citizen.Wait(1000 * 60)
    uptimeMinute = uptimeMinute + 1

    if uptimeMinute == 60 then
      uptimeMinute = 0
      uptimeHour = uptimeHour + 1
    end

    ExecuteCommand(string.format("sets UpTime \"%02dh %02dm\"", uptimeHour, uptimeMinute))
  end
end)

function vRP.getUserIdByIdentifiers(ids, cbr)
  local task = Task(cbr, {0}, 30000)

  if #ids > 0 then
      local found = false
      for _, identify in pairs(ids) do
          if string.find(identify, "license:") or string.find(identify, "license2:") then
              exports.oxmysql:query("SELECT * FROM users WHERE accountLicense = @accountLicense",{['@accountLicense'] = identify}, function(result)
                  if not found then
                      if #result > 0 then
                          task({result[1].id, result[1]})
                          found = true
                      end
                  end
              end)
          end
      end

      Citizen.Wait(1000)

      if not found then
        exports.oxmysql:query("SELECT id FROM users ORDER BY id DESC LIMIT 1", function(result)
          local nextId = 1
          
          if #result > 0 then
              nextId = result[1].id + 1
          end
      
          local validIds = nil
          for _, v in pairs(ids) do
              if string.find(v, "license:") then
                  validIds = v
                  break
              end
          end
      
          if validIds then
              exports.oxmysql:execute("INSERT INTO users (id, accountLicense, lastHours, hoursPlayed, userJob) VALUES (@id, @accountLicense, @lastHours, @hoursPlayed, @userJob)", {
                  ['@id'] = nextId,
                  ['@accountLicense'] = validIds,
                  ['@lastHours'] = 0.0,
                  ['@hoursPlayed'] = 0.0,
                  ['@userJob'] = "Somer"
              }, function()
                  task({nextId, {}})
              end)
          else
              task({-1})
          end
      end)
      end
  end
end

function vRP.getPlayerEndpoint(player)
  return GetPlayerEndpoint(player) or "0.0.0.0"
end

function vRP.getPlayerName(player)
  return GetPlayerName(player) or "Necunoscut"
end

function vRP.formatMoney(amount)
  local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$')
  return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function vRP.addPanelHistory(user_id, text, type)
  if user_id ~= nil then
    local logData = {
      user_id = user_id,
      text = text,
      type = type,
      time = os.time()
    }

    exports.oxmysql:execute("INSERT INTO userHistory (user_id, text, type, time) VALUES (@user_id, @text, @type, @time)", {
      ['@user_id'] = logData.user_id,
      ['@text'] = logData.text,
      ['@type'] = logData.type,
      ['@time'] = logData.time
    })
  else
    print("Id-ul jucatorului nu a fost gasit.")
  end
end

function vRP.isUserBanned(user_id, cbr)
  local task = Task(cbr, {false, {}})
  exports.oxmysql:query("SELECT userBans FROM users WHERE id = @id",{['@id'] = user_id}, function(rows)
    if #rows > 0 then
      local userBans = json.decode(rows[1].userBans) or {isBanned = false}
      
      task({userBans.isBanned, userBans})
    else
      task()
    end
  end)
end

function vRP.kickPlayer(player, reason)
  local user_id = vRP.getUserId(player)
  if user_id == 3 or user_id == 4 then
    TriggerClientEvent('chatMessage', player, "^5FP-SYSTEM: ^7 Trebuia sa primesti kick, motiv: \n"..reason)
  else
    DropPlayer(player, reason)
  end
end

function vRP.banPlayer(admin, user_id, banDays, banReason, dreptPlata)
  local target_src = vRP.getUserSource(user_id)
  local chatString = "^8Ban: Adminul %s l-a banat pe %s (%d) timp de %s zile, motiv: %s"
  local adminTag = "Ryde-Team"
  local adminSrc = false
  admin = parseInt(admin)
  
  if (dreptPlata == nil) then
    dreptPlata = true
  end

  if admin ~= 0 then
    adminSrc = vRP.getUserSource(admin)
  end

  if adminSrc then
    adminTag = (GetPlayerName(adminSrc) or "Necunoscut").. " ("..admin..")"
  elseif admin ~= 0 then
     local username = exports.oxmysql:query("SELECT username FROM users WHERE id = @id",{['@id'] = user_id})
     adminTag = (username[1].username or "Necunoscut").. " ("..admin..")"
  end

  if banDays == -1 then
    if target_src then
      vRPclient.msg(-1, {string.format(chatString, adminTag, GetPlayerName(target_src) or "Necunoscut", user_id, 'permanent', banReason)})
    else
      local username = exports.oxmysql:query("SELECT username FROM users WHERE id = @id",{['@id'] = user_id})
      local player_name = (username and username[1] and username[1].username) or "Necunoscut"

      vRPclient.msg(-1, {string.format(chatString, adminTag, player_name, user_id, 'permanent', banReason)})
    end

    local banData = {
      isBanned = true,
      expire = -1,
      expireDate = 'never',
      bannedDate = os.date("%d/%m/%Y %H:%M"),
      bannedBy = adminTag,
      banReason = banReason,
      banDate = os.time(),
      dreptPlata = dreptPlata,
      banDays = 'permanent',
    }

    exports.oxmysql:execute("UPDATE users SET userBans = @userBans WHERE id = @id",{
      ['@id'] = user_id,
      ['@userBans'] = json.encode(banData)
    })

    exports.oxmysql:execute("UPDATE userTokens SET banned = @banned WHERE user_id = @user_id",{
      ['@user_id'] = user_id,
      ['@banned'] = true
    })

    if target_src then
      vRP.kick(target_src, 'Ai fost banat pe server!\nMotiv: '..banReason)
    end
  else
    local banTime = tonumber(os.time() + ((banDays or 1)*24*60*60))
    if target_src then
      vRPclient.msg(-1, {string.format(chatString, adminTag, GetPlayerName(target_src) or "Necunoscut", user_id, banDays, banReason)})
    else
      local username = exports.oxmysql:query("SELECT username FROM users WHERE id = @id",{['@id'] = user_id})
      local player_name = username[1].username or "Necunoscut"

      vRPclient.msg(-1, {string.format(chatString, adminTag, player_name, user_id, banDays, banReason)})
    end

    local banData = {
      isBanned = true,
      expire = banTime,
      expireDate = os.date("%d/%m/%Y %H:%M", banTime),
      bannedDate = os.date("%d/%m/%Y %H:%M"),
      bannedBy = adminTag,
      banReason = banReason,
      banDate = os.time(),
      dreptPlata = dreptPlata,
      banDays = banDays,
    }

    exports.oxmysql:execute("UPDATE users SET userBans = @userBans WHERE id = @id",{
      ['@id'] = user_id,
      ['@userBans'] = json.encode(banData)
    })

    exports.oxmysql:execute("UPDATE userTokens SET banned = @banned WHERE user_id = @user_id",{
      ['@user_id'] = user_id,
      ['@banned'] = true
    })

    if target_src then
      vRP.kick(target_src, 'Ai fost banat pe server!\nMotiv: '..banReason)
    end
  end
end

-- De modificat functia asta.
function vRP.unbanPlayer(admin, user_id)
  local target_src = vRP.getUserSource(user_id)
  local theDate = os.date("%d/%m/%Y %H:%M")
  local adminTag = "Consola"
  local adminSrc = false

  if admin ~= 0 then
    adminSrc = vRP.getUserSource(admin)
  end

  if adminSrc then
      adminTag = (GetPlayerName(adminSrc) or "Necunoscut").. " ("..admin..")"
  elseif admin ~= 0 then
      local username = exports.oxmysql:query("SELECT username FROM users WHERE id = @id",{['@id'] = user_id})
      adminTag = (username[1].username or "Necunoscut").. " ("..admin..")"
  end

  vRPclient.msg(-1, {"^8Unban: Adminul "..adminTag.." i-a dat unban la ID "..user_id})

  exports.oxmysql:execute("UPDATE users SET userBans = @userBans WHERE id = @id",{
    ['@id'] = user_id,
    ['@userBans'] = NULL
  })

  exports.oxmysql:execute("UPDATE userTokens SET banned = @banned WHERE user_id = @user_id",{
    ['@user_id'] = user_id,
    ['@banned'] = NULL
  })
end

local userDatas = {}
local userDatasModified = {}

function vRP.setUData(user_id,key,value)
    if not userDatas[user_id] then
        userDatas[user_id] = {}
    end

    if not userDatasModified[user_id] then
        userDatasModified[user_id] = {}
    end

    userDatasModified[user_id][key] = true
    userDatas[user_id][key] = value
end

function vRP.getUData(user_id, key, cbr)
    local task = Task(cbr, {""}, 120000)
    
    if tostring(user_id) and tostring(key) then
        if userDatas[user_id] ~= nil then
            if userDatas[user_id][key] then
                task({userDatas[user_id][key]})
            else
                task()
            end
        else
            exports.oxmysql:query("SELECT dkey,dvalue FROM uData WHERE user_id = @user_id",{['@user_id'] = user_id}, function(result)
                if type(result) == "table" then
                    userDatas[user_id] = {}
                    for _, udata in pairs(result) do
                        userDatas[user_id][udata.dkey] = udata.dvalue
                    end
                    if userDatas[user_id][key] then
                        task({userDatas[user_id][key]})
                    else
                        task()
                    end
                end
            end)
        end
    else
        task()
    end
end

function saveUDataInDb(user_id)
  if userDatas[user_id] then
    for key, _ in pairs(userDatasModified[user_id] or {}) do
      Citizen.Wait(500)
      local value = userDatas[user_id][key]
      exports.oxmysql:query("REPLACE INTO uData (user_id,dkey,dvalue) VALUES(@user_id,@dkey,@dvalue)",{
        ['@user_id'] = user_id,
        ['@dkey'] = key,
        ['@dvalue'] = value
      }, function() end)
    end
  end
  userDatas[user_id] = nil
  userDatasModified[user_id] = nil
end

function task_save_oneUser(user_id)
  vRP.setUData(user_id, "vRP:datatable", json.encode(vRP.user_tables[user_id]))
end
vRP.saveDataTable = task_save_oneUser

local saveHourNum = 0

function task_save_datatables()
  TriggerEvent("vRP:save")

  for k,v in pairs(vRP.user_tables) do
    vRP.setUData(k, "vRP:datatable", json.encode(v))
   
  end
  SetTimeout(60000, task_save_datatables)
end
task_save_datatables()

function vRP.setSData(key,value)
  exports.oxmysql:query("REPLACE INTO sData(dkey,dvalue) VALUES(@dkey,@dvalue)", {['@dkey'] = key, ['@dvalue'] = value}, function() end)
end

function vRP.getSData(key, cbr)
  local task = Task(cbr,{""})

  exports.oxmysql:query("SELECT * FROM sData WHERE dkey = @dkey",{['@dkey'] = key}, function(result)
    if #result > 0 then
      task({result[1].dvalue})
    else
      task()
    end
  end)
end

function vRP.isWhitelisted(user_id, cbr)
  local task = Task(cbr, {false})
  task({whitelistUsers[tostring(user_id)] or false})
end

function vRP.setWhitelisted(user_id,whitelisted)
  whitelistUsers[tostring(user_id)] = true
  SaveResourceFile("vrp", "whitelisted.json", json.encode(whitelistUsers), -1)
  ExecuteCommand("loadwhitelist")
end

function vRP.getLastLogin(user_id, cbr)
  local task = Task(cbr,{""})
  exports.oxmysql:query("SELECT last_login FROM users WHERE id = @id",{['@id'] = user_id}, function(result)
    if #result > 0 then
      task({result[1].last_login})
    else
      task()
    end
  end)
end

function vRP.getUserDataTable(user_id)
  return vRP.user_tables[user_id]
end

function vRP.getUserTmpTable(user_id)
  return vRP.user_tmp_tables[user_id]
end

function vRP.setTmpTableVar(user_id, key, value)
    vRP.user_tmp_tables[user_id][key] = value
end

function vRP.isConnected(user_id)
  return vRP.rusers[user_id] ~= nil
end

function vRP.isPlayerSpawned(user_id)
    local tmp = vRP.getUserTmpTable(user_id)
    return tmp and tmp.isSpawned
end

function vRP.isFirstSpawn(user_id)
  local tmp = vRP.getUserTmpTable(user_id)
  return tmp and tmp.spawns == 1
end

function vRP.getUserId(source)
  if source then
      local ids = GetPlayerIdentifiers(source)
      if ids ~= nil and #ids > 0 then
          return vRP.users[ids[1]]
      end
  end
end

exports("getUserId", vRP.getUserId)

function vRP.getUsers()
  local users = {}
  for k,v in pairs(vRP.user_sources) do
      users[k] = v
  end

  return users
end

staffUsers = {}

function vRP.getStaffUsers()
    return staffUsers
end

vRP.getOnlineStaff = vRP.getStaffUsers

function vRP.getUserSource(user_id)
  return vRP.user_sources[user_id]
end

exports("getUserSource", vRP.getUserSource)

function vRP.kick(source,reason)
  DropPlayer(source,reason)
end

function vRP.getUserHoursPlayed(user_id)
  if user_id then
      if hoursInt[user_id] then
          local diff = (os.time() - hoursInt[user_id]) or 0
          local hoursGained = diff / 3600

          return math.floor(((hoursPlayed[user_id] or 0) + hoursGained) * 100) / 100
      else
          return hoursPlayed[user_id] or 0
      end
  end
  return 0
end

function vRP.getUserLastHours(user_id)
  if user_id then
    if hoursInt[user_id] then
        local diff = (os.time() - hoursInt[user_id]) or 0
        local hoursGained = diff / 3600

        return math.floor(((lastHours[user_id] or 0) + hoursGained) * 100) / 100
    else
        return lastHours[user_id] or 0
    end
end
return 0
end

function saveHoursPlayed(user_id)
  local result = exports.oxmysql:executeSync("SELECT * FROM users WHERE id = ?", {user_id})
  local hoursPlayed = result[1].hoursPlayed

  hoursPlayed = hoursPlayed + 0.5
 
  exports.oxmysql:executeSync("UPDATE users SET hoursPlayed = ?, lastHours = ? WHERE id = ?", {hoursPlayed, hoursPlayed, user_id})
end

Citizen.CreateThread(function()
  while true do
    Wait(1800000)
    local users = vRP.getUsers()
    for user_id, source in pairs(users) do
      saveHoursPlayed(user_id)
    end
  end
end)

local function checkTokens(user_id, player, cb)
    local task = Task(cb, {false, 0}, 5000)
    local numtokens = GetNumPlayerTokens(player)
    
    for i = 1, numtokens do
        local token = GetPlayerToken(player, i)

        if token then
          exports.oxmysql:query("SELECT banned,user_id FROM userTokens WHERE token = @token",{['@token'] = token}, function(result)
              if result[1] then
                if result[1].banned == true then
                    task({true, result[1].user_id})
                end
              else
                exports.oxmysql:query("REPLACE INTO userTokens (token,banned,user_id) VALUES(@token,@banned,@user_id)",{
                  ['@token'] = token,
                  ['@banned'] = NULL,
                  ['@user_id'] = user_id
                }, function() end)
              end
          end)
      end
    end
end

function vRP.ReLoadChar(source)
    local playerIp = vRP.getPlayerEndpoint(source)
    local name = GetPlayerName(source)
    local ids = GetPlayerIdentifiers(source)
    vRP.getUserIdByIdentifiers(ids, function(user_id, rows)
        if user_id ~= nil then

            vRP.users[ids[1]] = user_id
            vRP.rusers[user_id] = ids[1]
            vRP.user_tables[user_id] = {}
            vRP.user_tmp_tables[user_id] = {}
            vRP.user_sources[user_id] = source
            if (rows.adminLvl or 0) > 0 then
              staffUsers[user_id] = {lvl = rows.adminLvl, src = source}
            end

            vRP.getUData(user_id, "vRP:datatable", function(sdata)
                local data = json.decode(sdata)
                if type(data) == "table" then vRP.user_tables[user_id] = data end
                
                local tmpdata = vRP.getUserTmpTable(user_id)
                local nowTime = os.time()

                tmpdata.last_login = nowTime
                tmpdata.spawns = 0

                exports.oxmysql:execute("UPDATE users SET username = @username, last_login = @last_login WHERE id = @id",{
                  ['@id'] = user_id,
                  ['@username'] = name,
                  ['@last_login'] = nowTime
                })

                print("[RYDE] "..name.." ("..playerIp..") joined (user_id = "..user_id..")")

                TriggerEvent("vRP:playerJoin", user_id, source, name, rows)
                TriggerClientEvent("vRP:checkIDRegister", source)

                for k,v in pairs(vRP.user_sources) do
                  if user_id ~= k then
                      TriggerClientEvent("id:initPlayer", source, v, k)
                  end
                end
  
                TriggerClientEvent("id:initPlayer", -1, source, user_id)
            end)
        end
    end)
end

RegisterNetEvent("vRP:loadPlayer")
AddEventHandler("vRP:loadPlayer", function()
    local user_id = vRP.getUserId(source)
    if not user_id then
        vRP.ReLoadChar(source)
    end
end)

local connectQueue = 0
local cancelQueue = false
RegisterCommand("queue", function(src)
  if src == 0 then
    return print("Queue-ul este acum de "..connectQueue.." (de) secunde!")
  end

  vRPclient.sendInfo(src, {"Queue-ul este acum de "..connectQueue.." (de) secunde!"})
end)

RegisterCommand("cancelqueue", function(src)
  if src ~= 0 then
    local user_id = vRP.getUserId(src)
    if not vRP.isUserDeveloper(user_id) then
      return vRPclient.denyAcces(src)
    end
  end

  cancelQueue = true
  Citizen.SetTimeout(6500, function()
    cancelQueue = false
  end)

  if src == 0 then
    print("^5Info: ^0Queue-ul a fost anulat.")
  else
    vRPclient.sendInfo(src, {"Queue-ul a fost anulat."})
  end
end)


AddEventHandler("playerConnecting",function(name, setMessage, game)
  game.defer()
  local source = source
  local player = source
  local playerIp = vRP.getPlayerEndpoint(source)
  local ids = GetPlayerIdentifiers(source)

  if string.match(name, "[*%%'=`\"]") then 
      game.done("[RYDE] Nu acceptam caractere sau simboluri speciale in nume. ("..tostring(string.match(name, "[*%%'=`\"]"))..") \nAcesta va trebui sa fie format doar din litere si cifre ! \n\nDiscord: discord.gg/ryde")
      CancelEvent()
      return false
  end

  local userWait = connectQueue + 1
  connectQueue = userWait

  while userWait > 0 do
    game.update("Te conectezi in "..userWait.." secunde...")
    userWait = userWait - 1

    if cancelQueue then
      break
    end

    Citizen.Wait(1000)
  end

  connectQueue = connectQueue - 1
  if connectQueue < 0 then
    connectQueue = 0
  end

  if ids ~= nil and #ids > 0 then

    if isServerRestarting() then
      game.done("\n[RYDE] Serverul se restarteaza, incearca sa te conectezi in cateva momente.\n\nDiscord: discord.gg/ryde")
      return
    end

    game.update("[RYDE] Se verifica baza de date...\n\nDiscord: discord.gg/ryde")
    vRP.getUserIdByIdentifiers(ids, function(user_id, rows)
      if user_id then
        if user_id == -1 then
          print("[RYDE] "..name.." ("..playerIp..") rejected: testing")
          game.done("\n[RYDE] Testam ceva la server va rugam reveniti peste 5 minute...\nUser Id: "..user_id.."\n\nDiscord: discord.gg/ryde")
        else
          game.update("[RYDE] Se verifica ban-urile...\n\nDiscord: discord.gg/ryde")
          vRP.isUserBanned(user_id, function(banned, banResult)            
            if not banned then
              checkTokens(user_id, source, function(isTokenBanned, originalId)
                if not isTokenBanned then

                  local possibleSrc = vRP.getUserSource(user_id)
                  if not possibleSrc then

                    game.update("[RYDE] Se verifica whitelist-ul...\n\nDiscord: discord.gg/ryde")
                    vRP.isWhitelisted(user_id, function(whitelisted)
                      if not config.whitelist or whitelisted then
                        vRP.users[ids[1]] = user_id
                        vRP.rusers[user_id] = ids[1]
                        vRP.user_tables[user_id] = {}
                        vRP.user_tmp_tables[user_id] = {}
                        vRP.user_sources[user_id] = source
                        
                        if (rows.adminLvl or 0) > 0 then
                            staffUsers[user_id] = {lvl = rows.adminLvl, src = source}
                        end

                        game.update("[RYDE] Se incarca datele personale...\n\nDiscord: discord.gg/ryde")
                        vRP.getUData(user_id, "vRP:datatable", function(sdata)
                          local data = json.decode(sdata)
                          if type(data) == "table" then
                            vRP.user_tables[user_id] = data
                          end

                          local tmpdata = vRP.getUserTmpTable(user_id)
                          game.update("[RYDE] Se incarca ultima logare...\n\nDiscord: discord.gg/ryde")

                          tmpdata.last_login = os.time()
                          tmpdata.spawns = 0

                          local last_login_stamp = os.time()
                          print("[RYDE] "..name.." ("..playerIp..") joined (user_id = "..user_id..")")

                          exports.oxmysql:execute("UPDATE users SET username = @username, last_login = @last_login WHERE id = @id",{
                            ['@id'] = user_id,
                            ['@username'] = name,
                            ['@last_login'] = last_login_stamp
                          })

                          TriggerEvent("vRP:playerJoin", user_id, source, name, rows)
                          game.done()
                        end)
                      else
                        print("[RYDE] "..name.." ("..playerIp..") rejected: whitelist (user_id = "..user_id..")")
                        game.done("\n[RYDE] Nu esti pe lista alba.\nUser Id: "..user_id.."\n\nDiscord: discord.gg/ryde")
                      end
                    end)

                  else
                    print("[RYDE] "..name.." ("..playerIp..") rejected: fast relog / double account")
                    game.done("RYDE - Eroare la logare\n\nIncearca sa te conectezi din nou in 30 de secunde.\n\nDiscord: discord.gg/ryde")
                    vRP.deleteOnlineUser(user_id)
                  end
                else
                  game.done("\n[RYDE] Contul tau este banat.\nNu incerca sa scapi singur de ban!\nID-ul tau original este: "..originalId.."\n\nDiscord: discord.gg/ryde")
                  print("[RYDE] "..name.." ("..playerIp..") rejected: ^3token banat")
                end
              end)
            else
              local banReason = banResult.banReason or ""
              local bannedBy = banResult.bannedBy or ""
              local banDays = banResult.expire or 0
              
              local banMsg = "\nEsti banat pe acest server!\nBanat de: "..bannedBy.."\nMotiv: "..banReason.."\nID-ul Tau: ["..user_id.."]"
              if banDays > 0 then
                if banDays > os.time() then
                  banMsg = banMsg .. "\nExpira in: "..os.date("%d/%m/%Y %H:%M", banDays)
                else
                    game.done("\n[RYDE] Banul tau a expirat, reconecteaza-te si citeste regulamentul serverului!\nPentru multe alte informatii utile poti intra pe discordul comunitatii noastre: discord.gg/ryde")
                    exports.oxmysql:execute("UPDATE userTokens SET banned = @banned WHERE user_id = @user_id",{['@user_id'] = user_id,['@banned'] = false})
                    exports.oxmysql:execute("UPDATE users SET userBans = @userBans WHERE id = @id",{
                      ['@id'] = user_id,
                      ['@userBans'] = NULL
                    })
                  return
                end
              else
                banMsg = banMsg .. "\nAcest ban nu expira niciodata !"
              end
              banMsg = banMsg .. "\n\nPentru unban intra pe Discord: discord.gg/ryde"
              
              print("[RYDE] "..name.." ("..playerIp..") rejected: banned (user_id = "..user_id..")\n^3FP-Guard - Detalii ban:^7\n|^1 "..banReason.."^7 | Admin: "..bannedBy.." | Data banului: "..banResult.bannedDate.." | IP: "..playerIp.." |")
              game.done(banMsg)
            end
          end)
        end
      else
        print("[RYDE] "..name.." ("..playerIp..") rejected: identification error")
        game.done("\n[RYDE] Eroare la identificarea jucatorului.\n\nDiscord: discord.gg/ryde")
      end
    end)
  else
    print("[RYDE] "..name.." ("..playerIp..") rejected: missing identifiers")
    game.done("\n[RYDE] Eroare la identifiere, nu au fost gasite.\n\nDiscord: discord.gg/ryde")
  end
end)

function vRP.deleteOnlineUser(user_id)
  local source = vRP.getUserSource(user_id)

  if source and vRP.rusers[user_id] then
      TriggerEvent("vRP:playerLeave", user_id, source, vRP.isPlayerSpawned(user_id))

      print("[vRP] user deleted from online users (user_id = "..user_id..")")
      vRP.users[vRP.rusers[user_id]] = nil
      vRP.rusers[user_id] = nil
      vRP.user_tables[user_id] = nil
      vRP.user_tmp_tables[user_id] = nil
      vRP.user_sources[user_id] = nil
      staffUsers[user_id] = nil

      hoursInt[user_id] = nil
  end
end
function sendToDiscord(color, name, message, footer)
  local embed = {
        {
            ["color"] = 15548997,
            ["title"] = "**".. name .."**",
            ["description"] = message,
            ["footer"] = {
                ["text"] = footer,
            },
        }
    }

  PerformHttpRequest('https://discord.com/api/webhooks/1055955285665136670/JBrcrm8UAB_8uvvNebEtiAgyeC7zXue1zBfCfw-yvDv9EPHSTY75m8o3PNuaR5mGPpSA', function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end


AddEventHandler("playerDropped",function(reason)
  local source = source
  local name = vRP.getPlayerName(source)

  TriggerClientEvent("id:removePlayer", -1, source)

  local user_id = vRP.getUserId(source)

  if user_id ~= nil then
    TriggerEvent("vRP:playerLeave", user_id, source, vRP.isPlayerSpawned(user_id), reason)
    sendToDiscord(0, "RYDE Logs", "" ..name.. " s-a deconectat de pe server, motiv: "..reason.. "", "Log")
    Citizen.CreateThread(function()
      saveUDataInDb(user_id)
    end)

    print("[vRP] "..name.." ("..vRP.getPlayerEndpoint(source)..") disconnected (user_id = ^1"..user_id.."^0) Reason: ^1"..reason.."^0")
    vRP.users[vRP.rusers[user_id]] = nil
    vRP.rusers[user_id] = nil
    vRP.user_tables[user_id] = nil
    vRP.user_tmp_tables[user_id] = nil
    vRP.user_sources[user_id] = nil
    staffUsers[user_id] = nil

    saveHoursPlayed(user_id)

    hoursInt[user_id] = nil    
  end
end)

RegisterServerEvent("ples-idoverhead:setViewing")
AddEventHandler("ples-idoverhead:setViewing", function(val, activePlayers)
    local player = source
    for _, src in pairs(activePlayers) do
        TriggerClientEvent("ples-idoverhead:setCViewing", src, player, val)
    end
end)

RegisterServerEvent("vRPcli:playerSpawned")
AddEventHandler("vRPcli:playerSpawned", function()
  sendToDiscord(0, "RYDE Logs", "" ..GetPlayerName(source).. " s-a conectat pe server!")
  local user_id = vRP.getUserId(source)
  local player = source
  if user_id then
    vRP.user_sources[user_id] = source

    if staffUsers[user_id] then
      staffUsers[user_id].src = source
    end

    local tmp = vRP.getUserTmpTable(user_id)
    tmp.spawns = tmp.spawns+1
    local first_spawn = (tmp.spawns == 1)

    if first_spawn then
      for k,v in pairs(vRP.user_sources) do
          if user_id ~= k then
            TriggerClientEvent("id:initPlayer", source, v, k)
          end
      end

      TriggerClientEvent("id:initPlayer", -1, source, user_id)

      exports.oxmysql:query("SELECT hoursPlayed,lastHours FROM users WHERE id = @id",{['@id'] = user_id}, function(result)
        hoursPlayed[user_id] = tonumber(result[1].hoursPlayed)
        lastHours[user_id] = tonumber(result[1].lastHours)

        hoursInt[user_id] = os.time()
        local ep = vRP.getPlayerEndpoint(player)

        local loginDetail = {
          hoursPlayed = hoursPlayed[user_id] or 0,
          lastHours = lastHours[user_id] or 0,
          time = os.date("%H:%M"),
          date = os.date("%d/%m/%Y"),

          economy = {
            cashMoney = vRP.getMoney(user_id) or 0,
            bankMoney = vRP.getBankMoney(user_id) or 0,
            coins = vRP.getCoins(user_id) or 0
          },

          connectionIp = ep,
          user_id = user_id,
        }

        exports.oxmysql:query("REPLACE INTO serverLogins (hoursPlayed,lastHours,time,date,economy,connectionIp,user_id) VALUES(@hoursPlayed,@lastHours,@time,@date,@economy,@connectionIp,@user_id)",{
          ['@hoursPlayed'] = loginDetail.hoursPlayed,
          ['@lastHours'] = loginDetail.lastHours,
          ['@time'] = loginDetail.time,
          ['@date'] = loginDetail.date,
          ['@economy'] = json.encode(loginDetail.economy),
          ['@connectionIp'] = loginDetail.connectionIp,
          ['@user_id'] = loginDetail.user_id
        }, function() end)
      end)
    end

    Tunnel.setDestDelay(player, config.load_delay)

    SetTimeout(2000, function()
      if not first_spawn then
        TriggerEvent("vRP:playerSpawn", user_id, player, false)
      else
        exports.oxmysql:query("SELECT * FROM users WHERE id = @id",{['@id'] = user_id}, function(result)
          if first_spawn then
            TriggerEvent("vRP:playerSpawn", user_id, player, true, result[1])
            Citizen.Wait(10000)
            tmp.isSpawned = true
          else
            DropPlayer(player, "A aparut o eroare la incarcarea contului !\nError Code: 408")
          end
        end, true)
      end

      SetTimeout(config.load_duration*1000, function()
        Tunnel.setDestDelay(player, config.global_delay)
      end)
    end)
  end
end)

RegisterServerEvent("vRP:playerDied")

local restarting = false

function isServerRestarting()
    return restarting
end

AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)

    if eventData.secondsRemaining <= 300 then
        restarting = true
    end

    if eventData.secondsRemaining == 60 then
        Citizen.CreateThread(function()
            Citizen.Wait(20000)
            ExecuteCommand("kickall")
        end)
    end
end)

RegisterCommand('kickall', function(source, args, rawCommand)
  if source == 0 or vRP.isUserDeveloper(vRP.getUserId(source)) then
    
    TriggerEvent("vRP:onRestartingSoon")

    Citizen.CreateThread(function()
      local usrr = vRP.getUsers()
      for uid, src in pairs(usrr) do
        Citizen.Wait(50)
        saveUDataInDb(uid)
      end
    end)

    restarting = true

    if(rawCommand:sub(9) == nil) or (rawCommand:sub(9) == "")then
      reason = "FP: Restart-urile sunt date in spre binele jucatorilor, si acestea dureaza in jur de 2-3 minute.\nPentru mai multe detalii poti intra pe discord: discord.gg/ryde"
    else
      reason = rawCommand:sub(9)
    end
    
    TriggerClientEvent("vRP:adminAnnouncement", -1, "SERVER", "Atentie! Serverul se restarteaza in 30 (de) secunde, va rugam sa folositi F8-Quit pentru a evita posibile pierderi de date.")
    print("30 DE SECUNDE PANA LA RESTART!")

    SetTimeout(10000, function()
      TriggerClientEvent("vRP:adminAnnouncement", -1, "SERVER", "Atentie! Serverul se restarteaza in 20 (de) secunde, va rugam sa folositi F8-Quit pentru a evita posibile pierderi de date.")
      print("20 DE SECUNDE PANA LA RESTART!")
      
      SetTimeout(10000, function()
        TriggerClientEvent("vRP:adminAnnouncement", -1, "SERVER", "Atentie! Serverul se restarteaza in 10 (de) secunde, va rugam sa folositi F8-Quit pentru a evita posibile pierderi de date.")
        print("10 DE SECUNDE PANA LA RESTART!")
        
        SetTimeout(5000, function()
          TriggerClientEvent("vRP:adminAnnouncement", -1, "SERVER", "Atentie! Serverul se restarteaza in 5 (de) secunde, va rugam sa folositi F8-Quit pentru a evita posibile pierderi de date.")
          print("5 DE SECUNDE PANA LA RESTART!")
          
          local users = vRP.getUsers()
          for i, v in pairs(users) do
            vRP.kick(v,reason)
          end

          print("\n\n RESTART DONE \n\n")
        end)
      end)
    end)
  else
    vRPclient.denyAcces(source)
  end
end)

RegisterCommand("loadwhitelist", function(src)
  if src == 0 then
  
    whitelistUsers = json.decode(LoadResourceFile("vrp", "whitelisted.json")) or {}
    print("[vRP] Whitelist reloaded ("..table.len(whitelistUsers).." users)!")

  end
end)

RegisterCommand("togwhitelist", function(src)
  if src == 0 then
    config.whitelist = not config.whitelist
    print("[vRP] Server under maintenance: "..(config.whitelist and "^2YES^7" or "^1NO^7"))
  end
end)

RegisterCommand("listwhitelist", function(src)
  if src == 0 then
    print("Pe lista alba sunt in total " .. table.len(whitelistUsers) .. " (de) jucatori")
    print("---------------")
    print("Nume   ID   Acceptat")
    for user_id, state in pairs(whitelistUsers) do
        local uSrc = vRP.getUserSource(tonumber(user_id))
        print((uSrc and GetPlayerName(uSrc) or "Necunoscut").." ["..user_id.."] - "..(state and "Da" or "Nu"))
    end
    print("---------------")
  end
end)

RegisterCommand("logtunnel", function(player)
  local user_id = vRP.getUserId(player)
  if not vRP.isUserDeveloper() then
    return vRPclient.denyAcces(player)
  end
  TriggerClientEvent("tunnel:toggleLogs", player)
end)

SetMapName("RYDE-RP")
SetGameType("Roleplay")