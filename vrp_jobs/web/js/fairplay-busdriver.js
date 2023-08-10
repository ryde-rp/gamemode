var BusDriver = new Vue({
    el: ".bus-container",
    data: {
        userSkill: 1,
        selectedSkill: 1,
        jobActive: false,
    },
    methods:{
        startBus: function() {
            this.Post("startBus", {skill: this.selectedSkill});
            $(".bus-container").fadeOut();
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
                $(".bus-container").fadeOut();
                $(".jobs-container").fadeOut();
                this.Post("CloseBus", {close: true});
            }
        },
        SelectSkil(skil) {
            this.selectedSkill = skil;
            if (this.userSkill < skil) return;
            if (skil == 1) {
                $(".skill-1").addClass("active");
                $(".skill-2").removeClass("active");
                $(".skill-3").removeClass("active");
                $(".skill-1").removeClass("unlocked");

                if (this.userSkill == 2) {
                    $(".skill-2").addClass("unlocked");
                } else if (this.userSkill == 3) {
                    $(".skill-2").addClass("unlocked");
                    $(".skill-3").addClass("unlocked");
                }
            } else if (skil == 2) {
                $(".skill-1").removeClass("active");
                $(".skill-2").addClass("active");
                $(".skill-3").removeClass("active");
                $(".skill-1").addClass("unlocked");
                $(".skill-2").removeClass("unlocked");

                if (this.userSkill == 3) {
                    $(".skill-1").addClass("unlocked");
                    $(".skill-3").addClass("unlocked");
                }
            } else if (skil == 3) {
                $(".skill-1").removeClass("active");
                $(".skill-2").removeClass("active");
                $(".skill-3").addClass("active");

                $(".skill-1").addClass("unlocked");
                $(".skill-2").addClass("unlocked");
                $(".skill-3").removeClass("unlocked");

            }
        },
        StopJob() {
            this.Post("job:quit", {job: "busdriver"});
            $(".bus-container").fadeOut();
            $(".jobs-container").fadeOut();
        },
        onMessage() {
            let data = event.data;
            if (data.action == "OpenBus") {
                $(".bus-container").fadeIn();
                $(".jobs-container").fadeIn();
                this.jobActive = data.jobActive;
                this.UpdateSkills(data.skill);
            }
        },
        UpdateSkills: function(skill) {
            this.userSkill = skill;
            if (skill == 1) {
                this.SelectSkil(1);
            } else if (skill == 2) {
                $(".skill-1").addClass("unlocked");
               this.SelectSkil(2);
            } else if (skill == 3) {
                $(".skill-1").addClass("unlocked");
                $(".skill-2").addClass("unlocked");
                this.SelectSkil(3);
            }
        }
    },
    mounted() {
        window.addEventListener("keydown", this.onKey)
        window.addEventListener('message', this.onMessage)
      },      
})

