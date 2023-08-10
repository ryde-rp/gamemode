local items = {}

items["elastic"] = {
    name = "Elastic din Cauciuc",
    description = "Elastic din caucuic, folosit pentru a face diverse lucruri.",
    choices = function(args)
      local choices = {}

      choices["Foloseste"] = {function(player, _)
        local user_id = vRP.getUserId(player)
        vRP.prompt(player,"IMPACHETEAZA BANI",{{field = "suma", title = "Cate elastice sa folosesti? (1x elastic = 10k Bani Impachetati)"}},function(player,responses)
			  local amount = responses["suma"]
            amount = tonumber(amount)

            if amount > 0 then 
                if vRP.tryGetInventoryItem(user_id, "elastic", amount, false) then
                    if vRP.tryPayment(user_id, amount*10000) then
                        vRP.giveInventoryItem(user_id, "bani_impachetati", amount*10000)
                        local receiveMoney = vRP.formatMoney(amount*10000)
                        vRPclient.notify(player, {"Ai impachetat "..receiveMoney.."$ in bani impachetati."})
                    else
                        vRPclient.notify(player, {"Nu ai destui bani la tine!.", "error"})
                    end
                else
                    vRPclient.notify(player, {"Nu ai destule elastice!", "error"})
                end
            end

        end)
      end}
      return choices
    end,
    weight = 0.0,
  }

items['bani_impachetati'] = {
    name = "Bani Impachetati",
    description = "Bani Impachetati",
    choices = function(args)
      local choices = {}

      choices["Foloseste"] = {function(player, _)
        local user_id = vRP.getUserId(player)
        vRP.prompt(player,"DEZPACHETEAZA BANI",{{field = "suma", title = "Cat vrei sa dezpachetezi?"}},function(player,responses)
          local amount = responses["suma"]
              amount = tonumber(amount)

            if amount >= 1 then
              if vRP.tryGetInventoryItem(user_id, "bani_impachetati", amount, false) then
                vRP.giveMoney(user_id,amount)
                local receiveMoney = vRP.formatMoney(amount)
                vRPclient.notify(player, {"Ai primit "..receiveMoney.."$ in urma dezpachetari unei sume de bani!", "info"})
              end
            end
        end)
      end}
      return choices
    end,
    weight = 0.0,
  }

return items