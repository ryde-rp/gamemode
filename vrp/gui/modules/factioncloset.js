const factionCloset = new Vue({
    el: ".faction-closet-layout",
    data: {
        active: false,
        current: "",
        name: "",
        max: 1,
        uniform: 0,
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

        build(data) {
            this.active = true;
            this.uniform = 0;
            this.max = data[1];
            this.current = "";
            this.name = data[0].toUpperCase();
            $(".faction-closet-layout").fadeIn("fast");
        },

        update(current) {
            this.current = current.toUpperCase();
        },

        reset() {
            this.post("resetClosetUniform");
            this.destroy();
        },

        next() {
            if ((this.uniform + 1) > this.max){
                this.uniform = 1;
            } else {
                this.uniform++;
            }
            
            this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
            this.post("changeClosetUniform", [this.uniform]);
        },

        prev() {
            if ((this.uniform - 1) < 1){
                this.uniform = this.max;
            } else {
                this.uniform--;
            }

            this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
            this.post("changeClosetUniform", [this.uniform])
        },

        destroy() {
            this.active = false;
            $(".faction-closet-layout").fadeOut("fast");
            this.post("exitCloset");
        },
    },
})