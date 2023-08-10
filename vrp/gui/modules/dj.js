const dj = new Vue({
	el: "#fairplay-djscript",
	data: {
		active: false,
        title: "",
        playing: "",
        requesting: "",
        history: {},
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

		build(currentlyPlaying,history) {
            this.active = true;
            this.playing = currentlyPlaying;
            this.fetchSongName();
            this.history = history.reverse();
			$("#fairplay-djscript").fadeIn();
			// this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

        fetchSongName(play) {
            let comp = this;
            if(this.playing){
                $.getJSON(
                'https://noembed.com/embed?url=',
                {
                    format: 'json',
                    url: comp.playing,
                },
                function (jsonData) {
                    let title = jsonData.title
                    comp.title = title;
                    if (play){
                        comp.post("djboot", {changeUrl: comp.playing, name: title});
                    }
                }
                )
            } else {
                comp.title = "Nume melodie.."
            }
        },

        requestChange(){
            this.requesting = $("#djboot-input").val();
        },

        requestAccept(){
            this.changeSong(this.requesting);
            this.requesting = "";
        },

        changeSong(url) {
            this.playing = url;
            this.fetchSongName(true);
        },

        stopPlay() {
            this.post("djboot", {stopPlay: true})
        },

        volumeUp() {
            this.post("djboot", {vup: true})
        },

        volumeDown() {
            this.post("djboot", {vdown: true})
        },

		destroy() {
			this.active = false;
			$("#fairplay-djscript").fadeOut();
            this.playing = false;
            this.post("djboot", {exit: true});
            this.fetchSongName();
		},

	},
})