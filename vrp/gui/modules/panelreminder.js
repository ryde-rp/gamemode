const panelReminder = new Vue({
	el: ".panel-reminder-layout",
	data: {
		active: false,
		readmore: false,
		code: 255235,
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

		build(code) {
			this.active = true;
			this.code = code;

			$(".panel-reminder-layout").fadeIn();
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

		destroy() {
			this.active = false;

			$(".panel-reminder-layout").fadeOut();
	        this.post("setFocus", {state: false});
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

		togReadingPage() {
			this.readmore = !this.readmore;
		},

		copyCode() {
			const el = document.createElement('textarea');
			el.value = this.code;
			el.setAttribute('readonly', '');
			el.style.position = 'absolute';
			el.style.left = '-9999px';
			document.body.appendChild(el);
			el.select();
			document.execCommand('copy');
			document.body.removeChild(el);
		},

		redirectMe() {
			window.invokeNative('openUrl', 'https://panel.fairplay-rp.ro');
		},
	},
})