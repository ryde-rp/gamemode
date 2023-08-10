local cfg = {}
cfg.items = {
  ["phone"] = {
    name = "Telefon mobil",
    description = "Telefon mobil conectat la reteaua mobila FP-Mobile",
    choices = function(args)
      local choices = {}
      local idname = args[1]

      choices["Foloseste"] = {function(player, _)
        vRPclient.executeCommand(player, {"phone"})
      end}
      return choices
    end,
    weight = 0.2,
  },

  ["buletin"] = {
    name = "Buletin",
    description = "Carte de identitate unicata",
    choices = function(args)
      local choices = {}
      local idname = args[1]

      choices["Arata"] = {function(player)
        local user_id = vRP.getUserId(player)
        if user_id then
          vRPclient.getNearestPlayer(player, {3}, function(nPlayer)
            if nPlayer then            
              TriggerClientEvent("fp-identity$playBadgeAnim", player, "buletin")
              Citizen.Wait(300)

              vRP.getUserIdentity(user_id, function(userIdentity)
                if userIdentity then
                  TriggerClientEvent("vRP:showBuletin", nPlayer, {
                    nume = userIdentity.firstname,
                    prenume = userIdentity.name,
                    target = player,
                    age = userIdentity.age,
                    usr_id = user_id,
                    adresa = "Str.  Nr. ",
                  })

                  TriggerClientEvent("vRP:showBuletin", player, {
                    nume = userIdentity.firstname,
                    prenume = userIdentity.name,
                    age = userIdentity.age,
                    usr_id = user_id,
                    adresa = "Str.  Nr. ",
                  })
                end
              end)
            else
              vRP.getUserIdentity(user_id, function(userIdentity)
                if userIdentity then
                  TriggerClientEvent("vRP:showBuletin", player, {
                    nume = userIdentity.firstname,
                    prenume = userIdentity.name,
                    age = userIdentity.age,
                    usr_id = user_id,
                    adresa = "Str.  Nr. ",
                  })
                end
              end)
            end
          end)
        end
      end}
      return choices
    end,
    weight = 0.05,
  },

  ["drivingLicense"] = {
    name = "Permis Auto",
    description = "Permis de conducere a autovehiculelor",
    choices = function(args)
      local choices = {}
      local idname = args[1]

      choices["Arata"] = {function(player)
        local user_id = vRP.getUserId(player)
        if user_id then
          vRPclient.getNearestPlayer(player, {3}, function(nPlayer)
            if nPlayer then            
              TriggerClientEvent("fp-identity$playBadgeAnim", player, "permis")
              Citizen.Wait(300)

              vRP.getUserIdentity(user_id, function(userIdentity)
                if userIdentity then
                  TriggerClientEvent("vRP:showPermis", nPlayer, {
                    nume = userIdentity.firstname,
                    prenume = userIdentity.name,
                    target = player,
                  })

                  TriggerClientEvent("vRP:showPermis", player, {
                    nume = userIdentity.firstname,
                    prenume = userIdentity.name,
                  })
                end
              end)
            else
              vRP.getUserIdentity(user_id, function(userIdentity)
                if userIdentity then
                  TriggerClientEvent("vRP:showPermis", player, {
                    nume = userIdentity.firstname,
                    prenume = userIdentity.name,
                  })
                end
              end)
            end
          end)
        end
      end}
      return choices
    end,
    weight = 0.05,
  },

  ["legitimatie"] = {
    name = "Legitimatie",
    description = "Legitimatia de la locul de munca",
    choices = function(args)
      local choices = {}
      local idname = args[1]

      choices["Arata"] = {function(player)
        local user_id = vRP.getUserId(player)
        if user_id then
          local theFaction = vRP.getUserFaction(user_id)
          local theRank = vRP.getUserFactionRank(user_id)

          vRPclient.getNearestPlayer(player, {3}, function(nPlayer)
            if nPlayer then
              TriggerClientEvent("fp-identity$playBadgeAnim", player, theFaction)
              Citizen.Wait(300)

              vRP.getUserIdentity(user_id, function(userIdentity)
                if userIdentity then
                  TriggerClientEvent("vRP:showFactionBadge", nPlayer, {
                    nume = userIdentity.firstname,
                    prenume = userIdentity.name,
                    target = player,
                    faction = theFaction,
                    rank = theRank,
                    usr_id = user_id,
                  })

                  TriggerClientEvent("vRP:showFactionBadge", player, {
                    nume = userIdentity.firstname,
                    prenume = userIdentity.name,
                    faction = theFaction,
                    rank = theRank,
                    usr_id = user_id,
                  })
                end
              end)
            else
              vRP.getUserIdentity(user_id, function(userIdentity)
                if userIdentity then
                  TriggerClientEvent("vRP:showFactionBadge", player, {
                    nume = userIdentity.firstname,
                    prenume = userIdentity.name,
                    faction = theFaction,
                    rank = theRank,
                    usr_id = user_id,
                  })
                end
              end)
            end
          end)
        end
      end}
      return choices
    end,
    weight = 0.05,
  },

  ["body_armor"] = {
    name = "🔰 Vesta Anti-Glont",
    description = "Vesta Anti-Glont pentru o viata mai sigura.",
    choices = function(args)
      local choices = {}
      local idname = args[1]

      choices["Echipeaza"] = {function(player, _)
        local user_id = vRP.getUserId(player)
        if user_id then
          if vRP.tryGetInventoryItem(user_id, "body_armor", 1, true) then
            TriggerClientEvent("vRP:progressBar", player, {
              duration = 5000,
              text = "Echipezi 🔰 Vesta Anti-Glont..",
            })
            
            vRPclient.playAnim(player, {true,{{"mp_arresting","a_uncuff",1}},false})
            Citizen.Wait(5000)
            vRPclient.setArmour(player,{100,false})
          end
        end
      end}
      return choices
    end,
    weight = 8.0,
  },

  ["fuelcan"] = {
    name = "⛽ Canistra cu Benzina",
    description = "Canistra plina cu benzina.",
    choices = function(args)

      local choices = {}
      local idname = args[1]

      choices["Foloseste"] = {function(player, _)
        local user_id = vRP.getUserId(player)
        if user_id then
          if vRP.tryGetInventoryItem(user_id, "fuelcan", 1, true) then
            TriggerClientEvent("fuel$folosesteCanistra", player)
          end
        end
      end}
      return choices
    end,
    weight = 0.8,
  },

  ["catuse"] = {
    name = "Catuse",
    description = "Catuse pentru a incatusa o persoana.",
    choices = function(args)
      local choices = {}
      local idname = args[1]

      choices["Foloseste"] = {function(player, _)
        local user_id = vRP.getUserId(player)
        if user_id then
          vRPclient.getNearestPlayer(player, {1.5}, function(nplayer)
            local nuser_id = vRP.getUserId(nplayer)

            if not nuser_id then
              return vRPclient.notify(player, {"Niciun jucator prin preajma!", "error"})
            end

            vRPclient.isHandcuffed(nplayer, {}, function(cuffed)
              local newState = not cuffed

              if not newState then
                TriggerClientEvent("policeAnim$onUncuffed", nplayer, player)
                vRPclient.executeCommand(player, {"e uncuff"})
              else
                TriggerClientEvent('policeAnim$beingArested', nplayer, player)
                TriggerClientEvent('policeAnim$aresting', player)
              end

              Citizen.CreateThread(function()
                Citizen.Wait(3000)

                vRPclient.togHandcuffs(nplayer, {})
                vRPclient.executeCommand(player, {"e c"})
                vRPclient.notify(nplayer, {"Ai fost "..(newState and "incatusat" or "descatusat").."!", (newState and "warning" or "info"), false, "fas fa-handcuffs"})
              end)
            end)
          end)
        end
      end}

      return choices
    end,
    weight = 0.1,
  },

  ["fp_skateboard"] = {
    name = "🛹 Skateboard",
    description = "Skateboard folosit pentru a te distra intr-un parc.",
    choices = function(args)
      local choices = {}
      local idname = args[1]

      choices["Foloseste"] = {function(player, _)
        local user_id = vRP.getUserId(player)
        if user_id then
          local spawnSkateboard = checkIfSkateboard(user_id)
          
          if not spawnSkateboard then
            return vRPclient.notify(player, {"Ai deja un skateboard afara!", "error"})
          end

          spawnSkateboard(player)
        end
      end}

      return choices
    end,
    weight = 3.1,
  },

  ["scrisoareposta"] = {
    name = "Scrisoare",
    description = "Scrisoare livrata de Posta Romana",
    choices = function() end,
    weight = 0.3,
  },

  ["electrician_license"] = {
    name = "electrician_license",
    description = "electrician_license livrata de Job",
    choices = function() end,
    weight = 0.3,
  },

  ["forestier_license"] = {
    name = "forestier_license",
    description = "forestier_license livrata de Job",
    choices = function() end,
    weight = 0.3,
  },

  ["constructor_license"] = {
    name = "constructor_license",
    description = "constructor_license livrata de Job",
    choices = function() end,
    weight = 0.3,
  },

  ["miner_license"] = {
    name = "miner_license",
    description = "miner_license livrata de Job",
    choices = function() end,
    weight = 0.3,
  },

  ["glovo_license"] = {
    name = "glovo_license",
    description = "glovo_license livrata de Job",
    choices = function() end,
    weight = 0.3,
  },

  ["pescar_license"] = {
    name = "pescar_license",
    description = "pescar_license livrata de Job",
    choices = function() end,
    weight = 0.3,
  },

  ["sofer_autobuz_license"] = {
    name = "sofer_autobuz_license",
    description = "sofer_autobuz_license livrata de Job",
    choices = function() end,
    weight = 0.3,
  },

  ["petdeplastic"] = {
    name = "Pet de plastic",
    description = "Acesta se poate recicla si se gaseste in gunoaie",
    choices = function(args)
      local choices = {}
      local idname = args[1]

      choices["Foloseste"] = {function(player, _)
        local user_id = vRP.getUserId(player)
        if user_id then
          vRPclient.varyHealth(player, {-5})
          vRPclient.notify(player, {"Ai gasit un sobolan mort...", "warning", false, "fas fa-bugs"})
        end
      end}

      return choices
    end,
    weight = 0.1,
  },

  ["conserva"] = {
    name = "Conserva",
    description = "Aceasta se poate recicla si se gaseste in gunoaie",
    choices = function(args)
      local choices = {}
      local idname = args[1]

      choices["Foloseste"] = {function(player)
        local user_id = vRP.getUserId(player)
        if user_id then
          vRPclient.varyHealth(player, {-5})
          vRPclient.notify(player, {"Ai gasit un sobolan mort...", "warning", false, "fas fa-bugs"})
        end
      end}

      return choices
    end,
    weight = 0.1,
  },

  ["radio"] = {
    name = "📞 Statie Radio",
    description = "Folosita pentru comunicare cu alti oameni, prin intermediul antenelor radio.",
    choices = function(args)
      local choices = {}
      local idname = args[1]

      choices["Foloseste"] = {function(player)
        TriggerClientEvent("fp-radio:useItem", player)
      end}

      return choices
    end,
    weight = 0.1,
  },

  ["repair_kit"] = {
    name = "🧰 Trusa de Reparatii",
    description = "Folosita pentru a repara un vehicul stricat.",
    choices = function(args)
      local choices = {}
      local idname = args[1]

      choices["Foloseste"] = {function(player)
        local user_id = vRP.getUserId(player)
        if user_id then
          if vRP.tryGetInventoryItem(user_id, "repair_kit", 1, true) then
            vRPclient.playAnim(player,{false,{task="WORLD_HUMAN_WELDING"},false})
            
            Citizen.SetTimeout(15000, function()
              vRPclient.fixNearestVeh(player,{7})
              vRPclient.stopAnim(player,{false})
            end)
          end
        end
      end}
      
      return choices
    end,
    weight = 1.0,
  }
  
}

-- load more items function
local function load_item_pack(name)
  local items = module("cfg/item/"..name)
  if items then
    for k,v in pairs(items) do
      cfg.items[k] = v
    end
  else
    print(("^5Modules/Items: ^7Item pack ^5%s ^7does not exist!"):format(name))
  end
end

-- Packuri de iteme
load_item_pack("mancare")
load_item_pack("medicale")
load_item_pack("weapon_utils")
load_item_pack("ghiozdane")
load_item_pack("pachete_glovo")
load_item_pack("pesti")
load_item_pack("miner")
load_item_pack("traficantetnobotanice")
load_item_pack("traficantdetigari")
load_item_pack("jafbanca")
load_item_pack("jafbiju")
load_item_pack('weapons')
load_item_pack("ammo")
load_item_pack("meele_weapons")
load_item_pack("bani_impachetati")


return cfg
