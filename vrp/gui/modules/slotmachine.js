let _slotScript
let spinAudio = new Audio("https://cdn.fairplay-rp.ro/slots/spin.ogg");
let winAudio = new Audio("https://cdn.fairplay-rp.ro/slots/success.ogg");
let gambleAudio = new Audio("https://cdn.fairplay-rp.ro/slots/suspans_gamble.ogg");
let isSpining = false;
let lastSpinType = "normal";
(()=>{
    let randoms = {};
    let rows = {};
    let winElements = [];
    let preparingDublaje = false;
    let incercareDublare = false;
    _slotScript = new Vue({
        el: "#slots_container",
        data() {
            return {
                active: false,
                dubleaza: false,
                dublajeScreen: false,
                castig: 0,
                history: {
                    0: 1,
                    1: 1,
                    2: 2,
                    3: 1,
                    4: 1
                }
            }
        },
        mounted() {
            for (let i = 0; i < 5; i++){
                rows[i] = {};
                rows[i].element = document.getElementById('row'+(i+1));
                rows[i].machine = new SlotMachine(rows[i].element, {
                    direction: "down",
                    active: 0,
                    delay: 250,
                    randomize(){
                        return randoms[i];
                    }
                });
            }
            $("#slots_container").hide();
            window.addEventListener("keydown", this.onKey)
        },
        methods: {
            onKey() {
                if (!this.preparingDublaje){
                    var theKey = event.code;
                    if (theKey == "Escape" && this.active){
                        if (this.dubleaza && this.dublajeScreen){
                            $("#dublaje_pacanele").fadeOut();
                            this.dubleaza = false;
                            this.dublajeScreen = false;
                        } else {
                            this.destroy();
                        }
                            
                    }
                    if (theKey == "Space" && this.active){
                        this.dubleaza = false;
                        if (this.dublajeScreen){
                            this.dublajeScreen = false;
                            $("#dublaje_pacanele").fadeOut();
                        }
                        event.preventDefault();
                        this.spin();
                    }
                }
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
                $("#slots_container").fadeIn(500);
            },

            dubleazaBaaa(carte){
                let this_container = this;
                if (!incercareDublare){
                    incercareDublare = true;
                    $.post("https://vrp/dublaje", JSON.stringify({carte: carte})).done(function(data){
                        this_container.history = (data.history).reverse();
                        data = data.data;
                        gambleAudio.pause();
                        document.getElementById("carte_mijloc").style = `animation: none;background: url(https://cdn.fairplay-rp.ro/slots/${data[0] == 1 && "neagra.png" || "rosie.png"});background-size: 100% 100%;`;
                        let win = false;
                        if (data[1] == 1){win = true 
                            let winSound = new Audio("https://cdn.fairplay-rp.ro/slots/win_gamble.ogg");
                            winSound.play();
                        };
                        setTimeout(() => {
                            document.getElementById("carte_mijloc").style = "";
                            if (data[1] == 2){
                                this_container.dubleaza = false;
                                this_container.dublajeScreen = false;
                                $("#dublaje_pacanele").fadeOut();
                            } else if (win) {
                                this_container.castig = this_container.castig * 2
                                gambleAudio.play();
                            }
                            incercareDublare = false;
                        }, 500);
                    })
                }
            },

            bet(action){
                $.post("https://vrp/updateBet", JSON.stringify({action: action}))
            },

            spin(spinType){
                let this_container = this;
                if (spinType == "VIP" && this.dubleaza){
                    if (this.dublajeScreen){
                        $.post("https://vrp/incasare", JSON.stringify({})).done(function(data) {
                            $("#dublaje_pacanele").fadeOut();
                            gambleAudio.pause();
                            this_container.dubleaza = false;
                            this_container.dublajeScreen = false;
                        })
                        return
                    }
                    if (!preparingDublaje){
                        preparingDublaje = true;
                        $.post("https://vrp/vreaDublaj", JSON.stringify({})).done(function(data) {
                            this_container.history = (data.history).reverse();
                            this_container.castig = data.suma;
                            preparingDublaje = false;
                            this_container.dublajeScreen = true;
                            $("#dublaje_pacanele").fadeIn(500);
                            gambleAudio.loop = true;
                            gambleAudio.play();
                        })
                    }
                    return
                }
                this.dubleaza = false;
                if (!spinType){spinType = lastSpinType};
                lastSpinType = spinType;
                $.post("https://vrp/spinSlot", JSON.stringify({spinType: spinType})).done(function(data) {
                    let rand = data.rand;
                    let wins = data.wins;
                    let poateDubla = data.poateDubla;
                    randoms = rand;
                    for (const key in winElements) {
                        if (Object.hasOwnProperty.call(winElements, key)) {
                            const element = winElements[key];
                            element.classList.remove("redWin");
                            element.classList.remove("yellowWin");
                            delete winElements[key];
                        }
                    }
                    let i = 0;
                    let finishedShuffles = 0;
                    let spins = 10;
                    let seWin = false;
                    spinAudio.loop = true;
                    spinAudio.play();
                    for (const key in rows) {
                        if (Object.hasOwnProperty.call(rows, key)) {
                            const element = rows[key];
                            i = i + 1;
                            setTimeout(() => {
                                let spinStopAudio = new Audio("https://cdn.fairplay-rp.ro/slots/stop2.ogg");
                                element.machine.shuffle(spins,(index)=>{
                                    finishedShuffles = finishedShuffles + 1;
                                    spinAudio.pause();
                                    spinStopAudio.play();
                                    if (wins[key]){
                                        let objs = element.element.querySelectorAll("div");
                                        if (wins[key][(0).toString()]){
                                            objs[element.machine.visibleTile+1].classList.add("redWin");
                                            winElements.push(objs[element.machine.visibleTile+1]);
                                            seWin = true;
                                        }
                                        if (wins[key][(1).toString()]){
                                            objs[element.machine.visibleTile+2].classList.add("redWin");
                                            winElements.push(objs[element.machine.visibleTile+2]);
                                            seWin = true;
                                        }
                                        if (wins[key][(2).toString()]){
                                            objs[element.machine.visibleTile+3].classList.add("redWin");
                                            winElements.push(objs[element.machine.visibleTile+3]);
                                            seWin = true;
                                        }
                                    }

                                    if (finishedShuffles == 5){
                                        if (seWin){
                                            if (poateDubla){
                                                this_container.dubleaza = true;
                                            }
                                            winAudio.play();
                                        }
                                        $.post("https://vrp/finishSpin", JSON.stringify({}))
                                    }
                                });
                            }, (250*i)); 
                        }
                    }
                });
            },

            destroy() {
                this.active = false;
                $("#slots_container").fadeOut(500);
                $.post("https://vrp/outSlots", JSON.stringify({}))
            },
        },
    })
}
)()