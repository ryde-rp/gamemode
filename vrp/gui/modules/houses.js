const houses = new Vue({
	el: "#house_container",
	data() {
		return {
			active: false,
			houseId: 0,
			pret_chirie: 0,
			house_price: 0,
			owner_id: "State",
			owner_phone: "0763",
			interior_liber: false,
			user_id: -76,
			profit_chirie: 0,
			chiriasi: {
				[-76]: true
			},
			lavanzare: false,
			buyable: false
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

		build(data) {
			this.active = true;
			this.pret_chirie = data.house_info.chirie
			this.house_price = data.house_info.pret
			this.owner_id = data.house_info.owner_id
			this.chiriasi = data.house_info.chiriasi
			this.user_id = data.user_id
			this.owner_phone = data.house_info.phone
			this.interior_liber = data.house_info.interior_liber
			this.profit_chirie = data.house_info.profit_chirie
			this.lavanzare = data.house_info.lavanzare
			this.houseId = data.houseId
			this.buyable = data.house_info.buyable
			
			$("#house_container").fadeIn();
		},

		buy(){
			this.post("houses:buy", {});
			this.destroy();
		},

		sell(){
			this.post("houses:sell", {});
			this.destroy();
		},

		removesell(){
			this.post("houses:removesell", {});
			this.destroy();
		},

		rent(){
			this.post("houses:rent", {});
			this.destroy();
		},

		modificaChirie(){
			this.post("houses:schimbaChirie", {});
			this.destroy();
		},

		colecteazaChirie(){
			this.post("houses:colecteazaChirie", {});
			this.destroy();
		},

		chiriasi_f(){
			this.post("houses:chiriasi", {});
			this.destroy();	
		},

		enterHouse(){
			this.post("houses:enter", {});
			this.destroy();
		},

		anuleazaChirie(){
			this.post("houses:anuleazaChirie", {});
			this.destroy();
		},

		destroy() {
			this.active = false;
			$("#house_container").fadeOut();
	        this.post("setFocus", {state: false});
		},
	},
})