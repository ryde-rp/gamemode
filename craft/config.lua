Config = {}

Config.Crafting = {
	["Rafinarie"] = {
		coordinates = vector3(1109.3220214844,-2007.7229003906,31.035270690918), 
		tableName = 'Rafinarie', 
		onlyMafie =  false,
		crafts = {
			['argintnefinisat'] = {
				item = 'argintnefinisat', 
				itemName = "Argint Nefinisat",
				amount = 1,
				time = 5000, 
				dm_event = "dm:27",
				recipe = { 
					{"Minereu Argint", 'minereuargint', 5, true},
			    }, 
			},
			['aurnefinisat'] = {
				item = 'aurnefinisat',
				itemName = "Aur Nefinisat",
				amount = 1,
				time = 5000, 
				recipe = { 
					{"Minereu Aur", 'minereuaur', 5, true}, 
				},
			},
			['sulf'] = {
				item = 'sulf',
				itemName = "Sulf",
				amount = 1,
				time = 5000, 
				recipe = { 
					{"Minereu Sulf", 'minereusulf', 5, true}, 
				},
			},
			['fiernefinisat'] = {
				item = 'fiernefinisat',
				itemName = "Fier Nefinisat",
				amount = 1,
				time = 5000, 
				recipe = { 
					{"Minereu Fier", 'minereufier', 5, true}, 
				},
			},
			['aluminiu_nefinisat'] = {
				item = 'aluminiu_nefinisat',
				itemName = "Alumniniu Nefinisat",
				amount = 1,
				time = 5000, 
				recipe = { 
					{"Minereu Alumniniu", 'minereualuminiu', 5, true}, 
				},
			},
			['cupru_nefinisat'] = {
				item = 'cupru_nefinisat',
				itemName = "Cupru Nefinisat",
				amount = 1,
				time = 5000, 
				recipe = { 
					{"Minereu Cupru", 'minereucupru', 5, true}, 
				},
			}
		},
	},
	["Finisare"] = {
		coordinates = vector3(1071.0108642578,-2006.2154541016,32.083843231201), 
		tableName = 'Finisare Materiale', 
		onlyMafie = false,
		crafts = {
			['lingoudeargint'] = {
				item = 'lingoudeargint',
				itemName = "Lingou Argint",
				amount = 1,
				time = 5000, 
				recipe = { 
					{"Argint Nefinisat", 'argintnefinisat', 5, true},
			    }, 
			},
			['lingoudeaur'] = {
				item = 'lingoudeaur',
				itemName = "Lingou Aur",
				amount = 1,
				time = 5000, 
				recipe = { 
					{"Aur Nefinisat", 'aurnefinisat', 5, true}, 
				},
			},
			['suruburi'] = {
				item = 'suruburi', 
				itemName = "Suruburi",
				amount = 20,
				time = 5000, 
				recipe = { 
					{"Otel", 'otel', 1, true}, 
				},
			},
			['otel'] = {
				item = 'otel',
				itemName =  "Otel",
				amount = 1,
				time = 5000, 
				dm_event = "dm:28",
				recipe = { 
					{"Fier Nefinisat",  'fiernefinisat', 5, true},
					{"Carbune", 'carbune', 5, true}, 
				},
			},
			['prafdepusca'] = {
				item = 'prafdepusca',
				itemName = "Praf de Pusca",
				amount = 25,
				time = 5000, 
				recipe = { 
					{"Sulf", 'sulf', 1, true},
					{"Carbune", 'carbune', 2, true}, 
				},
			},
		},
	},
	-- [CRAFTING ARME]
	["Crafting-Arme"] = {
		coordinates = vector3(4983.0805664063,-5299.5151367188,-0.82316720485687), 
		tableName = 'Crafting Arme', 
		onlyMafie =  false,
		crafts = {
			['body_machinepistol'] = {
				item = 'body_machinepistol',
				itemName = "TEC-9",
				amount = 1,
				time = 40000, 
				recipe = { 
				   {"Parte Superioara", "partesuperioara", 1, true},
				   {"Parte Inferioara", "parteinferioara", 1, true},
				   {"Componente TEC-9", "componentetec9", 1, true},
				},
			},
			['body_assaultsmg'] = {
				item = 'body_assaultsmg',
				itemName = "Assault SMG",
				amount = 1,
				time = 40000, 
				recipe = { 
					{"Parte Superioara", "partesuperioara", 1, true},
					{"Parte Inferioara", "parteinferioara", 1, true},
				   	{"Componente Assault SMG", "componenteassaultsmg", 1, true},
				   	{"Teava de Pusca","tavapusca", 1, true},
				},
			},
			['body_pistolmk2'] = {
				item = 'body_pistolmk2',
				itemName = "Pistol MK2",
				amount = 1,
				time = 40000, 
				recipe = { 
				   {"Parte Superioara", "partesuperioara", 1, true},
				   {"Parte Inferioara", "parteinferioara", 1, true},
				   {"Componente Pistol MK2", "componentepistolmk2", 1, true},
				},
			},
			['body_combatpistol'] = {
				item = 'body_combatpistol',
				itemName = "Combat Pistol",
				amount = 1,
				time = 40000, 
				recipe = { 
					{"Parte Superioara", "partesuperioara", 1, true},
					{"Parte Inferioara", "parteinferioara", 1, true},
				  	{"Componente Combat Pistol", "componentecombatpistol", 1},
				},
			},
			['body_microsmg'] = {
				item = 'body_microsmg',
				itemName = "Micro SMG",
				amount = 1,
				time = 40000, 
				recipe = { 
					{"Parte Superioara", "partesuperioara", 1, true},
					{"Parte Inferioara", "parteinferioara", 1, true},
				  	{"Componente Micro SMG", "componentemicrosmg", 1},
				},
			},
			['body_compactrifle'] = {
				item = 'body_compactrifle',
				itemName = "Compact Rifle",
				amount = 1,
				time = 40000, 
				recipe = { 
					{"Parte Superioara", "partesuperioara", 1, true},
					{"Parte Inferioara", "parteinferioara", 1, true},
				  	{"Componente Compact Rifle", "componentecompactrifle", 1},
				},
			},
			['body_ak47'] = {
				item = 'body_ak47',
				itemName = "AK47",
				amount = 1,
				time = 40000, 
				recipe = { 
					{"Parte Superioara", "partesuperioara", 1, true},
					{"Parte Inferioara", "parteinferioara", 1, true},
				   	{"Componente AK47", "componenteak47", 1, true},
				   	{"Teava de Pusca","tavapusca", 1, true},
				},
			},
		}
	},
	-- Crafting Gloante
	["Crafting-Gloante"] = {
		coordinates = vector3(4979.2041015625,-5298.4633789063,-0.82316738367081), 
		tableName = 'Crafting Gloante', 
		onlyMafie =  true,
		crafts = {
			['ammo_9mm'] = {
				item = 'ammo_9mm',
				itemName = "Gloante 9MM",
				amount = 10,
				time = 15000, 
				recipe = { 
					{"Praf de Pusca", "prafdepusca", 25, true},
					{"Metal Fragmentat", "metal_fragmentat", 15, true},
				},
			},
			['ammo_762'] = {
				item = 'ammo_762',
				itemName = "Gloante 7.62MM",
				amount = 10,
				time = 15000, 
				recipe = { 
					{"Praf de Pusca", "prafdepusca", 50, true},
					{"Metal Fragmentat", "metal_fragmentat", 15, true},
				},
			},
			-- ['ammo_556'] = {
			-- 	item = 'ammo_556',
			-- 	itemName = "Gloante 5.56MM",
			-- 	amount = 10,
			-- 	time = 15000,  
			-- 	recipe = { 
			-- 		{"Praf de Pusca", "prafdepusca", 50, true},
			-- 		{"Metal Fragmentat", "metal_fragmentat", 15, true},
			-- 	},
			-- },
			['ammo_45acp'] = {
				item = 'ammo_45acp',
				itemName = "Gloante .45ACP",
				amount = 10,
				time = 15000,  
				recipe = { 
					{"Praf de Pusca", "prafdepusca", 50, true},
					{"Metal Fragmentat", "metal_fragmentat", 15, true},
				},
			},
		}
	},
	["Crafting-Compontente"] = {
		coordinates = vector3(4983.6303710938,-5295.1020507813,-0.823166847229), 
		tableName = 'Crafting Componente', 
		onlyMafie =  true,
		crafts = {
			['partesuperioara'] = {
				item = 'partesuperioara',
				itemName = "Parte Superioara",
				amount = 1,
				time = 15000, 
				recipe = { 
					{"Otel", 'otel', 2, true},
					{"Suruburi", 'suruburi', 25, true},
			    },
			},
			['parteinferioara'] = {
				item = 'parteinferioara',
				itemName = "Parte Inferioara",
				amount = 1,
				time = 15000, 
				recipe = { 
					{"Otel", 'otel', 2, true},
					{"Suruburi", 'suruburi', 30, true},
			    },
			},
			['tavapusca'] = {
				item = 'tavapusca',
				itemName = "Teava de Pusca",
				amount = 1,
				time = 15000, 
				recipe = { 
					{"Otel", 'otel', 4, true},
			    },
			},
			['componentepistolmk2'] = {
				item = 'componentepistolmk2',
				itemName = "Componente Pistol MK2",
				amount = 1,
				time = 15000, 
				recipe = { 
					{"Otel",'otel', 2, true},
					{"Surburi", 'suruburi', 25, true},
			    },
			},
			['componenteassaultsmg'] = {
				item = 'componenteassaultsmg',
				itemName = "Componente Assault SMG",
				amount = 1,
				time = 15000,  
				recipe = { 
					{"Otel", 'otel', 4, true},
					{"Suruburi", 'suruburi', 30, true},
			    },
			},
			['componentecombatpistol'] = {
				item = 'componentecombatpistol',
				itemName = "Componente Combat Pistol",
				amount = 1,
				time = 15000, 
				recipe = { 
					{"Otel", 'otel', 2, true},
					{"Suruburi", 'suruburi', 25, true},
			    },
			},
			['componenteak47'] = {
				item = 'componenteak47',
				amount = 1,
				itemName = "Componente AK47",
				time = 15000,  
				recipe = { 
					{"Otel", 'otel', 4, true},
					{"Suruburi", 'suruburi', 35, true},
			    },
			},
			['componentetec9'] = {
				item = 'componentetec9',
				itemName = "Componente TEC-9",
				amount = 1,
				time = 15000, 
				recipe = { 
					{"Otel", 'otel', 2, true},
					{"Suruburi", 'suruburi', 35, true},
			    },
			},
			["componentemicrosmg"] = {
				item = "componentemicrosmg",
				itemName = "Componente Micro SMG",
				amount = 1,
				time = 15000, 
				recipe = { 
					{"Otel", 'otel', 2, true},
					{"Suruburi", 'suruburi', 40, true},
			    },
			},
			["componentecompactrifle"] = {
				item = "componentecompactrifle",
				itemName = "Componente Compact Rifle",
				amount = 1,
				time = 15000, 
				recipe = { 
					{"Otel", 'otel', 3, true},
					{"Suruburi", 'suruburi', 25, true},
			    },
			},
		},
	},
	["Crafting-Ilegale"] = {
		coordinates = vector3(4989.0556640625,-5302.35546875,-0.82316696643829), 
		tableName = 'Crafting Device-uri Ilegale', 
		onlyMafie =  true,
		crafts = {
			["proximity_mine"] = {
				item = "proximity_mine",
				itemName = "Bomba Termica",
				amount = 1,
				time = 15000, 
				recipe = { 
					{"Cupru Nefinisat", 'cupru_nefinisat', 6, true},
					{"Aluminiu Nefinisat", 'aluminiu_nefinisat', 6, true},
					{"Praf de Pusca", "prafdepusca", 200, true},
					{"Banda Adeziva", "banda_adeziva", 1, true},
			    },
			},
			["righeist_baros"] = {
				item = "righeist_baros",
				itemName = "Baros [HEIST RIG]",
				amount = 1,
				time = 15000, 
				recipe = { 
					{"Otel", 'otel', 2, true},
					{"Fier Nefinisat",  'fiernefinisat', 10, true},
			    },
			},
			["righeist_cleste"] = {
				item = "righeist_cleste",
				itemName = "Cleste [HEIST RIG]",
				amount = 1,
				time = 15000, 
				recipe = { 
					{"Otel", 'otel', 3, true},
					{"Fier Nefinisat",  'fiernefinisat', 9, true},
			    },
			},
		}
	},

	["Crafting-armealbe"] = {
		coordinates = vector3(3065.3732910156,2207.3215332031,3.5802810192108), 
		tableName = 'Crafting Arme Albe', 
		onlyMafie =  false,
		crafts = {
            ["body_knife"] = {
                item = "body_knife",
                itemName = "Cutit",
                amount = 3,
                time = 15000, 
                recipe = { 
                    {"Lemn prelucrat", 'lemn_prelucrat', 1, true},
                    {"Otel", 'otel', 1, true},
                },
            },
            ["body_bat"] = {
                item = "body_bat",
                itemName = "Bata",
                amount = 3,
                time = 15000, 
                recipe = { 
                    {"Lemn prelucrat", 'lemn_prelucrat', 6, true},
                },
            },
            ["body_knuckle"] = {
                item = "body_knuckle",
                itemName = "Rozeta",
                amount = 3,
                time = 15000, 
                recipe = { 
                    {"Otel", 'otel', 1, true},
                },
            },
            ["body_machete"] = {
                item = "body_machete",
                itemName = "Maceta",
                amount = 3,
                time = 15000, 
                recipe = { 
                    {"Lemn prelucrat", 'lemn_prelucrat', 2, true},
                    {"Otel", 'otel', 2, true},
                },
            },
            ["body_switchblade"] = {
                item = "body_switchblade",
                itemName = "Briceag",
                amount = 3,
                time = 15000, 
                recipe = { 
                    {"Lemn prelucrat", 'lemn_prelucrat', 1, true},
                    {"Otel", 'otel', 1, true},
                },
            },
            ["body_dagger"] = {
                item = "body_dagger",
                itemName = "Cutit Pumnal",
                amount = 3,
                time = 15000, 
                recipe = { 
                    {"Lemn prelucrat", 'lemn_prelucrat', 1, true},
                    {"Otel", 'otel', 2, true},
                },
            },
            ["body_battleaxe"] = {
                item = "body_battleaxe",
                itemName = "Topor De Lupta",
                amount = 3,
                time = 15000, 
                recipe = { 
                    {"Lemn prelucrat", 'lemn_prelucrat', 2, true},
                    {"Otel", 'otel', 3, true},
                },
            },
            ["body_wrench"] = {
                item = "body_wrench",
                itemName = "Cheie Franceza",
                amount = 3,
                time = 15000, 
                recipe = { 
                    {"Otel", 'otel', 1, true},
                },
            },
            ["body_crowbar"] = {
                item = "body_crowbar",
                itemName = "Ranga",
                amount = 3,
                time = 15000, 
                recipe = { 
                    {"Otel", 'otel', 3, true},
                },
            },
        }
	},
	['Crafting-prelucrarelemn'] = {
		coordinates = vec3(-511.47817993164,5305.376953125,80.239891052246),
		tableName = 'Prelucrare lemn', 
		onlyMafie =  false,
		crafts = {
			["lemn_prelucrat"] = {
				item = "lemn_prelucrat",
				itemName = "Lemn prelucrat",
				amount = 1,
				time = 15000, 
				recipe = { 
					{"Lemn", 'lemn', 10, true},
			    },
			},
		}
	},
	['Topitorie'] = {
		coordinates = vec3(1084.9104003906,-2002.6480712891,31.380714416504),
		tableName = "Topitorie",
		onlyMafie = false,
		crafts = {
			["lingoudeaur"] = {
				item = "lingoudeaur",
				itemName = "Lingou de aur",
				amount = 1,
				time = 15000, 
				dm_event = {"dm:36","dm:37"},
				recipe = { 
					{"Lant de aur", 'lant_de_aur', 1, true},
			    },
			},
		}
	}
}