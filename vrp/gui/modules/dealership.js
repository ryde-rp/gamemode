const dealership = new Vue({
	el: ".dealership-layout",
	data() {
		return {
			active: false,
			selectionData: {
				active: false,
				name: "",
				price: 0,
				stats: {
					brake: 1,
					acceleration: 1,
					traction: 1,
				},
			},
			categoryIcons: {
				'dube': 'fa-van-shuttle',
				'camioane': 'fa-truck-front',
				'remorci': 'fa-truck-ramp-box',
				'motociclete': 'fa-motorcycle',
				'avioane': 'fa-plane',
				'elicoptere': 'fa-helicopter',
				'barci': 'fa-sailboat',
				'premium': 'fa-star',
			},
			categoryData: {
				active: false,
				icon: 'fa-car-rear',
				filteredVehs: {},
				vehicles: {
					// 'test': {name: "Lamborghini Veneno", price: 500000},
				}
			},
			colorCarousel: [
				{r: 161, g: 40, b: 48},
				{r: 34, g: 119, b: 250},
				{r: 106, g: 13, b: 173},
				{r: 75, g: 139, b: 59},
				{r: 255, g: 127, b: 0},
				{r: 0, g: 0, b: 0},
				{r: 255, g: 0, b: 0},
				{r: 119, g: 181, b: 254},
				{r: 207, g: 0, b: 99},
				{r: 166, g: 214, b: 8},
				{r: 250, g: 253, b: 15},	
				{r: 255, g: 255, b: 255},
			],
		}
	},
	mounted() {
		this.categoryData.filteredVehs = this.categoryData.vehicles;
		window.addEventListener("keydown", this.onKey)
	},
	methods: {
		onKey() {
			var theKey = event.code;

			if (theKey == "Escape" && this.active)
				if (this.categoryData.active) {
					this.categoryData.active = false;
					this.selectionData.active = false;
					this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
					this.post("deleteDealershipVehicle");
				} else {
					this.destroy();
				}
		},

		async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},

		build() {
			this.active = true;

			if (this.selectionData.active) {
				this.selectionData.active = false;
			}

			if (this.categoryData.active) {
				this.categoryData.active = false;
			}

			$(".dealership-layout").fadeIn();
			this.post("deleteDealershipVehicle");
		},

		destroy() {
			this.active = false;
			this.post("closeDealership");
			this.post("deleteDealershipVehicle");
			$(".dealership-layout").fadeOut();
		},

		setCategory(newCategory) {
			this.post("getDealershipVehicles", {category: newCategory}).then(result => {
				this.categoryData.vehicles = result;
				this.categoryData.filteredVehs = this.categoryData.vehicles;

				if (result.length < 1)
					console.log("INFO: Categoria nu are vehicule setate in config, te rugam sa raportezi aceasta problema.")
			});

			this.categoryData.icon = this.categoryIcons[newCategory] || 'fa-car-rear';
			this.categoryData.active = newCategory;
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

		testVehicle() {
			var veh = this.selectionData.active;
			if (!veh)
				return;

			this.destroy();
			this.post("testDealershipVehicle", {model: veh, category: this.categoryData.active})
		},

		paintVehicle(r, g, b, type) {
			this.post("setDealershipColors", {r:r,g:g,b:b,paint:type});
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

		payVehicle() {
			this.post("buyDealershipVehicle", {model: this.selectionData.active, category: this.categoryData.active});
			this.destroy();
		},

		selectVehicle(model) {
			var vehicleInfo = this.categoryData.vehicles[model];

			if (!vehicleInfo)
				return;

			if (this.selectionData.active == model){
				this.selectionData.active = false;
				this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
				this.post("deleteDealershipVehicle");
				return;
			}

			this.selectionData.active = model;
			this.selectionData.price = vehicleInfo.price;
			this.selectionData.name = vehicleInfo.name;

			this.post("createDealershipVehicle", {model: model}).then(result => {
				this.selectionData.stats.acceleration = result.acceleration;
				this.selectionData.stats.brake = result.breaking;
				this.selectionData.stats.traction = result.traction;
			});
			
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		}
	}
})

function searchDealership(value){
	var filterEntries = Object.entries(dealership.categoryData.vehicles);

	dealership.categoryData.filteredVehs = Object.fromEntries(filterEntries.filter(([key, vehicle]) => {
		return vehicle.name.toLowerCase().includes(value.toLowerCase())
	}));
}