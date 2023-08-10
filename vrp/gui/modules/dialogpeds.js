const dialogPeds = new Vue({
	el: ".dialognpc",
	data: {
      active: false,
      name: "",
      desc: "",
      text: "",
      fields: [
        // {item: "Test", post: "Muie"},
      ],
	},
	mounted() {
		window.addEventListener("keydown", this.onKey)
	},
	methods: {
		onKey() {
			var theKey = event.code;

			if (theKey == "Escape" && this.active)
				this.destroy(true);
		},

		async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},

		use(action, addedArgs) {
	        if (action == "closePedDialog"){
	          return this.destroy();
	        }

	        this.destroy();
	        setTimeout(() => {
				this.post("useDialogPedOption", {post: action, args: addedArgs});
			}, 50)
		},

		build(fields, text, desc, name) {
	        this.active = true;
	        this.fields = fields;
	        this.text = text;
	        this.desc = desc;
	        this.name = name;

	        $(".dialognpc").fadeIn();
		},

		destroy() {
        	$(".dialognpc").fadeOut(250);
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
			this.post("closePedDialog");
	        
	        setTimeout(() => {
	          this.active = false;
	          this.fields = [];
	        }, 250)
		}
	},
})