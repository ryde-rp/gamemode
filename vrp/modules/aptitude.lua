local aptitudes = module("cfg/aptitude")
local userAptitudes = {}

AddEventHandler("vRP:playerJoin", function(user_id, player, name)
  local rows = exports.oxmysql:querySync("SELECT * FROM users WHERE id = ?",{user_id})
  if #rows > 0 then
    userAptitudes[user_id] = json.decode(rows[1].userAptitudes) or {}
  end
end)

AddEventHandler("vRP:playerLeave", function(user_id)
  if userAptitudes[user_id] then
    exports.oxmysql:execute("UPDATE users SET userAptitudes = @userAptitudes WHERE id = @id",{
      ['@id'] = user_id,
      ['@userAptitudes'] = json.encode(userAptitudes[user_id])
    })
  end
end)

function vRP.getUserAptitude(user_id, apt)
  local uApts = json.decode(userAptitudes[user_id])
  if uApts[apt] then
    
    local aptLvl = tonumber(uApts[apt])
    local maxLvl = aptitudes[apt].max

    if maxLvl and aptLvl > maxLvl then
      return tonumber(maxLvl)
    end

    return aptLvl
  else
    local aptLvl = aptitudes[apt].default
    return aptLvl or 0
  end
end

function vRP.setUserAptitude(user_id, akey, avalue)
  userAptitudes[tonumber(user_id)][akey] = avalue
end

function vRP.varyAptitude(user_id, akey, added)  
  local theAptitudes = json.decode(userAptitudes[user_id])
  if theAptitudes then
    if not theAptitudes[akey] then
      local fakeLvl = (aptitudes[akey].default or 0) + added
      
      userAptitudes[user_id][akey] = fakeLvl
      return fakeLvl
    end

    local newLevel = theAptitudes[akey] + added
    userAptitudes[user_id][akey] = newLevel
    return newLevel
  end
end

function vRP.canIncreaseAptitude(aptitude, currentLevel, addingLevel)
  local max = 15
  if aptitudes[aptitude] then
    max = aptitudes[aptitude].max
  end
  
  local canIncrease = false

  if not max then
    canIncrease = true
  elseif max > (currentLevel + addingLevel) then
    canIncrease = true
  end

  return canIncrease
end