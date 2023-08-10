const factionStore = new Vue({
	el: ".faction-store-layout",
	data: {
		active: false,
      	faction: "Marabunta Grande",
      	type: "weapons",
      	items: [],
	},
	mounted() {
		window.addEventListener("keydown", this.onKey)
	},
	methods: {
		onKey() {
			var theKey = event.code;

			if (theKey == "Escape" && this.active)
				this.destroy()
		},

		async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},

		build(itemList, type, faction) {
	        this.type = type;
	        this.items = itemList;
	        this.faction = faction;
	        this.active = true;

	        $(".faction-store-layout").fadeIn();
		},

		destroy() {
	        $(".faction-store-layout").fadeOut();
        	this.active = false;
	        this.post("setFocus", {state: false});

	        setTimeout(() => {
	          this.type = "weapons";
	          this.items = {};
	        }, 350)
		},

		buy(theItem, itemPrice) {
	        var amm = $("#buyVal_" + theItem).val();

	        if (amm && amm != null) {
	          this.post("fs$buyItem", {item: theItem, amount: amm || 1, price: itemPrice || 0})
	        }
		}
	},
})