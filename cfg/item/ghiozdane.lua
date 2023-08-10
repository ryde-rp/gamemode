local items = {}

items["ghiozdanMare"] = {
    name = "🎒 Ghiozdan Mare",
    description = "Foloseste acest ghiozdan pentru a putea cara mai multe iteme.",
    choices = function(args)
      local choices = {}
      local idname = args[1]
      
      choices["Foloseste"] = {function(player,choice)
      	local user_id = vRP.getUserId(player)
      	if user_id then
      		local currentBag = getBackpack(user_id)
      		if currentBag then
      			if currentBag ~= "Ghiozdan Mare" then
      				return vRPclient.notify(player, {"Ti-ai echipat deja 🎒 "..currentBag..", dezechipeaza-l pentru a-ti schimba ghiozdanul!", "error"})
      			end

      			return removeBackpack(player, user_id)
      		end

      		updateBackpack(user_id, "Ghiozdan Mare")
	      end
      end}
      
      return choices
    end,
    weight = 2.0,
}

items["ghiozdanMediu"] = {
    name = "🎒 Ghiozdan Mediu",
    description = "Foloseste acest ghiozdan pentru a putea cara mai multe iteme.",
    choices = function(args)
      local choices = {}
      local idname = args[1]
      
      choices["Foloseste"] = {function(player,choice)
      	local user_id = vRP.getUserId(player)
      	if user_id then
      		local currentBag = getBackpack(user_id)
      		if currentBag then
      			if currentBag ~= "Ghiozdan Mediu" then
      				return vRPclient.notify(player, {"Ti-ai echipat deja 🎒 "..currentBag..", dezechipeaza-l pentru a-ti schimba ghiozdanul!", "error"})
      			end

      			return removeBackpack(player, user_id)
      		end

      		updateBackpack(user_id, "Ghiozdan Mediu")
	      end
      end}
      
      return choices
    end,
    weight = 2.0,
}

items["ghiozdanMic"] = {
    name = "🎒 Ghiozdan Mic",
    description = "Foloseste acest ghiozdan pentru a putea cara mai multe iteme.",
    choices = function(args)
      local choices = {}
      local idname = args[1]
      
      choices["Foloseste"] = {function(player,choice)
      	local user_id = vRP.getUserId(player)
      	if user_id then
      		local currentBag = getBackpack(user_id)
      		if currentBag then
      			if currentBag ~= "Ghiozdan Mic" then
      				return vRPclient.notify(player, {"Ti-ai echipat deja 🎒 "..currentBag..", dezechipeaza-l pentru a-ti schimba ghiozdanul!", "error"})
      			end

      			return removeBackpack(player, user_id)
      		end

      		updateBackpack(user_id, "Ghiozdan Mic")
	      end
      end}
      
      return choices
    end,
    weight = 2.0,
}

items["borsetaMica"] = {
    name = "🎒 Borseta",
    description = "Foloseste aceasta borseta pentru a putea cara mai multe iteme.",
    choices = function(args)
      local choices = {}
      local idname = args[1]
      
      choices["Foloseste"] = {function(player,choice)
        local user_id = vRP.getUserId(player)
        if user_id then
          local currentBag = getBackpack(user_id)
          if currentBag then
            if currentBag ~= "Borseta" then
              return vRPclient.notify(player, {"Ti-ai echipat deja 🎒 "..currentBag..", dezechipeaza-l pentru a-ti schimba ghiozdanul!", "error"})
            end

            return removeBackpack(player, user_id)
          end

          updateBackpack(user_id, "Borseta")
        end
      end}
      
      return choices
    end,
    weight = 2.0,
}

items["geanta"] = {
    name = "🎒 Geanta",
    description = "Foloseste aceasta geanta pentru a putea cara mai multe iteme.",
    choices = function(args)
      local choices = {}
      local idname = args[1]
      
      choices["Foloseste"] = {function(player,choice)
        local user_id = vRP.getUserId(player)
        if user_id then
          local currentBag = getBackpack(user_id)
          if currentBag then
            if currentBag ~= "Geanta" then
              return vRPclient.notify(player, {"Ti-ai echipat deja 🎒 "..currentBag..", dezechipeaza-l pentru a-ti schimba ghiozdanul!", "error"})
            end

            return removeBackpack(player, user_id)
          end

          updateBackpack(user_id, "Geanta")
        end
      end}
      
      return choices
    end,
    weight = 2.0,
}

return items