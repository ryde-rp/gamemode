
  local theGunshops = {
      {vec3(22.171268463135,-1105.2290039063,29.797004699707), 150},
      {vec3(842.54113769531,-1035.6743164063,28.194869995117), 0},
      {vec3(810.23071289063,-2159.1396484375,29.618989944458), 0},
      {vec3(-1304.1517333984,-394.55209350586,36.695755004883), 70},
      {vec3(253.83529663086,-50.484718322754,69.941101074219), 70},
      {vec3(1692.1788330078,3761.0441894531,34.705337524414), 225},
      {vec3(-331.76403808594,6084.9794921875,31.454763412476), 225},
  }

  RegisterNetEvent("fp-gunshop:viewItems")
  AddEventHandler("fp-gunshop:viewItems", function()
      Wait(500)

      SendNUIMessage({
          act = "interface",
          target = "gunShop",
      })

      TriggerEvent("vRP:interfaceFocus", true)
  end)


  CreateThread(function()
      Wait(150)

      for gunshopId, gunshopPosition in pairs(theGunshops) do
          local pos = gunshopPosition[1]

          tvRP.createPed("vrp_gunshopPed:"..gunshopId, {
            position = pos,
            rotation = gunshopPosition[2],
            model = "a_m_y_stwhi_02",
            freeze = true,
            scenario = {
              default = true,
            },
            minDist = 3.5,
            
            name = "Ivan Teodor",
            description = "Vanzator de Arme Albe",
            text = "Bine ai venit la noi, cu ce te-as putea ajuta?",
            fields = {
              {item = "Vreau sa cumpar arme albe.", post = "fp-gunshop:checkHours", args={"server"}}
            },
          })

          local nblip = tvRP.createBlip("vrp_gunshopBlip:"..gunshopId, pos.x, pos.y, pos.z, 110, 0, "Magazin Arme Albe", 0.550)
          SetBlipAlpha(nblip, 150)
      end
  end)

  RegisterNUICallback("vRPgunshop:getGun", function(data, cb)
      if data then
          vRPserver.purchaseOneGun({data.item})   
      end

      cb("discord.gg/ryde")
  end)
