const factionCalls = new Vue({
	el: ".factioncalls-layout",
	data: {
		active: false,
		page: 'calls',
		logo: "",
		calls: [],
		history: [],
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
		
		takeCall(id, faction) {
			this.post("calls:take", {id: id, faction: faction})
		},
		
		cancelCall(id, faction) {
			this.post("calls:cancel", {id: id, faction: faction})
		},

		setLocation(location) {
			this.post("calls:setLocation", {location: location})
		},
		
		build(calls, logo) {
			this.active = true;
			this.page = 'calls';
			this.calls = calls;
			this.logo = logo;

			$(".factioncalls-layout").fadeIn();
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

		update(calls) {
			this.calls = calls;
		},

		destroy() {
			this.active = false;
			$(".factioncalls-layout").fadeOut();

			this.post("calls:exit");
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

		setPage(onePage) {
			this.page = onePage;
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},
	},
})