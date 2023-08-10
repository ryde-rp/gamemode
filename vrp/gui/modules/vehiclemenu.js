const vehicleMenu = new Vue({
	el: ".vehicle-menu",
	data: {
		active: false,
		page: 1,
	},
	mounted() {
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

		build() {
			this.active = true;
			this.page = 1;
			$(".vehicle-menu").fadeIn();
		},

		destroy() {
			this.active = false;
			$(".vehicle-menu").fadeOut();

	        this.post("setFocus", {state: false});
		},

		nextPage() {
			this.page++;
	        if (this.page > 3){
	          this.page = 1;
	        }

			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

		prevPage() {
	        this.page--;
	        if (this.page < 1){
	          this.page = 1;
	        }

			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

		setSeat(newSeat) {
	        this.post("vehmenu$switchSeat", {seat: newSeat});
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

		togEngine() {
			this.post("vehmenu$switchEngine");
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

		togDoor(theDoor) {
			this.post("vehmenu$toggleDoor", {door: theDoor});
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

	    togWindow(theWindow) {
	        this.post("vehmenu$toggleWindow", {windowId: theWindow});
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
	    },

	    togAllDoors() {
	    	this.post("vehmenu$toggleAllDoors");
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
	    },

	    togLocking() {
	    	this.post("vehmenu$togLocking");
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
	    },

	    togLights() {
	    	this.post("vehmenu$togLights");
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
	    },

	}
})