const investment = new Vue({
	el: ".investment-system",
	data: {
        active: false,
        activeInvest: false,
        InvestData: {},
        userHours: 0,

        investitii: {
            1: {
                text: "Aceasta investitie iti poate aduce un profit net in valoare de 5.000$ intr-o ora",
                time: "1 ORA",
                img: "https://cdn.fairplay-rp.ro/recovery/investitie1.png",
                investitie: "5.000",
                profit: "5.000",
            },
            2: {
                text: "Aceasta investitie iti poate aduce un profit net in valoare de 12.500$ in 2 ore",
                time: "2 ORE",
                img: "https://cdn.fairplay-rp.ro/recovery/investitie2.png",
                investitie: "12.500",
                profit: "12.500",
            },
            3: {
                text: "Aceasta investitie iti poate aduce un profit net in valoare de 20.000$ in 3 ore",
                time: "3 ORE",
                img: "https://cdn.fairplay-rp.ro/recovery/investitie3.png",
                investitie: "20.000",
                profit: "20.000",
            },
            4: {
                text: "Aceasta investitie iti poate aduce un profit net in valoare de 27.500$ in 7 ore",
                time: "7 ORE",
                img: "https://cdn.fairplay-rp.ro/recovery/investitie5.png",
                investitie: "27.500",
                profit: "27.500",
            },
            5: {
                text: "Aceasta investitie iti poate aduce un profit net in valoare de 37.500$ in 9 ore",
                time: "9 ORE",
                img: "https://cdn.fairplay-rp.ro/recovery/investitie6.png",
                investitie: "37.500",
                profit: "37.500",
            },
            // 6: {
            //     text: "Aceasta investitie iti poate aduce un profit net in valoare de 50.000$ in 6 ore",
            //     time: "6 ORE",
            //     img: "https://cdn.fairplay-rp.ro/recovery/investitie4.png",
            //     investitie: "50.000",
            //     profit: "50.000",
            // },
            // 7: {
            //     text: "Aceasta investitie iti poate aduce un profit net in valoare de 100.000$ in 7 ore",
            //     time: "7 ORE",
            //     img: "https://cdn.fairplay-rp.ro/recovery/investitie9.png",
            //     investitie: "100.000",
            //     profit: "100.000",
            // },
            // 8: {
            //     text: "Aceasta investitie iti poate aduce un profit net in valoare de 200.000$ in 8 ore",
            //     time: "8 ORE",
            //     img: "https://cdn.fairplay-rp.ro/recovery/investitie7.png",
            //     investitie: "200.000",
            //     profit: "200.000",
            // },
            // 9: {
            //     text: "Aceasta investitie iti poate aduce un profit net in valoare de 225.000$ in 9 ore",
            //     time: "9 ORE",
            //     img: "https://cdn.fairplay-rp.ro/recovery/investitie8.png",
            //     investitie: "225.000",
            //     profit: "225.000",
            // },
            // 10: {
            //     text: "Aceasta investitie iti poate aduce un profit net in valoare de 375.000$ in 10 ore",
            //     time: "10 ORE",
            //     img: "https://cdn.fairplay-rp.ro/recovery/investitie10.png", 
            //     investitie: "375.000",
            //     profit: "375.000",
            // },
            // 11: {
            //     text: "Aceasta investitie iti poate aduce un profit net in valoare de 475.000$ in 12 ore",
            //     time: "12 ORE",
            //     img: "https://cdn.fairplay-rp.ro/recovery/investitie11.png",
            //     investitie: "475.000",
            //     profit: "475.000",
            // },
        }
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

        GetInvestTime() {
            const numberFormat = new Intl.NumberFormat("us-US", {style: 'decimal', maximumFractionDigits: 4, minimumFractionDigits: 2});
            return numberFormat.format(this.InvestData.investTime - this.userHours)
        },

        GetInvestMoney() {
            let moneyFormat = new Intl.NumberFormat("us-US", {style: 'currency', currency: "USD", maximumFractionDigits: 0, minimumFractionDigits: 0});
            return moneyFormat.format(Math.floor(this.InvestData.investMoney));
        },

		build(data, ore) {
            if (data) {
                this.activeInvest = true;
                this.InvestData =  data;
                this.userHours = ore;
            } else {
                this.activeInvest = false;
            }

            this.active = true;
			$(".investment-system").fadeIn();
		},

        MakeInvest(index) {
            this.destroy();
            this.post("makeInvest", {invest: index})
        },

		destroy() {
			this.active = false;
			$(".investment-system").fadeOut();
            this.post("closeInvestment", {exit: true})
		},

	},
})