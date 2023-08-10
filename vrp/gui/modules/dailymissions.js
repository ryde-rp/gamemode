const dailymissions = new Vue({
    el: ".dailymissions-layout",
    data: {
        active: false,
        timerType: 1,
        ore: 0,
        minute: 0,
        missions: {},
        showReward: false
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

        build(missions,reward) {
            this.missions = missions;
            if (!this.active){
                this.active = true;
                console.log(reward);
                $("#fairplayRewardH").html(reward == 1 && "X2 PAYDAY" || reward == 2 && "50% JOB BOOST" || reward == 3 && "25% JOB BOOST");
                $(".fairplayReward-DailyReward").fadeIn(500);
                setTimeout(() =>{
                    this.destroy();
                },5000);
            }
        },

        buildTimer(tog,type) {
            // console.log(tog,type);
            if (!tog){
                if (type == 1){
                    // console.log(1);
                    $("#fairplayReward-PayDayX2").fadeOut(500);
                } else {
                    // console.log(2);
                    $("#fairplayReward-50JobBoost").fadeOut(500);
                }
            } else {
                this.timerType = type
                if (type == 1){
                    // console.log(3);
                    $("#fairplayReward-PayDayX2").fadeIn(500);
                } else {
                    // console.log(4);
                    $("#fairplayReward-JobBoost").html(type == 2 && "50% JOB BOOST" || "25% JOB BOOST");
                    $("#fairplayReward-50JobBoost").fadeIn(500);
                }
            }
        },

        updateDailyTimer(ore,minute){
            this.ore = ore
            this.minute = minute
        },

        destroy() {
            this.active = false;
            $(".fairplayReward-DailyReward").fadeOut(500);
        },
    },
})