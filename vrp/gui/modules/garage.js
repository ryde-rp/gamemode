const basic_garage = new Vue({
	el: ".garage-wrapper",
	data() {
		return {
			active: false,
			title: "",
			filteredVehs: {},
			userVehicles: [],
		}
	},
	mounted() {
		this.filteredVehs = this.userVehicles;

		window.addEventListener('keydown', this.onKey)
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

		compare(a, b) {
	        if (a.name < b.name)
	          return -1;
	        if (a.name > b.name)
	          return 1;

	        return 0;
		},

		build(vehs, title) {
			this.active = true;
			this.title = title;
			this.userVehicles = vehs.sort(this.compare);
			this.filteredVehs = this.userVehicles;
			
			$(".garage-wrapper").fadeIn();
		},

		destroy() {
			this.active = false;
			$(".garage-wrapper").fadeOut();
	        this.post("setFocus", {state: false});
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

		spawnVehicle(car, carType) {
			this.destroy();

			this.post("spawnGarageVehicle", {model: car, vtype: carType});
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

		despawnVehicle() {
			this.destroy();

			this.post("despawnGarageVehicle", {garage: this.title});
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},
	},
})

function searchGarage(value){
	basic_garage.filteredVehs = basic_garage.userVehicles.filter(vehicle => {
		return vehicle.name.toLowerCase().includes(value.toLowerCase())
	})
}