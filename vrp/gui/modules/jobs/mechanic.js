const mechanic = new Vue({
    el: ".mechanic-container",
    data: {
        active: false,
        jobActive: false,
    },
    methods: {
        onKey() {
            var theKey = event.code;
            if (theKey == 'Escape' && this.active)
                this.destroy();
        },
        build(data) {
            this.active = true;
            this.jobActive = data.jobActive;
            $(".mechanic-container").fadeIn();
            $(".jobs-container").fadeIn();
        },
        destroy() {
            if (!this.active) return;
            this.active = false;
            $(".mechanic-container").fadeOut();
            $(".jobs-container").fadeOut();
            this.post('jobExit', {exit: true})
        },
        async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},
        startmechanic: function() {
            this.post('startJob', {job: 'Mecanic'});
            this.destroy();
        },
        StopJob() {
            this.post('quitJob', {job: 'Mecanic'});
            this.destroy();
        },
    },
    mounted() {
        window.addEventListener('keydown', this.onKey)
    },
})

const mechanicCmds = new Vue({
    el: ".mechaniccmds-layout",
    data: {
        active: false,
        total: 0,
        cmdList: {},
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
            this.total = data[0];
            this.cmdList = data[1];

            $(".mechaniccmds-layout").fadeIn("fast");
        },

        update(data) {
            this.total = data[0];
            this.cmdList = data[1];
        },

        accept(cmdId){
            this.destroy();
            this.post("acceptTaxiCommand", [cmdId]);
        },

        showAlert(title, text) {            
            $("#mechanicAlertTitle").text(title);
            $("#mechanicAlertText").html(text);

            $(".mechaniccall-alert-layout").fadeIn("fast");
            soundManager.play("taxi-newcall", 0.05);
            setTimeout(() => {
                $(".mechaniccall-alert-layout").fadeOut("fast");
            }, 5000);
        },

        destroy() {
            this.active = false;
            $(".mechaniccmds-layout").fadeOut("fast");
            this.post("closeTaxiWork");
        },

    },
})