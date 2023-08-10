const meniuProcesare = new Vue({
	el: ".procesare-layout",
	data: {
		active: false,
		recipe: [],
		result: [],
		title: "TRAFICANT DE PULE",
		icon: "fas fa-pills",
		waitTime: "Instant",
		notification: {
			type: 1,
			text: "Salut frate ce mai faci!???"
		},
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

		build(recipe, result, title, icon, time) {
			this.recipe = recipe;
			this.result = result;
			this.title = title;
			this.icon = icon;
			this.waitTime = time;

			this.active = true;
			$(".procesare-layout").fadeIn();
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

		notify(type, text) {
			this.notification = {
				type: type,
				text: text,
			};

			$(".procesare-notification").fadeIn();

			setTimeout(() => {
				$(".procesare-notification").fadeOut();				
			}, 3500);
		},

		processItem() {
			this.post("processItem");
			this.destroy();
		},

		destroy() {
			this.active = false;
			$(".procesare-layout").fadeOut();
			this.post("procesare:exit");
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},
	},
})