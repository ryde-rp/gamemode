local items = {}
local healCooldown = {}
local anim_trusa_medicala = {
  {"amb@medic@standing@kneel@enter","enter",1},
  {"amb@medic@standing@kneel@idle_a","idle_a",1},
  {"amb@medic@standing@kneel@exit","exit",1},
}

items["medkit"] = {
    name = "Trusa Medicala",
    description = "Foloseste aceasta trusa pentru a acorda primul ajutor celui mai apropiat jucator.",
    choices = function(args)
      local choices = {}
      local idname = args[1]
      
      choices["Foloseste"] = {function(player,choice)
      	local user_id = vRP.getUserId(player)
      	if user_id then
	       	vRPclient.getNearestPlayer(player, {10}, function(nPlayer)
	       		if nPlayer then
	       			vRPclient.isInComa(player, {}, function(userDied)
	       				if not userDied then
				       		vRPclient.isInComa(nPlayer, {}, function(inComa)
				       			if inComa then
						       		vRP.tryGetInventoryItem(user_id, "medkit", 1, true)

						       		TriggerClientEvent("vRP:progressBar", player, {
										duration = 15000,
										text = "💊 Acorzi primul ajutor..",
						       		})

						    		TriggerClientEvent("vRP:progressBar", nPlayer, {
										duration = 15000,
										text = "🩺 Primesti ingrijiri medicale..",
						       		})

						          	vRPclient.playAnim(player,{false,anim_trusa_medicala,false})
							        
							        Citizen.CreateThread(function()
							        	Citizen.Wait(15000)

								    	vRPclient.isInComa(player, {}, function(inComa)
								    		if not inComa then
								    			vRPclient.varyHealth(nPlayer, {25})
								    		end
								    	end)
							        end)
				       			else
				       				vRPclient.notify(player, {"Aceasta persoana nu are nevoie de ingrijiri medicale!", "error"})
				       			end
				       		end)
				       	end
			       	end)
   				else
		        	vRPclient.notify(player, {"Nu a fost gasit niciun jucator in jurul tau!", "error"})
			    end
	       	end)
	    end
      end}
      return choices
    end,
    weight = 2.0,
}

items["bandajmic"] = {
    name = "Bandaj Mic",
    description = "",
    choices = function(args)
      local choices = {}
      local idname = args[1]
      
      choices["Foloseste"] = {function(player,choice)
      	local user_id = vRP.getUserId(player)
      	if user_id then
      		if not healCooldown[user_id] or healCooldown[user_id] <= os.time() then
	      		vRPclient.isInComa(player, {}, function(inComa)
	      			if not inComa then
	      				healCooldown[user_id] = os.time() + 15
		      			vRP.tryGetInventoryItem(user_id, "bandajmic", 1, true)

					   	TriggerClientEvent("vRP:progressBar", player, {
							duration = 4000,
							text = "🩹 Aplici bandaj mic..",
					   	})

						vRPclient.playAnim(player, {true,{{"mp_arresting","a_uncuff",1}},false})
					    
					    Citizen.CreateThread(function()
					    	Citizen.Wait(4000)
					    	vRPclient.isInComa(player, {}, function(inComa)
					    		if not inComa then
					    			vRPclient.varyHealth(player, {35})
					    		end
					    	end)

					    	vRPclient.notify(player, {"Ai primit +35 HP", "success"})
					    end)
					else
						vRPclient.notify(player, {"Nu iti poti aplica bandaje mort!", "error"})
	      			end
	      		end)
	      	else
	      		vRPclient.notify(player, {("Trebuie sa mai astepti %d secunde!"):format(healCooldown[user_id] - os.time()), "error"})
	      	end
	    end
      end}
      return choices
    end,
    weight = 0.5,
}

items["bandajmare"] = {
    name = "Bandaj Mare",
    description = "",
    choices = function(args)
      local choices = {}
      local idname = args[1]
      
      choices["Foloseste"] = {function(player,choice)
      	local user_id = vRP.getUserId(player)
      	if user_id then
      		if not healCooldown[user_id] or healCooldown[user_id] <= os.time() then
	      		vRPclient.isInComa(player, {}, function(inComa)
	      			if not inComa then
		      			vRP.tryGetInventoryItem(user_id, "bandajmare", 1, true)

					   	TriggerClientEvent("vRP:progressBar", player, {
							duration = 6500,
							text = "🩹 Aplici bandaj mare..",
					   	})

						vRPclient.playAnim(player, {true,{{"mp_arresting","a_uncuff",1}},false})
					    
					    Citizen.CreateThread(function()
					    	Citizen.Wait(6500)
					    	vRPclient.isInComa(player, {}, function(inComa)
					    		if not inComa then
					    			vRPclient.varyHealth(player, {55})
					    		end
					    	end)

					    	vRPclient.notify(player, {"Ai primit +55 HP", "success"})
					    end)
					else
						vRPclient.notify(player, {"Nu iti poti aplica bandaje mort!", "error"})
	      			end
	      		end)
	      	else
	      		vRPclient.notify(player, {("Trebuie sa mai astepti %d secunde!"):format(healCooldown[user_id] - os.time()), "error"})
	      	end
	    end
      end}
      return choices
    end,
    weight = 0.8,
}

items["adrenalina"] = {
    name = "Injectie Adrenalina",
    description = "",
    choices = function(args)
      local choices = {}
      local idname = args[1]
      
      choices["Foloseste"] = {function(player,choice)
      	local user_id = vRP.getUserId(player)
      	if user_id then
      		if not healCooldown[user_id] or healCooldown[user_id] <= os.time() then
	      		vRPclient.isInComa(player, {}, function(inComa)
	      			if not inComa then
		      			vRP.tryGetInventoryItem(user_id, "adrenalina", 1, true)

					   	TriggerClientEvent("vRP:progressBar", player, {
							duration = 3500,
							text = "💉 Injectezi adrenalina..",
					   	})

						vRPclient.playAnim(player, {true,{{"mp_arresting","a_uncuff",1}},false})
					    
					    Citizen.CreateThread(function()
					    	Citizen.Wait(3500)
							TriggerClientEvent("vRP:bypassRunning", player)

							-- vRPclient.isInComa(player, {}, function(inComa)
					    	-- 	if not inComa then
					    	-- 		vRPclient.varyHealth(player, {30})
					    	-- 	end
					    	-- end)

					    end)
					else
						vRPclient.notify(player, {"Nu iti poti injecta adrenalina mort!", "error"})
	      			end
	      		end)
	      	else
	      		vRPclient.notify(player, {("Trebuie sa mai astepti %d secunde!"):format(healCooldown[user_id] - os.time()), "error"})
	      	end
	    end
      end}
      return choices
    end,
    weight = 0.6,
}

return items
