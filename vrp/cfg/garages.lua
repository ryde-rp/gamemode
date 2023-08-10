local cfg = {}

cfg.garage_types = {
  ["Civili"] = {
    _config = {vtype = "ds", blip_id = 524, blip_color = 0, marker_color = {255, 255, 255, 150}, text = "Acceseaza garajul personal"},
  },

  ["Camioane"] = {
    _config = {vtype = "camion", blip_id = 635, blip_color = 0, marker_id = 39, marker_color = {255, 255, 255, 130}},
  },
  
  ["Remorci"] = {
    _config = {vtype = "remorca", blip_id = 479, blip_color = 0, marker_id = 39, marker_color = {255, 255, 255, 130}},
  },

  ["Barci"] = {
    _config = {vtype = "barca", blip_id = 410, blip_color = 0, marker_id = 35, marker_color = {255, 255, 255, 130}},
  },
  
  ["Avioane"] = {
    _config = {vtype = "avion", blip_id = 578, blip_color = 0, marker_id = 7, marker_color = {255, 255, 255 , 130}, text = "Acceseaza hangar avioane"},
  },
  
  ["Elicoptere"] = {
    _config = {vtype = "elicopter", blip_id = 602, blip_color = 0, marker_id = 34, marker_color = {255, 255, 255, 130}, text = "Acceseaza hangar elicoptere"},
  },
  ["Dube"] = {
    _config = {vtype = "duba", blip_id = 616, blip_color = 0, marker_color = {255, 255, 255, 130}},
  },
  ["Cayo"] = {
    _config = {vtype = "cayo", blip_id = 524, blip_color = 82, marker_color = {255, 255, 255, 130}},
  },
  
  -- Factiuni Legale/Ilegale

  ["Politia Romana"] = {
    _config = {vtype = "faction", blip_id = 569, blip_color = 54, marker_color = {0,255, 255, 130}, faction = "Politia Romana"},
    ["14ram"] = {"Dodge Ram Unmarked", "https://cdn.discordapp.com/attachments/996450506388029460/1001116974824304680/14ram.png"},
    ["16bugatti"] = {"Bugatti Chiron Unmarked", "https://cdn.discordapp.com/attachments/996450506388029460/1001116985989550141/16bugatti.png"},
    ["e63unmark"] = {"Mercedes E63S Unmarked", "https://cdn.discordapp.com/attachments/996450506388029460/1001117385811570828/e63unmark.png"},
    ["mercedesunmarked"] = {"Mercedes E63 Unmarked", "https://cdn.discordapp.com/attachments/996450506388029460/1001120940480016395/mercedesunmarked.png"},
    ["pd_bmwr"] = {"BMW M5 Unmarked", "https://cdn.discordapp.com/attachments/996450506388029460/1001121346597691423/pd_bmwr.png"},
    ["pdmercedesv"] = {"Mercedes-Benz Vito Unmarked", "https://cdn.discordapp.com/attachments/996450506388029460/1001127498534359101/pdmercedesv.png"},
    ["polnspeedo"] = {"Vapid Speedo Unmarked", "https://cdn.discordapp.com/attachments/996450506388029460/1001115083600044053/Untitled-1.png"},
    ["audis4"] = {"Audi S4 Politie", "https://cdn.discordapp.com/attachments/996450506388029460/1001117000749293599/audis4.png"},
    ["dacia2"] = {"Dacia Duster Politie", "https://cdn.discordapp.com/attachments/996450506388029460/1001116950312788099/dacia2.png"},
    ["g63amg6x6cop"] = {"Mercedes-AMG G63 6X6 Politie", "https://cdn.discordapp.com/attachments/996450506388029460/1001118517447368734/g63amg6x6cop.png"},
    ["ghispo2"] = {"Maserati Ghibli", "https://cdn.discordapp.com/attachments/996450506388029460/1001118930296913970/ghispo2.png"},
    ["jp"] = {"Jeep Wrangler Politie", "https://cdn.discordapp.com/attachments/996450506388029460/1001119851219255316/jp.png"},
    ["logan"] = {"Dacia Logan Politie", "https://cdn.discordapp.com/attachments/996450506388029460/1001120309379870782/logan.png"},
    ["passat"] = {"Volkswagen Passat Politie", "https://cdn.discordapp.com/attachments/996450506388029460/1001121858487324753/passat.png"},
    ["polarteon"] = {"Volkswagen Arteon Politie", "https://cdn.discordapp.com/attachments/996450506388029460/1001117654972645476/Untitled-1.png"},
    ["polchiron"] = {"Bugatti Chiron Politie", "https://cdn.discordapp.com/attachments/996450506388029460/1001125989453156372/Untitled-1.png"},
    ["polf430"] = {"Ferrari Scuderia F430 Politie", "https://cdn.discordapp.com/attachments/996450506388029460/1001126709678055606/Untitled-1.png"},
    ["polgs350"] = {"Lexus GS350 Politie", "https://cdn.discordapp.com/attachments/996450506388029460/1001127158183366707/Untitled-1.png"},
    ["porschecayenne"] = {"Porsche Cayenne Politie", "https://cdn.discordapp.com/attachments/996450506388029460/1001118625958199376/Untitled-1.png"},
    ["skoda"] = {"Skoda Octavia Politie", "https://cdn.discordapp.com/attachments/996450506388029460/1001119108772937808/Untitled-1.png"},
    ["volvopolitie"] = {"Volvo V70 Politie", "https://cdn.discordapp.com/attachments/996450506388029460/1001119514131447808/Untitled-1.png"},
    ["policeb1"] = {"Moto High Speed Politie", "https://cdn.discordapp.com/attachments/996450506388029460/1001120253796962344/Untitled-1.png"},
    ["policeb2"] = {"Moto Off-Road Politie", "https://cdn.discordapp.com/attachments/996450506388029460/1001122143632900166/Untitled-1.png"},
    ["pbike"] = {"Bicicleta Politie", "https://cdn.discordapp.com/attachments/996450506388029460/1001125517812047903/Untitled-1.png"},
    ["policeinsurgent"] = {"Insurgent D.I.I.C.O.T", "https://cdn.discordapp.com/attachments/1015597677943210054/1137773043003969738/Untitled-1.png"},
    ["polamggtr"] = {"Mercedes AMG GT-R Politie", "https://cdn.discordapp.com/attachments/996450506388029460/1001532749976436857/Untitled-1.png"},
    ["polmp4"] = {"McLaren MP4 Politie", "https://cdn.discordapp.com/attachments/996450506388029460/1001536950261518355/Untitled-1.png"},
    ["lspdunm"] = {"Dodge Charger Unmarked", "https://cdn.discordapp.com/attachments/996450506388029460/1002248108228485262/Untitled-1.png"},
  },

  ["Helipad Politia Romana"] = {
    _config = {vtype = "faction", blip_id = 602, blip_color = 54, marker_id = 34, marker_color = {44, 109, 184, 130}, faction = "Politia Romana"},
    ["polmav"] = {"Elicopter Politia Romana", "https://cdn.discordapp.com/attachments/996450506388029460/1001117133327048775/Untitled-1.png"},
  },

  ["Garaj Dock Politia Romana"] = {
    _config = {vtype = "faction", blip_id = 455, blip_color = 54, marker_id = 35, marker_color = {44, 109, 184, 130}, faction = "Politia Romana"},
    ["jetmax"] = {"Barca Politia Romana", ""},
    ["speeder2"] = {"Barca Politia Romana", ""},
  },
  
  ["Smurd"] = {
    _config = {vtype = "faction", blip_id = 586, blip_color = 75, marker_color = {194, 80, 80, 130}, faction = "Smurd"},
    ["cprotection"] = {"Land Rover Discovery SMURD", "https://cdn.discordapp.com/attachments/996453297932206160/1019693241047720037/cprotection.png"},
		["ghispo3"] = {"Maserati Ghibli SMURD", "https://cdn.discordapp.com/attachments/996453297932206160/1019693167081164841/ghispo3.png"},
		["jp2"] = {"Jeep Wrengler SMURD", "https://cdn.discordapp.com/attachments/996453297932206160/1019694616225783888/jp2.png"},
		["dacia1"] = {"Dacia Duster SMURD", "https://cdn.discordapp.com/attachments/996453297932206160/1019693185565474826/dacia1.png"},
		["rsb_mbsprinter"] = {"Mercedes-Benz Sprinter Ambulanta", "https://cdn.discordapp.com/attachments/996453297932206160/1019693220185243688/rsb_mbsprinter.png"},
		["ems_gs1200"] = {"Motor Smurd", "https://cdn.discordapp.com/attachments/996453297932206160/1027587429080772678/smurdd.png"},
  },

  ["Helipad Smurd"] = {
    _config = {vtype = "faction", blip_id = 602, blip_color = 76, marker_id = 34, marker_color = {194, 80, 80, 130}, faction = "Smurd"},
    ["lguardmav"] = {"Elicopter Smurd", "https://cdn.discordapp.com/attachments/996453297932206160/1004770542798262382/lguardvcrop.png"},
  },

  -- Mafii --
  ["Los Varrios"] = {
    _config = {vtype = "faction", hide_blip = true, marker_color = {255, 255, 255, 130}, faction = "Los Varrios"},
    
  ["escalade"] = {"Cadillac Escalade", "https://cdn.discordapp.com/attachments/996440974815416401/997166718097035294/Untitled-1.png"},
	["evo10"] = {"Mitsubishi Lancer Evolution X", "https://cdn.discordapp.com/attachments/996440974815416401/997167405107261592/Untitled-1.png"},
	["e63svg"] = {"Mercedes-Benz E63 AMG SVG", "https://cdn.discordapp.com/attachments/996441046659637308/997167969933205534/Untitled-1.png"},
	["bmm"] = {"Bentley Mulsanne", "https://cdn.discordapp.com/attachments/996426057383157850/997115509898215504/Untitled-1.png"},
	["yukon"] = {"GMC Yukon", "https://cdn.discordapp.com/attachments/996441046659637308/997168678569263154/Untitled-1.png"},
	["w140"] = {"Mercedes-Benz W140", "https://cdn.discordapp.com/attachments/996441060278546462/997169517321007294/Untitled-1.png"},
	["rrab"] = {"Range Rover SVR Mansory", "https://cdn.discordapp.com/attachments/996441060278546462/997170084508352633/Untitled-1.png"},
	["19s650"] = {"Mercedes-Benz Maybach S650", "https://cdn.discordapp.com/attachments/996444858376016024/997435847693574227/Untitled-1.png"},
	["g63amg6x6"] = {"Mercedes-Benz G63 AMG 6X6", "https://cdn.discordapp.com/attachments/996441060278546462/997171117762547843/Untitled-1.png"},
	["brabus500"] = {"Mercedes-Benz G500 4X4 Brabus", "https://cdn.discordapp.com/attachments/996441060278546462/997171683586756608/Untitled-1.png"},
  },

  ["Camorra"] = {
    _config = {vtype = "faction", hide_blip = true, marker_color = {255, 255, 255, 130}, faction = "Camorra"},
    
  ["escalade"] = {"Cadillac Escalade", "https://cdn.discordapp.com/attachments/996440974815416401/997166718097035294/Untitled-1.png"},
	["evo10"] = {"Mitsubishi Lancer Evolution X", "https://cdn.discordapp.com/attachments/996440974815416401/997167405107261592/Untitled-1.png"},
	["e63svg"] = {"Mercedes-Benz E63 AMG SVG", "https://cdn.discordapp.com/attachments/996441046659637308/997167969933205534/Untitled-1.png"},
	["bmm"] = {"Bentley Mulsanne", "https://cdn.discordapp.com/attachments/996426057383157850/997115509898215504/Untitled-1.png"},
	["yukon"] = {"GMC Yukon", "https://cdn.discordapp.com/attachments/996441046659637308/997168678569263154/Untitled-1.png"},
	["w140"] = {"Mercedes-Benz W140", "https://cdn.discordapp.com/attachments/996441060278546462/997169517321007294/Untitled-1.png"},
	["rrab"] = {"Range Rover SVR Mansory", "https://cdn.discordapp.com/attachments/996441060278546462/997170084508352633/Untitled-1.png"},
	["19s650"] = {"Mercedes-Maybach S650", "https://cdn.discordapp.com/attachments/996444858376016024/997435847693574227/Untitled-1.png"},
	["g63amg6x6"] = {"Mercedes-Benz G63 AMG 6X6", "https://cdn.discordapp.com/attachments/996441060278546462/997171117762547843/Untitled-1.png"},
	["brabus500"] = {"Mercedes-Benz G500 4X4 Brabus", "https://cdn.discordapp.com/attachments/996441060278546462/997171683586756608/Untitled-1.png"},
  },
  
  ["Mala Del Brenta"] = {
    _config = {vtype = "faction", hide_blip = true, marker_color = {255, 255, 255, 130}, faction = "Mala Del Brenta"},
    
  ["escalade"] = {"Cadillac Escalade", "https://cdn.discordapp.com/attachments/996440974815416401/997166718097035294/Untitled-1.png"},
	["evo10"] = {"Mitsubishi Lancer Evolution X", "https://cdn.discordapp.com/attachments/996440974815416401/997167405107261592/Untitled-1.png"},
	["e63svg"] = {"Mercedes-Benz E63 AMG SVG", "https://cdn.discordapp.com/attachments/996441046659637308/997167969933205534/Untitled-1.png"},
	["yukon"] = {"GMC Yukon", "https://cdn.discordapp.com/attachments/996441046659637308/997168678569263154/Untitled-1.png"},
	["19s650"] = {"Mercedes-Maybach S650", "https://cdn.discordapp.com/attachments/996444858376016024/997435847693574227/Untitled-1.png"},
  },

  ["Sureños"] = {
    _config = {vtype = "faction", hide_blip = true, marker_color = {255, 255, 255, 130}, faction = "Sureños"},
    
  ["escalade"] = {"Cadillac Escalade", "https://cdn.discordapp.com/attachments/996440974815416401/997166718097035294/Untitled-1.png"},
	["evo10"] = {"Mitsubishi Lancer Evolution X", "https://cdn.discordapp.com/attachments/996440974815416401/997167405107261592/Untitled-1.png"},
	["e63svg"] = {"Mercedes-Benz E63 AMG SVG", "https://cdn.discordapp.com/attachments/996441046659637308/997167969933205534/Untitled-1.png"},
	["bmm"] = {"Bentley Mulsanne", "https://cdn.discordapp.com/attachments/996426057383157850/997115509898215504/Untitled-1.png"},
	["yukon"] = {"GMC Yukon", "https://cdn.discordapp.com/attachments/996441046659637308/997168678569263154/Untitled-1.png"},
	["w140"] = {"Mercedes-Benz W140", "https://cdn.discordapp.com/attachments/996441060278546462/997169517321007294/Untitled-1.png"},
	["rrab"] = {"Range Rover SVR Mansory", "https://cdn.discordapp.com/attachments/996441060278546462/997170084508352633/Untitled-1.png"},
	["19s650"] = {"Mercedes-Maybach S650", "https://cdn.discordapp.com/attachments/996444858376016024/997435847693574227/Untitled-1.png"},
	["g63amg6x6"] = {"Mercedes-Benz G63 AMG 6X6", "https://cdn.discordapp.com/attachments/996441060278546462/997171117762547843/Untitled-1.png"},
	["brabus500"] = {"Mercedes-Benz G500 4X4 Brabus", "https://cdn.discordapp.com/attachments/996441060278546462/997171683586756608/Untitled-1.png"},
  },

  ["Los Vagos"] = {
    _config = {vtype = "faction", hide_blip = true, marker_color = {255, 255, 255, 130}, faction = "Los Vagos"},
    
  ["escalade"] = {"Cadillac Escalade", "https://cdn.discordapp.com/attachments/996440974815416401/997166718097035294/Untitled-1.png"},
	["evo10"] = {"Mitsubishi Lancer Evolution X", "https://cdn.discordapp.com/attachments/996440974815416401/997167405107261592/Untitled-1.png"},
	["e63svg"] = {"Mercedes-Benz E63 AMG SVG", "https://cdn.discordapp.com/attachments/996441046659637308/997167969933205534/Untitled-1.png"},
	["bmm"] = {"Bentley Mulsanne", "https://cdn.discordapp.com/attachments/996426057383157850/997115509898215504/Untitled-1.png"},
	["yukon"] = {"GMC Yukon", "https://cdn.discordapp.com/attachments/996441046659637308/997168678569263154/Untitled-1.png"},
	["w140"] = {"Mercedes-Benz W140", "https://cdn.discordapp.com/attachments/996441060278546462/997169517321007294/Untitled-1.png"},
	["rrab"] = {"Range Rover SVR Mansory", "https://cdn.discordapp.com/attachments/996441060278546462/997170084508352633/Untitled-1.png"},
	["19s650"] = {"Mercedes-Maybach S650", "https://cdn.discordapp.com/attachments/996444858376016024/997435847693574227/Untitled-1.png"},
	["g63amg6x6"] = {"Mercedes-Benz G63 AMG 6X6", "https://cdn.discordapp.com/attachments/996441060278546462/997171117762547843/Untitled-1.png"},
	["brabus500"] = {"Mercedes-Benz G500 4X4 Brabus", "https://cdn.discordapp.com/attachments/996441060278546462/997171683586756608/Untitled-1.png"},
  },

  ["Araba"] = {
    _config = {vtype = "faction", hide_blip = false, marker_color = {255, 255, 255, 130}, faction = "Araba"},
    
    ['f10m5'] = {"BMW M5 F10", ""},
    ["rmode63s"] = {"Brabus 800 E63S",""},
    ["escalade"] = {"Cadillac Escalade", "https://cdn.discordapp.com/attachments/996440974815416401/997166718097035294/Untitled-1.png"},
    ["brabus500"] = {"Mercedes-Benz G500 4X4 Brabus", "https://cdn.discordapp.com/attachments/996441060278546462/997171683586756608/Untitled-1.png"},
    ["356ac"] = {"Porsche 356 Speedster 1956", ""},
    ["monzasp2"] = {"Ferrari Monza", ""},
    ["2018s650p"] = {"Mercedes-Benz Maybach Limuzina", ""},
    ["ph8m"] = {"Rolls-Royce Phantom", ""},
  },


  ["Grove Street"] = {
    _config = {vtype = "faction", hide_blip = true, marker_color = {255, 255, 255, 130}, faction = "Grove Street"},
    
  ["escalade"] = {"Cadillac Escalade", "https://cdn.discordapp.com/attachments/996440974815416401/997166718097035294/Untitled-1.png"},
	["evo10"] = {"Mitsubishi Lancer Evolution X", "https://cdn.discordapp.com/attachments/996440974815416401/997167405107261592/Untitled-1.png"},
	["e63svg"] = {"Mercedes-Benz E63 AMG SVG", "https://cdn.discordapp.com/attachments/996441046659637308/997167969933205534/Untitled-1.png"},
	["bmm"] = {"Bentley Mulsanne", "https://cdn.discordapp.com/attachments/996426057383157850/997115509898215504/Untitled-1.png"},
	["yukon"] = {"GMC Yukon", "https://cdn.discordapp.com/attachments/996441046659637308/997168678569263154/Untitled-1.png"},
	["w140"] = {"Mercedes-Benz W140", "https://cdn.discordapp.com/attachments/996441060278546462/997169517321007294/Untitled-1.png"},
	["rrab"] = {"Range Rover SVR Mansory", "https://cdn.discordapp.com/attachments/996441060278546462/997170084508352633/Untitled-1.png"},
	["19s650"] = {"Mercedes-Maybach S650", "https://cdn.discordapp.com/attachments/996444858376016024/997435847693574227/Untitled-1.png"},
	["g63amg6x6"] = {"Mercedes-Benz G63 AMG 6X6", "https://cdn.discordapp.com/attachments/996441060278546462/997171117762547843/Untitled-1.png"},
	["brabus500"] = {"Mercedes-Benz G500 4X4 Brabus", "https://cdn.discordapp.com/attachments/996441060278546462/997171683586756608/Untitled-1.png"},
  },

  ["La Nuestra Familia"] = {
    _config = {vtype="car",blipid=229,blipcolor=57,faction="La Nuestra Familia",vehcolor=94},
    
    ["ztype"] = {"Ztype", ""},
    ["btype"] = {"Btype", ""},
    ["nightshade"] = {"Nightshade",""},
    ["guardian"] = {"Guardian", ""},
    ["akuma"] = {"Akuma",""}
  },
}

return cfg