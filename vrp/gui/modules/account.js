const accountStats = new Vue({
    el: ".account-layout",
    data: {
        active: false,
        page: "profile",
        user_id: 0,
        username: "Proxy",
        sex: "m",
        userObj: {
            faction: "Corleone Family",
            accountLvl: "Silver",
            lastHours: 21,
            totalHours: 123,
        },
        userWarns: [
            {admin: "Proxy (3)", reason: "Salmane sami sugi pula iei la muie huaa hotule"},
            {admin: "Proxy (3)", reason: "Salmane sami sugi pula iei la muie huaa hotule"},
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
        
        build(user_id, username, sex, userObj, userWarns) {
            this.active = true;
            this.user_id = user_id;
            this.username = username;
            this.sex = sex;
            this.userObj = userObj;
            this.userWarns = userWarns;

            $(".account-layout").fadeIn("fast");
            this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
        },

        setPage(page) {
            this.page = page;
        },

        destroy() {
            this.active = false;
            $(".account-layout").fadeOut();
	        this.post("setFocus", {state: false});
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
        },
    },
})