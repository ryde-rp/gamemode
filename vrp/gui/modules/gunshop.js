const gunStore = new Vue({
	el: ".gunshop-menu",
	data: {
		active: false,
		items: [
	        {display: "ROZETĂ", item: "body_knuckle", price: 2000},
	        {display: "STICLĂ SPARTĂ", item: "body_bottle", price: 1500},
	        {display: "BÂTĂ", item: "body_bat", price: 2500},
	        {display: "RANGĂ", item: "body_crowbar", price: 2500},
	        {display: "PUMNAL", item: "body_dagger", price: 3000},
	        {display: "LANTERNĂ", item: "body_flashlight", price: 1000},
	        {display: "CROSĂ DE GOLF", item: "bodygolfclub", price: 2500},
	        {display: "CIOCAN", item: "body_hammer", price: 2500},
	        {display: "TOPOR", item: "body_hatchet", price: 3500},
	        {display: "CUȚIT", item: "body_knife", price: 3750},
	        {display: "MACETĂ", item: "body_machete", price: 4000},
	        {display: "TAC DE BILIARD", item: "body_poolcue", price: 2500},
	        {display: "BRICEAG", item: "body_switchblade", price: 4500},
	        {display: "CHEIE", item: "body_wrench", price: 2500},
      	],
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
			$(".gunshop-menu").fadeIn();
			
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

		destroy() {
			this.active = false;
			$(".gunshop-menu").fadeOut();

	        this.post("setFocus", {state: false});
		},

		use(theItem) {
        	this.post("vRPgunshop:getGun", {item: theItem});
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		}
	}
})