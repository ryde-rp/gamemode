const deathScreen = new Vue({
	el: ".death-screen",
	data: {
		respawnTime: "29:56",
		selfTime: "04:50",
		canRespawn: false,
	},
	methods: {
		build() {
			$(".death-screen").fadeIn();
		},

		async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},

		update(respawnTime, selfTime, canRespawn) {
			this.respawnTime = respawnTime;
			this.selfTime = selfTime;
			this.canRespawn = canRespawn;
		},

		respawn() {
			this.post("respawn");
		},

		destroy() {
			this.canRespawn = false;
			$(".death-screen").fadeOut();
		},
	}
})