---@diagnostic disable: undefined-global
do return (function ()
    
  local Tunnel  = module("vrp", "lib/Tunnel"); local Proxy  = module("vrp", "lib/Proxy")

  local vRPclient , vRP, remoteSlots, clientRemoteSlots  = Tunnel.getInterface('vRP', 'vRP'), Proxy.getInterface[[vRP]], {} , Tunnel.getInterface('rydeSlots','rydeSlots')

  local WIN_SPRITES <const> = { ['cherry'] = { [3] = 5, [4] = 35, [5] = 70   }, ['plum'] = { [3] = 5, [4] = 35, [5] = 70   },  ['lemon'] = { [3] = 5, [4] = 35, [5] = 70   }, ['seven'] = { [3] = 10, [4] = 100, [5] = 500 }, ['grapes'] = { [3] = 5, [4] = 20, [5] = 100 }, ['orange'] = { [3] = 3, [4] = 10, [5] = 50 }, ['watermelon'] = { [3] = 10, [4] = 50, [5] = 100 } }


  local function getMultiplierFromPattern(pattern,amount)
     return WIN_SPRITES[pattern][amount]
  end

  local function getSpritesFromPositions(slotsMatrix, positions )
    local length = #positions
    local sprites = {}

    for i = 1, length do 
        sprites[#sprites+1] = { idx = positions[i], sprite = slotsMatrix[positions[i]].instance.sprite }
    end

    return sprites
  end

  local function areSlotsTheSame(slotsMatrix, check  )

   
      local same = true
      for i = 1, #check - 1 do
        
        if slotsMatrix[check[i]].instance.sprite ~= slotsMatrix[check[i+1]].instance.sprite then 
          same = false
        end
      end
      return same
  end

  local function getWinningPatterns(slotsMatrix, idxs )

        local winningPaterns = {}

        for i = 1, #idxs do
          local position = idxs[i] 
            local same = areSlotsTheSame(slotsMatrix, position )
            if same then   
                table.insert(winningPaterns, { getSpritesFromPositions(slotsMatrix,position)}  )
            end
        end

        if #winningPaterns == 0 then return nil end

        local max = { number = 0 , patternMatrix = { } }

        for _, pattern in pairs(winningPaterns) do 

            local mult = getMultiplierFromPattern(pattern[1][1].sprite,#pattern[1])
        
            if mult > max.number then max.number = mult; max.patternMatrix = pattern end
        end

        return max

  end

  local activeRollers = {}

  local UserPots = {}

  local function randomASCII(length)
    local res = {}
    for i = 1, length do
      table.insert(res,string.char(math.random(97, 122)))
    end
    return res
  end

  function remoteSlots.startRolling()
      local user_id = vRP.getUserId{source}
      if not vRP.tryFullPayment{user_id, tonumber(UserPots[user_id].pot)} then return vRPclient.notify(source,{'~r~Nu ai destui bani!'}) end 
        
      local rollId = table.concat(randomASCII(16)) .. ':' .. tostring(user_id)

      activeRollers[user_id] = rollId
      return rollId

  end


  function remoteSlots.removeMoney(money)
    local user_id = vRP.getUserId{source}
    money = tonumber(money) 
    if money < 0 then return DropPlayer(source,SlotsConfig.hackerDropText) end

    vRP.tryFullPayment{user_id,money}

  end

  function remoteSlots.cashOut(rollId,money)
    local user_id = vRP.getUserId{source}
    money = tonumber(money) 
    if money < 0 then return DropPlayer(source,SlotsConfig.hackerDropText) end
    local pattern = ":(.*)"
    if activeRollers[user_id] ~= rollId or tostring(user_id) ~= ( rollId:match(pattern) or '' ) then return DropPlayer(source,SlotsConfig.hackerDropText) end


    vRP.sendToDis{
      vRP.getGlobalStateLogs{}['Inventory']['Pacanele'],
      'Ryde Slots',
      ''..user_id..' a castigat '..money..'$ la pacanele'
    }

    vRP.giveMoney{user_id,money}

  end

  local toGive = false
  function remoteSlots.finishRoll(id,slotsMatrix,pot)
      local user_id = vRP.getUserId{source}
      local pattern = ":(.*)"

      if tonumber(UserPots[user_id].pot) ~= tonumber(pot) then return end 

      local player = source

      if not slotsMatrix or type(slotsMatrix) ~= 'table' or slotsMatrix[1].data.guard ~= '0x559b828c4d80' then return DropPlayer(source,SlotsConfig.hackerDropText) end
      if activeRollers[user_id] ~= id or tostring(user_id) ~= ( id:match(pattern) or '' ) then return DropPlayer(source,SlotsConfig.hackerDropText) end
      
      local max = 0 
      local winningPatterns = getWinningPatterns(slotsMatrix,SlotsConfig.WinPatterns)
          if winningPatterns then 
              if winningPatterns.number > max then max = winningPatterns.number end 
          end

      if max == 0 then
       
        clientRemoteSlots.setBottomText(player, { '~w~ai pierdut:~r~ ' .. FormatMoney(tonumber(pot))})
        toGive = true
        Citizen.SetTimeout(2500,function()
          toGive = false
        end)
        return false,pot
       end 

      clientRemoteSlots.highlightWinningMatrix(player, { slotsMatrix,winningPatterns.patternMatrix })

      if not toGive then
        local mmonneyy = tonumber(pot*max)
        vRP.sendToDis{
          vRP.getGlobalStateLogs{}['Inventory']['Pacanele'],
          'Ryde Slots',
          ''..user_id..' a castigat '..mmonneyy..'$ la pacanele'
        }

        vRP.giveMoney{user_id, mmonneyy}
      end

      
      return true,pot*max
  end

  remoteSlots.setPot = function(pot)
    pot = tonumber(pot)
    if pot > SlotsConfig.minMaxPot.max or pot < SlotsConfig.minMaxPot.min then return DropPlayer(source,SlotsConfig.hackerDropText) end 
    
    local user_id = vRP.getUserId{source}

    UserPots[user_id] = UserPots[user_id] or {}
    local t = UserPots[user_id]; t.pot = pot
  end; remoteSlots.getPot = function() 
    local user_id = vRP.getUserId{source}
    return ( UserPots[user_id] or {} ).pot or 0
   end
   
   AddEventHandler('vRP:playerLeave', function(id) activeRollers[id] = nil; UserPots[id] = nil  end)

  Tunnel.bindInterface('rydeSlots',remoteSlots)


end)() end