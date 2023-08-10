const testDrive = new Vue({
	el: ".testdrive-timer",
	data: {
		seconds: 0,
		model: "",
		interval: false,
	},
	methods: {
		build(model) {
			$(".testdrive-timer").fadeIn();
			this.seconds = 60;
			this.model = model;
			
			this.interval = setInterval(() => {
				this.seconds--;
			}, 1000);

			setTimeout(() => {
				this.destroy();
				clearInterval(this.interval);
				this.interval = false;
			}, 60000);
		},

		destroy() {
			$(".testdrive-timer").fadeOut();
			this.seconds = 0;
			this.model = "";
		},
	},
})