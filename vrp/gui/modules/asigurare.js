const AsigurareAuto = new Vue({
    el: "#asigurare_container",
    data: {
        active: false,
        expire: "NECUNOSCUT",
        until: "NECUNOSCUT",
        detinator: "NECUNOSCUT",
        model: "NECUNOSCUT",
        plate: "NECUNOSCUT"
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
            this.active = true
            this.expire = data.expire
            this.until = data.until
            this.detinator = data.detinator
            this.model = data.model
            this.plate = data.plate
            let comp = this; 
            $("#asigurare_container").fadeIn(500);
            setTimeout(() => {
               comp.destroy();
            }, 6000);
        },

        destroy(){
            $("#asigurare_container").fadeOut(500);
        }
    },
})

const Rovinieta = new Vue({
    el: "#rovinieta_container",
    data: {
        active: false,
        expire: "NECUNOSCUT",
        until: "NECUNOSCUT",
        detinator: "NECUNOSCUT",
        detinator_id: 0,
        model: "NECUNOSCUT",
        plate: "NECUNOSCUT"
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

        formatValabil(){
            return (this.expirat && "<font color = 'red'>EXPIRAT</font>") || "VALABIL"
        },

        build(data) {
            this.active = true;
            this.expire = data.expire
            this.until = data.until
            this.detinator = data.detinator
            this.model = data.model
            this.plate = data.plate
            this.detinator_id = data.detinator_id
            this.expirat = data.expirat
            let comp = this; 
            $("#rovinieta_container").fadeIn(500);
            setTimeout(() => {
               comp.destroy();
            }, 6000);
        },

        destroy(){
            $("#rovinieta_container").fadeOut(500);
        }
    },
})