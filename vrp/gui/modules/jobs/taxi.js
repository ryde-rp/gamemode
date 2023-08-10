
const taxiCompanyMenu = new Vue({
    el: ".taxi-layout",
    data: {
        active: false,
        ownCompany: false,
        bizName: "",
        bizOwner: "",
        bizCarFare: 0,
        bizPrice: 0,
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
            this.bizName = data.name;
            this.bizOwner = data.owner.name;
            this.ownCompany = data.ownCompany;
            this.bizCarFare = data.carFare;
            this.bizPrice = data.price;
            $(".taxi-layout").fadeIn("fast");
        },
        work() {
            this.post("workAsTaxi", [this.bizName]);

            this.destroy();
        },
        buy() {
            this.post("buyTaxiCompany", [this.bizName]);
            this.destroy();  
        },
        manage() {
            $(".taxi-layout").fadeOut("fast", () => {
                this.post("manageTaxiCompany", [this.bizName]);
            })
        },
        destroy() {
            this.active = false;
            $(".taxi-layout").fadeOut();
            this.post("closeTaxiWork");
        },
    },
})

const taxiManagement = new Vue({
    el: ".taxi-management",
    data: {
        active: false,
        bizName: "",
        bizProfit: 0,
        bizCar: "",
        bizCarLvl: 0,
        bizCarFare: 0,
        bizWorkers: 0,
        bizSellPrice: "",
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
            this.bizName = data.name;
            this.bizProfit = data.profit;
            this.bizCar = data.car;
            this.bizCarLvl = data.carLvl;
            this.bizWorkers = data.workers;
            this.bizCarFare = data.distanceFare;
            $(".taxi-management").fadeIn("fast");
        },

        work() {
            this.post("workAsTaxi", [this.bizName]);

            this.destroy();
        },

        sell() {
            if (this.bizSellPrice.length < 1)
                return false;

            this.post("sellTaxiCompany", [this.bizName, this.bizSellPrice]);    
            this.destroy();
        },

        upgrade() {
            if (this.bizCarLvl >= 3)
                return false;
            
            this.post("upgradeTaxiCar", [this.bizName]);
            this.destroy();
        },

        withdraw() {
            if (this.bizProfit < 1)
                return false;
            
            this.post("withdrawTaxiProfit", [this.bizName]);    
            this.bizProfit = 0;
        },

        destroy() {
            this.active = false;
            this.bizSellPrice = "";
            $(".taxi-management").fadeOut();
            this.post("closeTaxiWork");
        },

    },
})

const taxiCmds = new Vue({
    el: ".taxicmds-layout",
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

            $(".taxicmds-layout").fadeIn("fast");
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
            $("#taxiAlertTitle").text(title);
            $("#taxiAlertText").html(text);

            $(".taxicall-alert-layout").fadeIn("fast");
            soundManager.play("taxi-newcall", 0.05);
            setTimeout(() => {
                $(".taxicall-alert-layout").fadeOut("fast");
            }, 5000);
        },

        destroy() {
            this.active = false;
            $(".taxicmds-layout").fadeOut("fast");
            this.post("closeTaxiWork");
        },

    },
})

const taximeter = new Vue({
    el: "#fpTaxiMeter",
    data: {
        active: false,
        cost: 0,
        time: 0
    },
    methods: {
        build() {
            this.cost = 0;
            this.active = true;
            this.time = 0;
            $("#fpTaxiMeter").fadeIn();
        },
        
        setCost(cost) {
            this.cost = cost;
        },

        setTime(time) {
            this.time = time;
        },

        destroy() {
            this.cost = 0;
            this.active = false;
            this.time = 0;
            $("#fpTaxiMeter").fadeOut();
        },
    }
})