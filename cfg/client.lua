-- client-side vRP configuration

local cfg = {}

cfg.iplload = true

cfg.voice_proximity = 30.0 -- default voice proximity (outside)
cfg.voice_proximity_vehicle = 15.0
cfg.voice_proximity_inside = 13.0

cfg.gui = {
  anchor_minimap_width = 260,
  anchor_minimap_left = 60,
  anchor_minimap_bottom = 213
}

-- gui controls (see https://wiki.fivem.net/wiki/Controls)
-- recommended to keep the default values and ask players to change their keys
cfg.controls = {
  phone = {
    -- PHONE CONTROLS
    up = {3,172},
    down = {3,173},
    left = {3,174},
    right = {3,175},
    select = {3,176},
    cancel = {3,177},
    open = {3,311}, -- K to open the menu
  },
  request = {
    yes = {1,166}, -- Michael, F5
    no = {1,167} -- Franklin, F6
  }
}

-- disable menu if handcuffed
cfg.handcuff_disable_menu = true

-- when health is under the threshold, player is in coma
-- set to 0 to disable coma
cfg.coma_threshold = 120

-- maximum duration of the coma in minutes
cfg.coma_duration = 29

-- if true, a player in coma will not be able to open the main menu
cfg.coma_disable_menu = false

-- see https://wiki.fivem.net/wiki/Screen_Effects
cfg.coma_effect = "DeathFailMPDark"

-- if true, vehicles can be controlled by others, but this might corrupts the vehicles id and prevent players from interacting with their vehicles
cfg.vehicle_migration = false

cfg.map_blips = {

  ["Politia Los-Santos"] = {
    coords = {437.00091552734,-982.34582519532,30.723756790162},
    blip_id = 526,
    blip_color = 63,
    scale = 0.650,
  },

  ["Politia Paleto-Bay"] = {
    coords = {-446.17834472656,6013.6938476562,31.716520309448},
    blip_id = 526,
    blip_color = 31,
    scale = 0.650,
  },

  ["Politia Sandy-Shores"] = {
    coords = {1850.7702636718,3686.0822753906,34.270118713378},
    blip_id = 526,
    blip_color = 5,
    scale = 0.650,
  },

  ["Spital Viceroy"] = {
    coords = {-795.19696044922,-1222.3479003906,7.3374257087708},
    blip_id = 107,
    blip_color = 1,
    scale = 0.450,
  },

  ["Statie Reciclare"] = {
    coords = {-448.71423339844,-1698.5794677734,18.933629989624},
    blip_id = 527,
    blip_color = 44,
    scale = 0.5,
  },
  
  [212] = {
    coords = {455.27032470704,5571.806640625,781.18359375},
    blip_id = 550,
    blip_color = 0,
    scale = 0.450,
    name = "Salt cu parasuta",
  },

  [2121] = {
    coords = {429.11569213868,5614.8081054688,766.23840332032},
    blip_id = 550,
    blip_color = 0,
    scale = 0.450,
    name = "Salt cu parasuta",
  },

  ["Club Galaxy"] = {
    coords = {355.31051635742,302.55828857422,103.76114654542},
    blip_id = 590,
    blip_color = 8,
    scale = 0.6,
  },

  ["Casino"] = {
    coords = {963.10614013672,35.739540100098,74.876976013184},
    blip_id = 89,
    blip_color = 3,
    scale = 0.7,
  },

  -- # Angajari/Garaje Joburi # --
  ["Job: Sofer de Autobuz"] = {
    coords = {442.9266052246,-628.20416259766,28.520711898804},
    blip_id = 351,
    blip_color = 39,
    scale = 0.550,
  },
  
  ["Zona Momeala"] = {
    coords = {-1987.1396484375,2596.4577636718,1.5778241157532},
    blip_id = 655,
    blip_color = 42,
    scale = 0.550,
  },
}

return cfg