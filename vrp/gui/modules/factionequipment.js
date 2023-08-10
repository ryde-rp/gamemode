const factionEquipment = new Vue({
	el: ".faction-equipment",
	data: {
		active: false,
		category: "weapons",
		faction: "Smurd",
	   	items: {
	     'Politia Romana': {
	       'weapons': [
	         {id: "body_heavypistol", name: 'Heavy Pistol'},
	         {id: "body_pistol50", name: 'Pistol .50'},
	         {id: "body_stungun", name: 'Stungun'},

	         {id: "body_smg", name: "Submachine Gun"},
	         {id: "body_combatpdw", name: "Combat PDW"},
	         {id: "body_militaryrifle", name: "Military Rifle"},
	         {id: "body_bullpuprifle_mk2", name: "Bullpup Rifle MK2"},
	         {id: "body_specialcarbine_mk2", name: "Special Carbine MK2"},

	         {id: "body_nightstick", name: 'Baston'},
	         {id: "body_flashlight", name: "Lanterna"},
			 {id: "body_smoke", name: "Smoke"}
	       ],
		
	       'attachments': [
	         {id: "suppressor", name: 'Supresor'},
	         {id: "grip", name: 'Grip'},
	         {id: "lanterna", name: 'Lanterna'},
	         {id: "extended_clip", name: "Extended Clip"},
	         {id: "scope", name: "Scope"},
	       ],

	       'utilities': [
	         {id: "body_armor", name: 'Vesta Anti-Glont'},
	         {id: "medkit", name: 'Trusa Medicala'},
	         {id: "adrenalina", name: 'Injectie Adrenalina'},
	         {id: "bandajmic", name: 'Bandaj Mic'},
	         {id: "bandajmare", name: "Bandaj Mare"},
			 {id: "radio", name: "Statie Radio"},
			 {id: "geanta", name: "Geanta"},
			 {id: "setscafandru", name: "Set Scafandru"}
	       ],
	     },

	     'Smurd': {
	       'weapons': [
	         {id: "body_stungun", name: 'Stungun'},
	         {id: "body_flashlight", name: "Lanterna"},
	       ],

	       'utilities': [
			 {id: "body_armor", name: 'Vesta Anti-Glont'},
	         {id: "medkit", name: 'Trusa Medicala'},
	         {id: "adrenalina", name: 'Injectie Adrenalina'},
	         {id: "bandajmic", name: 'Bandaj Mic'},
	         {id: "bandajmare", name: "Bandaj Mare"},
			 {id: "radio", name: "Statie Radio"},
	       ],
	     },

		 'BIZ': {
			'utilities': [
			  {id: "medkit", name: 'Trusa Medicala'},
			  {id: "bandajmic", name: 'Bandaj Mic'},
			  {id: "bandajmare", name: "Bandaj Mare"},
			  {id: "repair_kit", name: "Trusa de Reparatii"},

			//   2 medkit, 6 bandaje mici, 3 bandaje mari, 2 truse reparatii
			],
		  },
	   	},
	},
	mounted(){
		window.addEventListener("keydown", this.onKey)
	},
	methods: {
		onKey() {
			var theKey = event.code;
			if (theKey == "Escape" && this.active)
				this.destroy();
		},

		async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},

		build(usedGroup) {
			if (!usedGroup)
				return;

			this.active = true;
			this.faction = usedGroup;
			$(".faction-equipment").fadeIn();
		},

		destroy() {
			$(".faction-equipment").fadeOut();
	        this.active = false;
	        this.post("setFocus", {state: false});
	        
	        this.category = "weapons";
		},

		use(theItem, itemDisplay, itemCost){
	        this.post("fe:takeItem", {item: theItem, group: this.faction, itemLabel: itemDisplay, price: itemCost || 0});
		},

		setCategory(tab) {
			this.category = tab || "weapons";
		},
	},
})