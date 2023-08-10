const Banking = new Vue({
	el: ".robbery-interface",
	data: {
        actions: {},
        time: "00:00",
        active: false,
	},
	mounted() {
        window.addEventListener("message", this.onMessage)
	},
	methods: {

        onMessage() {
            if (event.data.action == "UpdateTime") {
                this.time = event.data.time
            }
            if (event.data.action == "ShowActions") {
                if (!this.active) {
                    $(".robbery-interface").fadeIn()
                    this.active = true
                }
            }
            if (event.data.action == "UpdateActions") {
                this.actions = event.data.robberyData
            }
            if (event.data.action == "CloseActions") {
                this.active = false
                $(".robbery-interface").fadeOut();
            }
        },
	},
})