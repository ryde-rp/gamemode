local items = {}

-- wbody|WEAPON_NAME => arma in sine
-- wammo|WEAPON_NAME => gloante pentru arma

local get_wname = function(weapon_id)
  local name = string.gsub(weapon_id,"WEAPON_","")
  name = string.upper(string.sub(name,1,1))..string.lower(string.sub(name,2))
  return name
end

--- weapon body
local bodyname = function(args)
  return "Arma "..get_wname(args[2])
end

local bodychoices = function(args)
  local choices = {}
  local fullidname = joinStrings(args,"|")

  choices["Echipeaza"] = {function(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id then
		if vRP.tryGetInventoryItem(user_id, fullidname, 1, true) then
        if args[2]:upper() == "WEAPON_MOLOTOV" then
    		  GiveWeaponToPed(GetPlayerPed(player), args[2]:upper(), 1, false, true)
        else
          GiveWeaponToPed(GetPlayerPed(player), args[2]:upper(), 0, false, true)
        end
    	end
    end
  end}

  return choices
end

local bodyweight = function(args)
  return 0.75
end

items["wbody"] = {
	name = bodyname,
	description = "Arma de foc folosita pentru autoaparare sau in mod ilegal.",
	choices = bodychoices,
	weight = bodyweight
}

local wammo_name = function(args)
  return "Munitie "..get_wname(args[2])
end

local wammo_choices = function(args)
  local choices = {}
  local fullidname = joinStrings(args,"|")

  choices["Incarca"] = {function(player,choice)
    local user_id = vRP.getUserId(player)
    if user_id then
      local amount = vRP.getInventoryItemAmount(user_id, fullidname)
      vRP.prompt(player, "INCARCARE ARMA", {
        {field = "amt", title = "Suma incarcata (max. "..amount..")"}
      }, function(player,responses)
        local ammoAmt = responses["amt"]
        if not ammoAmt then return end
        
	      vRPclient.getWeaponInHand(player, {}, function(uWeapon)
	    	  if uWeapon == GetHashKey(args[2]) then
  		      if vRP.tryGetInventoryItem(user_id, fullidname, ramount, true) then
  		        vRPclient.giveWeaponAmmo(player, {args[2], ramount})
  		    	end
  		    else
  		      vRPclient.notify(source, {"Trebuie sa ai arma in mana pentru a putea incarca gloante!", "error"})
  		    end
		    end)
      end)
    end
  end}

  return choices
end

local wammo_weight = function(args)
  return 0.01
end

items["wammo"] = {
	name = wammo_name,
	description = "Munitie folosita pentru a incarca o arma de foc.",
	choices = wammo_choices,
	weight = wammo_weight
}

items["suppressor"] = {
  name = "Suppressor",
  description = "Suppressorul este folosit pentru a reduce zgomotul emis de arma",
  choices = function(args)
    local choices = {}
    local idname = args[1]
    
    choices["Monteaza"] = {function(player,choice)
      local user_id = vRP.getUserId(player)
      if user_id then
        vRPclient.getWeaponInHand(player, {}, function(uWeap)
          if uWeap ~= -1569615261 then
            if vRP.tryGetInventoryItem(user_id, "suppressor", 1, true) then
              TriggerClientEvent("vRP:progressBar", player, {
                duration = 6500,
                text = "🔫 Montezi atasamentul..",
              })

              vRPclient.playAnim(player, {true,{{"mp_arresting","a_uncuff",1}},false})

              Citizen.CreateThread(function()
                Citizen.Wait(6500)
              
                TriggerClientEvent("vRP:addWeaponAttachment", player, uWeap, "Suppressor")
                vRPclient.notify(player, {"Ai montat Suppressor pe arma!", "success"})
              end)
            end
          else
            vRPclient.notify(player, {"Poti pune acest atasament doar pe o arma!", "error"})
          end
        end)
      end
    end}
    return choices
  end,
  weight = 0.5,
}

items["grip"] = {
  name = "Grip",
  description = "Gripul este folosit pentru a imbunatatii stabilitatea armei",
  choices = function(args)
    local choices = {}
    local idname = args[1]
    
    choices["Monteaza"] = {function(player,choice)
      local user_id = vRP.getUserId(player)
      if user_id then
        vRPclient.getWeaponInHand(player, {}, function(uWeap)
          if uWeap ~= -1569615261 then
            if vRP.tryGetInventoryItem(user_id, "grip", 1, true) then
              TriggerClientEvent("vRP:progressBar", player, {
                duration = 6500,
                text = "🔫 Montezi atasamentul..",
              })

              vRPclient.playAnim(player, {true,{{"mp_arresting","a_uncuff",1}},false})

              Citizen.CreateThread(function()
                Citizen.Wait(6500)
              
                TriggerClientEvent("vRP:addWeaponAttachment", player, uWeap, "Grip")
                vRPclient.notify(player, {"Ai montat Grip pe arma!", "success"})
              end)
            end
          else
            vRPclient.notify(player, {"Poti pune acest atasament doar pe o arma!", "error"})
          end
        end)
      end
    end}
    return choices
  end,
  weight = 0.5,
}

items["scope"] = {
  name = "Scope",
  description = "Scopeul este folosit pentru a imbunatatii vizibilitatea in momentul folosirii armei de foc",
  choices = function(args)
    local choices = {}
    local idname = args[1]
    
    choices["Monteaza"] = {function(player,choice)
      local user_id = vRP.getUserId(player)
      if user_id then
        vRPclient.getWeaponInHand(player, {}, function(uWeap)
          if uWeap ~= -1569615261 then
            if vRP.tryGetInventoryItem(user_id, "scope", 1, true) then
              TriggerClientEvent("vRP:progressBar", player, {
                duration = 6500,
                text = "🔫 Montezi atasamentul..",
              })

              vRPclient.playAnim(player, {true,{{"mp_arresting","a_uncuff",1}},false})

              Citizen.CreateThread(function()
                Citizen.Wait(6500)
              
                TriggerClientEvent("vRP:addWeaponAttachment", player, uWeap, "Scope")
                vRPclient.notify(player, {"Ai montat Scope pe arma!", "success"})
              end)
            end
          else
            vRPclient.notify(player, {"Poti pune acest atasament doar pe o arma!", "error"})
          end
        end)
      end
    end}
    return choices
  end,
  weight = 0.5,
}

items["lanterna"] = {
  name = "Lanterna",
  description = "Lanterna este folosita pentru a imbunatatii vizibilitatea in momentul folosirii armei de foc pe timp de noapte",
  choices = function(args)
    local choices = {}
    local idname = args[1]
    
    choices["Monteaza"] = {function(player,choice)
      local user_id = vRP.getUserId(player)
      if user_id then
        vRPclient.getWeaponInHand(player, {}, function(uWeap)
          if uWeap ~= -1569615261 then
            if vRP.tryGetInventoryItem(user_id, "lanterna", 1, true) then
              TriggerClientEvent("vRP:progressBar", player, {
                duration = 6500,
                text = "🔫 Montezi atasamentul..",
              })

              vRPclient.playAnim(player, {true,{{"mp_arresting","a_uncuff",1}},false})

              Citizen.CreateThread(function()
                Citizen.Wait(6500)
              
                TriggerClientEvent("vRP:addWeaponAttachment", player, uWeap, "Flashlight")
                vRPclient.notify(player, {"Ai montat Lanterna pe arma!", "success"})
              end)
            end
          else
            vRPclient.notify(player, {"Poti pune acest atasament doar pe o arma!", "error"})
          end
        end)
      end
    end}
    return choices
  end,
  weight = 0.5,
}

items["partesuperioara"] = {
  name = "Parte Superioara",
  description = "",
  choices = function() end,
  weight = 0.5,
}

items["parteinferioara"] = {
  name = "Parte Inferioara",
  description = "",
  choices = function() end,
  weight = 0.5,
}

items["componentetec9"] = {
  name = "Componente TEC-9",
  description = "",
  choices = function() end,
  weight = 0.4,
}

items["componenteassaultsmg"] = {
  name = "Componente Assault SMG",
  description = "",
  choices = function() end,
  weight = 0.6,
}

items["componentepistolmk2"] = {
  name = "Componente Pistol MK2",
  description = "",
  choices = function() end,
  weight = 0.4,
}

items["componentecombatpistol"] = {
  name = "Componente Combat Pistol",
  description = "",
  choices = function() end,
  weight = 0.4,
}

items["componentemicrosmg"] = {
  name = "Componente Micro SMG",
  description = "",
  choices = function() end,
  weight = 0.4,
}

items["componentecompactrifle"] = {
  name = "Componente Compact Rifle",
  description = "",
  choices = function() end,
  weight = 0.6,
}

items["componenteak47"] = {
  name = "Componente AK47",
  description = "",
  choices = function() end,
  weight = 0.8,
}

items["tavapusca"] = {
  name = "Teava de Pusca",
  description = "",
  choices = function() end,
  weight = 1,
}

return items