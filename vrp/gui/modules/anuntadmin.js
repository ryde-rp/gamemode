const adminAnnounce = new Vue({
	el: ".admin-announcement",
	data: {
		admin: "",
		text: "",
	},
	methods: {
		build(admin, text) {
			this.admin = admin;
			this.text = text;

			$(".admin-announcement").fadeIn();

			setTimeout(() => {
				$(".admin-announcement").fadeOut();
			}, 7500);
		},
	},
})