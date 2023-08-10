local items = {}

items["piatra"] = {
    name = "Piatra",
    description = "",
    choices = function() end,
    weight = 1,
  }

  items["minereucupru"] = {
    name = "Minereu Cupru",
    description = "",
    choices = function() end,
    weight = 1,
  }

  items["cupru_nefinisat"] = {
    name = "Cupru Nefinisat",
    description = "",
    choices = function() end,
    weight = 1,
  }

  items["minereufier"] = {
    name = "Minereu Fier",
    description = "",
    choices = function() end,
    weight = 1,
  }

  items["minereualuminiu"] = {
    name = "Minereu Alumniniu",
    description = "",
    choices = function() end,
    weight = 1,
  }

  items["aluminiu_nefinisat"] = {
    name = "Alumniniu Nefinisat",
    description = "",
    choices = function() end,
    weight = 1,
  }

  items["minereuargint"] = {
    name = "Minereu Argint",
    description = "",
    choices = function() end,
    weight = 1,
  }

  items["minereuaur"] = {
    name = "Minereu Aur",
    description = "",
    choices = function() end,
    weight = 1,
  }

  items["minereusulf"] = {
    name = "Minereu Sulf",
    description = "",
    choices = function() end,
    weight = 1,
  }

  items["argintnefinisat"] = {
    name = "Argint Nefinisat",
    description = "",
    choices = function() end,
    weight = 0.5,
  }
  
  items["aurnefinisat"] = {
    name = "Aur Nefinisat",
    description = "",
    choices = function() end,
    weight = 0.5,
  }
  
  items["fiernefinisat"] = {
    name = "Fier Nefinisat",
    description = "",
    choices = function() end,
    weight = 0.4,
  }
  
  items["minereudecupru"] = {
    name = "Minereu de Cupru",
    description = "",
    choices = function() end,
    weight = 1,
  }

  items["tarnacop"] = {
    name = "Tarnacop",
    description = "",
    choices = function() end,
    weight = 1,
  }
  
  items["cuprunefinisat"] = {
    name = "Cupru nefinisat",
    description = "",
    choices = function() end,
    weight = 0.4,
  }
  
  items["sulf"] = {
    name = "Sulf",
    description = "",
    choices = function() end,
    weight = 0.2,
  }
  
  items["lingoudeaur"] = {
    name = "Lingou de Aur",
    description = "",
    choices = function() end,
    weight = 1,
  }
  
  items["lingoudeargint"] = {
    name = "Lingou de Argint",
    description = "",
    choices = function() end,
    weight = 1,
  }
  
  items["suruburi"] = {
    name = "suruburi",
    description = "",
    choices = function() end,
    weight = 0.1,
  }
  
  items["otel"] = {
    name = "Otel",
    description = "",
    choices = function() end,
    weight = 0.5,
  }
  
  items["carbune"] = {
    name = "Carbune",
    description = "",
    choices = function() end,
    weight = 0.1,
  }
  
  items["prafdepusca"] = {
    name = "Praf de Pusca",
    description = "",
    choices = function() end,
    weight = 0.01,
  }

  items["bustean"] = {
    name = "Bustean",
    description = "",
    choices = function() end,
    weight = 0.7,
  }

  items['metal_fragmentat'] = {
    name = "Metal Fragmentat",
    description = "",
    choices = function() end,
    weight = 0.5,
  }

  items["setscafandru"] = {
    name = "Set Scafandru",
    description = "Setul de scafandru este folosit pentru practicarea jobului de Scafandru Miner.",
    choices = function(args)
      local choices = {}
      local idname = args[1]
      
      choices["Echipeaza"] = {function(player,choice)
        TriggerClientEvent("FP:EchipeazaSetScafandru", player)
      end}
      return choices
    end,
    weight = 1,}


return items;