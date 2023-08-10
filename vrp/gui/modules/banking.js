const Banking = new Vue({
	el: ".bank-layout",
	data: {
		active: false,
		money: 0,
		hasFaction: false,
		factionLeader: false,
		factionBudget: 0,
		identity: {
			name: "NECUNOSCUT",
			iban: 0,
		},
		notification: {
			type: 1,
			text: "Aceasta este o notificare simpla, cu rezultat OK",
		},
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

		build(money, name, iban, faction, leader, budget) {
			this.active = true;
			this.money = money;
			this.hasFaction = faction;
			this.factionLeader = leader;
			this.factionBudget = budget;
			this.identity = {
				name: name,
				iban: iban,
			};

			$(".bank-layout").fadeIn();
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

		update() {
			this.post("getBankMoney").then(result => {
				this.money = parseInt(result);
			});
		},

		notify(type, text) {
			this.notification = {
				type: type,
				text: text,
			};

			$(".bank-info").fadeOut();
			$(".bank-notification").fadeIn();

			setTimeout(() => {
				$(".bank-notification").fadeOut();				
				$(".bank-info").fadeIn();
			}, 2500);
		},

		destroy() {
			this.active = false;
			$(".bank-layout").fadeOut();
			this.post("exitBanking");
			this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
		},

		fastAction(ft) {
			switch(ft) {
				case "fpcoins":
					this.post("exchangeCoins", {amt: 5}).then(result => {
						this.notify(result[0], result[1]);
					});

					this.update();
				break

				case "withdraw":
					this.post("withdrawMoney", {amt: 100}).then(result => {
						this.notify(result[0], result[1]);
					});

					this.update();
				break

				case "deposit":
					this.post("depositMoney", {amt: 100}).then(result => {
						this.notify(result[0], result[1]);
					});

					this.update();
				break
			}
		},

		exchangeCoins(amt) {
			this.post("exchangeCoins", {amt: amt}).then(result => {
				this.notify(result[0], result[1]);
			});

			this.update();
		},

		click(at) {
			switch(at) {
				case "withdraw":
					var amt = $("#bank-withdraw-amt").val() || 0

					this.post("withdrawMoney", {amt: amt}).then(result => {
						this.notify(result[0], result[1]);
					});

					this.update();
				break
			
				case "deposit":
					var amt = $("#bank-deposit-amt").val() || 0

					this.post("depositMoney", {amt: amt}).then(result => {
						this.notify(result[0], result[1]);
					});

					this.update();
				break

				case "transfer":
					var amt = $("#bank-transfer-amt").val() || 0
					var iban = $("#bank-transfer-id").val()

					this.post("transferMoney", {iban: iban, amt: amt}).then(result => {
						this.notify(result[0], result[1]);
					});

					this.update();
				break

				case "factionWithdraw":
					if (!this.factionLeader){
						return this.notify(2, "Doar liderul poate retrage bani din fondul factiunii.");
					}

					var amt = $("#bank-factionWithdraw-amt").val() || 0

					this.post("factionWithdraw", {amt: amt}).then(result => {
						this.notify(result[0], result[1]);
					});

					this.post("getFactionBudget").then(result => {
						this.factionBudget = parseInt(result);
					});
				break

				case "factionDeposit":
					var amt = $("#bank-factionDeposit-amt").val() || 0

					this.post("factionDeposit", {amt: amt}).then(result => {
						this.notify(result[0], result[1]);
					});

					this.post("getFactionBudget").then(result => {
						this.factionBudget = parseInt(result);
					});
				break
			}
		},

	},
})