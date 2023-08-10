var GlovoDelivery = new Vue({
    el: ".glovo-container",
    data: {
        jobActive: false,
    },
    methods:{
        startglovo: function() {
            this.Post("startGlovo", {skill: this.selectedSkill});
            $(".glovo-container").fadeOut();
            $(".jobs-container").fadeOut();
        },
        async Post(url, data = {}) {
            const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            
            return await response.json();
        },
        onKey() {
            var theKey = event.code;
            if(theKey == "Escape") {
                $(".glovo-container").fadeOut();
                $(".jobs-container").fadeOut();
                this.Post("CloseGlovo", {close: true});
            }
        },
        onMessage() {
            let data = event.data;
            if (data.action == "OpenGlovo") {
                $(".glovo-container").fadeIn();
                $(".jobs-container").fadeIn();
                this.jobActive = data.jobActive;
            }
        },
        StopJob() {
            this.Post("job:quit", {job: "Glovo"});
            $(".glovo-container").fadeOut();
            $(".jobs-container").fadeOut();
        },
    },
    mounted() {
        window.addEventListener("keydown", this.onKey)
        window.addEventListener('message', this.onMessage)
      },      
});
