const moneyWasher = new Vue({
	el: ".moneywash-layout",
	data() {
		return {
			active: false,
			usedBiz: 0,
			bizData: {
				faction: "Corleone Family",
				dateOfTax: "12.12.2022",
				name: "GUNSHOP LS(1)",
				type: "LOS SANTOS AMMO NATION",
				desc: `Customers of the store 24/7 can buy goods needed for life.
	                    In this store you can find everything: from a SIM card to a backpack.
	                    The business owner himself regulates the price for the goods sold.
	                    Delivery of items is carried out by truckers, the manager must make a timely order for the receipt of goods`,
			},
		}
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

		onError(error) {

		},

		async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},

		build(data, id) {
			this.active = true;
			this.bizData = data;
			this.usedBiz = id;

			$(".moneywash-layout").fadeIn();
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

		destroy() {
			this.active = false;
			$(".moneywash-layout").fadeOut();
	        this.post("setFocus", {state: false});
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

		payTax() {
			this.destroy();
			this.post("payWasher", {biz: this.usedBiz});
		},

		washMoney() {
			if (this.bizData.suspended) return this.onError("suspended");

			this.destroy();
			this.post("washMoney", {biz: this.usedBiz});
		},

	},
})