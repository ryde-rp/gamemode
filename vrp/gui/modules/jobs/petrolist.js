const petrolist = new Vue({
    el: ".petrolist-container",
    data: {
        active: false,
        userSkill: 1,
        selectedSkill: 1,
        jobActive: false,
    },
    methods: {
        async post(url, data = {}) {
            const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            
            return await response.json();
        },
        onKey() {
            var theKey = event.code;
            if (theKey == 'Escape' && this.active)
                this.destroy();
        },
        build(data) {
            this.active = true;
            this.userSkill = data.skill;
            this.selectedSkill = data.skill;
            this.jobActive = data.jobActive;
            this.UpdateSkills(data.skill);
            $(".petrolist-container").fadeIn();
            $(".jobs-container").fadeIn();
        },
        destroy() {
            if (!this.active) return;
            this.active = false;
            $(".petrolist-container").fadeOut();
            $(".jobs-container").fadeOut();
            this.post('jobExit', {exit: true})
        },
        startpetrolist: function() {
            this.post('startJob', {job: 'Petrolist', skill: this.selectedSkill});
            this.destroy();
        },
        StopJob() {
            this.post('quitJob', {job: 'Petrolist'});
            this.destroy();
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
    },
    mounted() {
        window.addEventListener('keydown', this.onKey)
    },
})


const petrolistChoice = new Vue({
    el: ".fairplay-petrolistjob",
    data: {
        active: false,
        skill: 1
    },
    methods: {
        async post(url, data = {}) {
            const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });
            
            return await response.json();
        },
        onButton(res){
            this.active = false;
            $(".fairplay-petrolistjob").fadeOut();
            
            this.post('petrolistExit', {response: res})
        },
        onKey() {
            var theKey = event.code;
            if (theKey == 'Escape' && this.active)
                this.destroy(true);
        },
        build(data) {
            console.log(data.skill);
            this.skill = data.skill;
            this.active = true;
            $(".fairplay-petrolistjob").fadeIn();
        },
        destroy(cancel) {
            if (!this.active) return;
            this.active = false;
            $(".fairplay-petrolistjob").fadeOut();
            
            this.post('petrolistExit', {response: !cancel})
        },
    },
    mounted() {
        window.addEventListener('keydown', this.onKey)
    },
})