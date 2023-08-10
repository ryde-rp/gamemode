const hints = new Vue({
	el: ".action-hint",
	data: {
		text: "",
	},
	methods: {
		build(text, timeout = 5000){

			this.text = text;
			$(".action-hint").fadeIn("fast");

			setTimeout(() => {
				$(".action-hint").fadeOut("fast");
			}, timeout);
		}
	},
})