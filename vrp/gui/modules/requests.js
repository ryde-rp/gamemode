const initialDiagTitle = "CONFIRMARE NECESARĂ";
const requestManager = new Vue({
	el: "#all-requests",
	data: {
		keyData: {
			active: false,
			key: "E",
			text: "",
		},
		promptData: {
			active: false,
			title: "",
			fields: {},
		},
		dialogData: {
			active: false,
			identifier: false,
			title: initialDiagTitle,
			text: "",
		},
	},
	mounted() {
		window.addEventListener("keydown", this.onKey)
	},
	methods: {
		onKey() {
			var theKey = event.code;
			var fields = this.promptData.fields;
			var hide = this.hidePrompt
			if (theKey == "Escape") {
				if (this.promptData.active){
					fetch(`https://${GetParentResourceName()}/prompt`, {
						method: 'POST',
						headers: {'Content-Type': 'application/json; charset=UTF-8'},
						body: JSON.stringify({
						result: fields || {}
						})
					}).then(resp => resp.json()).then(resp => {
						if (resp == "ok")
							hide();
					});
				}	
			}
		},
		requestKey(key, text) {
			this.keyData.active = true;
			this.keyData.key = key;
			this.keyData.text = text;

			$(".interaction-wrap").fadeIn();
		},

		createDialog(id, title, text) {
			$(".request-container").fadeIn();
			this.dialogData.active = true;
	        this.dialogData.identifier = id;
	        this.dialogData.title = title || initialDiagTitle;
	        this.dialogData.text = text;
		},

		createPrompt(title, fields) {
	        this.promptData.active = true;
	        $(".prompt-layout").fadeIn();
	        this.promptData.title = title;
	        this.promptData.fields = fields;
		},

		useDialog(response) {
			if (!this.dialogData.active) return;
			
			fetch(`https://${GetParentResourceName()}/request`, {
			  method: 'POST',
			  headers: {'Content-Type': 'application/json; charset=UTF-8'},
			  body: JSON.stringify({
			    id: this.dialogData.identifier,
			    ok: response || false
			  })
			}).then(resp => resp.json()).then(resp => {
			  if (resp == "ok")
			  	this.hideDialog();
			});
		},

		usePrompt() {
			var responses = this.promptData.fields || {};

	        fetch(`https://${GetParentResourceName()}/prompt`, {
		        method: 'POST',
		        headers: {'Content-Type': 'application/json; charset=UTF-8'},
		        body: JSON.stringify({
		          result: responses
		        })
		    }).then(resp => resp.json()).then(resp => {
		        if (resp == "ok")
		            this.hidePrompt();
		    });
	    },

		hideKey() {
			this.keyData.active = false;
			$(".interaction-wrap").fadeOut("fast");
		},

		hideDialog() {
			this.dialogData.active = false;
			$(".request-container").fadeOut();
			this.dialogData.identifier = false;
		},

		hidePrompt() {
			$(".prompt-layout").fadeOut(200);
			
			setTimeout(() => {
				this.promptData.active = false
				this.promptData.fields = {}
			}, 190);
		},

	},
})