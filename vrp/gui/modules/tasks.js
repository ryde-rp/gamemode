const Tasks = new Vue({
	el: "#tasks-interface",
	data: {
        actions: {},
        time: "00:00",
        active: false,
        title: "",
	},
	mounted() {},
	methods: {
        updateTime(time){
            this.time = time;
        },
        showActions(){
            $("#tasks-interface").fadeIn()
        },
        updateActions(actions){
            this.actions = actions
        },
        updateTitle(title){
            this.title = title;
        },
        closeActions(){
            $("#tasks-interface").fadeOut();
        },
	},
})