const basic_markets = new Vue({
    el: ".markets-layout",
    data: {
        active: false,
        name: "",
        gtype: "",
        balance: 0,
        owner: false,
        products: {},
        basket: [],
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

        truncate(text, max) {
            return text.substr(0,max-1)+(text.length>max?'...':''); 
        },

        build(data) {
            this.active = true;
            this.gtype = data[0];
            this.products = data[1];
            this.balance = data[2];
            this.name = data[3];
            this.owner = data[4];
            this.basket = [];
            $(".markets-layout").fadeIn();
        },

        isItemInCart(name) {
            var data = this.basket.filter((item) => item.item == name);
            return data[0] ? data[0] : false;
        },

        remove(name) {
            var data = this.basket.filter((item) => item.item == name);
            data[0].amount--;

            if (data[0].amount <= 0) {
                this.basket.splice(this.basket.indexOf(data[0].item), 1);
            }
        },

        add(name) {
            if (this.isItemInCart(name)) {
                var data = this.basket.filter((item) => item.item == name);
                data[0].amount++;
            } else {
                this.basket.push({
                    item: name,
                    label: this.products[name].label,
                    amount: 1,
                })
            }
        },

        pay(method) {
            if (this.basket.length > 0){
                this.post("exitMarket", [this.basket, method, this.gtype]);
                this.destroy();
            }
        },

        destroy() {
            this.active = false;
            $(".markets-layout").fadeOut();
            this.post("exitMarket");
        },
    },
})