const eastershop = new Vue({
	el: "#fairplayEasterShop",
	data: {
		active: false,
        oua: 0,
        hovered: false,
        hoverPrices: {
            1: 40,
            2: 65,
            3: 200,
            4: 145
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

		async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},

        openPoluarea(){
            // console.log("hmm");
            window.invokeNative('openUrl', 'https://youtu.be/jAa58N4Jlos');  
        },

        buy(){
            this.post("eastershop", {buy: this.hovered});
            this.destroy();
        },

		build(oua) {
            this.hovered = false;
            this.oua = oua;
            this.active = true;
			$("#fairplayEasterShop").fadeIn();
		},
        
		destroy() {
			this.active = false;
			$("#fairplayEasterShop").fadeOut();
            this.playing = false;
            this.post("eastershop", {exit: true});
		},

	},
})