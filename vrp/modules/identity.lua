local htmlEntities = module("lib/htmlEntities")
local defaultPicture = "https://i.imgur.com/ylKcHww.png";

local tempIdentities = {}
local usersByPhone = {}
local ibanHolders = {}

local characters = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","R","S","T","U","V","W","X","Y","Z"}
local phoneFormat = "DDD-DDDD"

function vRP.getUserIdentity(user_id, cbr)
  local task = Task(cbr, { {firstname = "Nume", name = "Prenume", age = 18, phone = 0, iban = 0, sex = "M", carPlate = "LS 69FRP", photo = defaultPicture, phoneBackground = "default-QBCore"} })

  if tempIdentities[user_id] then
    task({ tempIdentities[user_id] })
  else
    task()
  end
end

function vRP.getIdentities()
  return tempIdentities
end

function vRP.getIdentity(user_id)
  if tempIdentities[user_id] then
    return tempIdentities[user_id]
  end

  return {firstname = "Nume", name = "Prenume"}
end

function vRP.getUserPhone(user_id)
  if tempIdentities[user_id] and (tempIdentities[user_id].phone ~= 0) then
    return tempIdentities[user_id].phone
  end
end

function vRP.getUserIban(user_id)
  if tempIdentities[user_id] and (tempIdentities[user_id].iban ~= 0) then
    return tempIdentities[user_id].iban
  end
end

function vRP.getUserPlate(user_id)
  if tempIdentities[user_id] and (tempIdentities[user_id].carPlate ~= 0) then
    return tempIdentities[user_id].carPlate
  end
end

function vRP.getPlayerByPhone(phoneNumber)
  local thePlayer = usersByPhone[phoneNumber]
  if thePlayer then
    return thePlayer
  end
end

function vRP.getUserByIban(iban)
  local thePlayer = ibanHolders[iban]
  if thePlayer then
    return thePlayer
  end
end

vRP.getUserByPhone = vRP.getPlayerByPhone

function vRP.getUserPhoneBackground(user_id)
  if tempIdentities[user_id] then
    return tostring(tempIdentities[user_id].phoneBackground)
  end

  return "default-QBCore"
end

function vRP.generatePlateNumber()
  local plate = "LS "

  for i=1, 2 do
    plate = plate..math.random(1, 9)
  end

  for i=1, 3 do
    plate = plate..characters[math.random(1, #characters)]
  end

  return plate
end

function vRP.generateIbanNumber()
  return "FP"..vRP.generateStringNumber("DDDDD")
end

function vRP.GetIdentifierByCarNumber(car_number, cbr)
  local task = Task(cbr, {0}, 2000)
  local user_id = vRP.getUserId(source)

  exports.oxmysql:query("SELECT * FROM userVehicles WHERE carPlate = @carPlate",{['@carPlate'] = car_number}, function(result)
    task({result})
  end)
end


function vRP.setPlateNumber(user_id, newPlate)
  exports.oxmysql:execute("UPDATE users SET carPlate = @carPlate WHERE id = @id",{
    ['@id'] = user_id,
    ['@carPlate'] = newPlate
  })

  if tempIdentities[user_id] then
    tempIdentities[user_id].carPlate = newPlate
  end
end

function vRP.generateStringNumber(format) -- (ex: DDDLLL, D => digit, L => letter)
  local abyte = string.byte("A")
  local zbyte = string.byte("0")

  local number = ""
  for i=1,#format do
    local char = string.sub(format, i,i)
    if char == "D" then number = number..string.char(zbyte+math.random(0,9))
    elseif char == "L" then number = number..string.char(abyte+math.random(0,25))
    else number = number..char end
  end

  return number
end

-- cbreturn a unique registration number
function vRP.generateRegistrationNumber(cbr)
  local task = Task(cbr)

  local function search()
    -- generate registration number
    local registration = vRP.generateStringNumber(phoneFormat)
    vRP.getUserByRegistration(registration, function(user_id)
      if user_id ~= nil then
        search() -- continue generation
      else
        task({registration})
      end
    end)
  end

  search()
end

-- cbreturn a unique phone number (0DDDDD, D => digit)
function vRP.generatePhoneNumber(cbr)
  local task = Task(cbr)

  local function search()
    -- generate phone number
    local phone = vRP.generateStringNumber(phoneFormat)
    local user_id = vRP.getUserByPhone(phone)

    if user_id ~= nil then
      search() -- continue generation
    else
      task({phone})
    end
  end

  search()
end

function vRP.setPhoneNumber(user_id, number)
  exports.oxmysql:execute("UPDATE users SET phone = @phone WHERE id = @id",{
    ['@id'] = user_id,
    ['@phone'] = number
  })

  if tempIdentities[user_id] then
    tempIdentities[user_id].phone = number
  end

end

function checkName(theText)
  local foundSpace, valid = false, true
  local spaceBefore = false
  local current = ''

  for i = 1, #theText do
    local char = theText:sub( i, i )
    if char == ' ' then
      if i == #theText or i == 1 or spaceBefore then 
        valid = false
        break
      end
      current = ''
      spaceBefore = true
    elseif ( char >= 'a' and char <= 'z' ) or ( char >= 'A' and char <= 'Z' ) then 
      current = current .. char
      spaceBefore = false
    else 
      valid = false
      break
    end
  end
  
  if valid then
    return true
  end

  return false
end

local function getIdentifierByPhoneNumber(phone_number, cbr) 
  local task = Task(cbr, {0}, 2000)
  local user_id = vRP.getUserId(source)

  exports.oxmysql:query("SELECT * FROM users WHERE phone = @phone",{['@phone'] = phone_number}, function(result)
    task({result})
  end)
end

local function getIdentifierByIban(iban_number, cbr)
  local task = Task(cbr, {0}, 2000)
  local user_id = vRP.getUserId(source)

  exports.oxmysql:query("SELECT * FROM users WHERE iban = @iban",{['@iban'] = iban_number}, function(result)
    task({result})
  end)
end

RegisterServerEvent("fp-identity:createCharacter", function(cData)
  local user_id = vRP.getUserId(source)
  local player = source

  local firstname = cData.firstname
  local name = cData.name
  local age = cData.age
  local sex = cData.sex:upper()

  local myPhoneNumber = 0
  local function searchOne()
    myPhoneNumber = vRP.generateStringNumber(phoneFormat)

    getIdentifierByPhoneNumber(myPhoneNumber, function(hasPhone)
      if not hasPhone or hasPhone ~= 0 then
        searchOne()
      end
    end)
  end
  searchOne()

  local iban = "FP12345"
  local function searchOne()
    iban = vRP.generateIbanNumber()

    getIdentifierByIban(iban, function(oneIban)
      if not oneIban or oneIban ~= 0 then
        searchOne()
      end
    end)
  end
  searchOne()

  exports.oxmysql:execute("UPDATE users SET userIdentity = @userIdentity, firstName = @firstName, secondName = @secondName, age = @age, sex = @sex, phone = @phone, profilePhoto = @profilePhoto, phoneBackground = @phoneBackground, iban = @iban WHERE id = @id",{
    ['@id'] = user_id,
    ['@userIdentity'] = 1,
    ['@firstName'] = firstname,
    ['@secondName'] = name,
    ['@age'] = age,
    ['@sex'] = sex,
    ['@phone'] = myPhoneNumber,
    ['@profilePhoto'] = defaultPicture,
    ['@phoneBackground'] = "default-QBCore",
    ['@iban'] = iban
  }, function()
    tempIdentities[user_id] = {firstname = firstname, name = name, age = age, sex = sex, phone = myPhoneNumber, iban = iban, carPlate = carPlate, photo = defaultPicture, phoneBackground = "default-QBCore"}

    TriggerEvent("fp-clothing:requestSkin", user_id)
    ibanHolders[iban] = player
    usersByPhone[myPhoneNumber] = player
  end)
end)

local function ch_identity(source)
  local user_id = vRP.getUserId(source)

  TriggerClientEvent("fp-identity:createCharacter", source)
end

AddEventHandler("vRP:playerLeave", function(user_id)
  local identity = tempIdentities[user_id]

  if identity and (identity.phone ~= 0) then
    usersByPhone[identity.phone] = nil
    ibanHolders[identity.iban] = nil
  end
end)

AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
  if first_spawn then
    local rows = exports.oxmysql:querySync("SELECT firstName,secondName,age,phone,iban,sex,profilePhoto,phoneBackground FROM users WHERE id = @id", {['@id'] = user_id})
    if #rows > 0 then
      tempIdentities[user_id] = {
        firstname = rows[1].firstName or "Nume",
        name = rows[1].secondName or "Prenume",
        age = rows[1].age or 18,
        phone = rows[1].phone or "0",
        iban = rows[1].iban or "0",
        sex = rows[1].sex or "M",
        photo = rows[1].profilePhoto or defaultPicture,
        phoneBackground = rows[1].phoneBackground or "default-QBCore",
      }
    else
      tempIdentities[user_id] = {firstname = "Nume", name = "Prenume", age = 18, phone = "0", iban = "0", sex = "M", profilePhoto = defaultPicture, phoneBackground = "default-QBCore"}
    end

    local thePhone = tempIdentities[user_id].phone
    local theIban = tempIdentities[user_id].iban
    if (thePhone or 0) ~= 0 and (theIban or 0) ~= 0 then
      usersByPhone[thePhone] = source
      ibanHolders[theIban] = source
    end
  end

  Citizen.Wait(2000)
  vRP.getUserIdentity(user_id, function(identity)
    if identity then
      if identity.firstname == "Nume" then
        ch_identity(source)
      end
    else
      ch_identity(source)
    end
  end)

  local uTable = vRP.getUserDataTable(user_id) or {}
  if not uTable.inventory then
    vRP.giveInventoryItem(user_id, "buletin", 1)
  else
    uTable.inventory["buletin"] = {
      amount = 1,
    }
  end
end)

RegisterCommand("resetidentity", function(source, args)
  local user_id = vRP.getUserId(source)

  if not vRP.isUserAdministrator(user_id) then
    return vRPclient.denyAcces(source, {})
  end

  local target = tonumber(args[1])
  if not target then
    return vRPclient.cmdUse(source, {"/resetidentity <user_id>"})
  end

  exports.oxmysql:execute("UPDATE users SET userIdentity = @userIdentity WHERE id = @id",{
    ['@id'] = target,
    ['@userIdentity'] = 0
  })

  local targetSrc = vRP.getUserSource(target)
  if targetSrc then
    vRPclient.notify(targetSrc, {GetPlayerName(source).." ti-a resetat identitatea!", "warning", false, "far fa-id-card"})
    vRPclient.sendInfo(source, {"I-ai resetat identitatea jucatorului "..GetPlayerName(targetSrc).." ["..target.."]"})

    Citizen.Wait(2500)
    ch_identity(targetSrc)
  else
    vRPclient.sendInfo(source, {"I-ai resetat identitatea jucatorului cu ID "..target.."!"})
  end
end)