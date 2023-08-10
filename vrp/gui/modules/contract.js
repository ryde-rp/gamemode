window.requestAnimFrame = (function (callback) {
    return window.requestAnimationFrame ||
        window.webkitRequestAnimationFrame ||
        window.mozRequestAnimationFrame ||
        window.oRequestAnimationFrame ||
        window.msRequestAnimaitonFrame ||
        function (callback) {
            window.setTimeout(callback, 1000 / 60);
        };
})();

let canvas
let ctx
let drawing = false;
let clearCanvas

$(document).ready(function () {
    canvas = document.getElementById("sig-canvas");
    ctx = canvas.getContext("2d");
    ctx.strokeStyle = "#222222";
    ctx.lineWidth = 4;

    var mousePos = {
        x: 0,
        y: 0
    };
    var lastPos = mousePos;


    function getMousePos(canvasDom, mouseEvent) {
        var rect = canvasDom.getBoundingClientRect();
        return {
            x: mouseEvent.clientX - rect.left,
            y: mouseEvent.clientY - rect.top
        }
    }

    function renderCanvas() {
        if (drawing) {
            ctx.moveTo(lastPos.x, lastPos.y);
            ctx.lineTo(mousePos.x, mousePos.y);
            ctx.stroke();
            // console.log(lastPos.x, mousePos.x);
            lastPos = mousePos;
        }
    }

    (function drawLoop() {
        requestAnimFrame(drawLoop);
        renderCanvas();
    })();

    canvas.width = (document.body.clientHeight * 0.5490);
    canvas.height = (document.body.clientHeight * 0.18);

    function reportWindowSize() {
        canvas.width = (document.body.clientHeight * 0.5490);
        canvas.height = (document.body.clientHeight * 0.18);
    }

    window.onresize = reportWindowSize;

    clearCanvas = function() {
        canvas.width = canvas.width;
    }

    // Set up the UI
    var sigText = document.getElementById("sig-dataUrl");
    var sigImage = document.getElementById("sig-image");
    var clearBtn = document.getElementById("contract_sterge");


    // $("#sig-canvas").on("click", function (e) {
    //     drawing = !drawing;
    //     mousePos = getMousePos(canvas, e); 
    //     lastPos = getMousePos(canvas, e);
    // });

    $("#sig-canvas").mousedown(function (e) {
        drawing = true;
        lastPos = getMousePos(canvas, e);
        mousePos = getMousePos(canvas, e);
    })

    $("#sig-canvas").mouseup(function (e) {
        drawing = false;
        lastPos = getMousePos(canvas, e);
        mousePos = getMousePos(canvas, e);
    })

    $("#sig-canvas").mousemove(function (e) {
        mousePos = getMousePos(canvas, e);
    })
});

const Contract = new Vue({
    el: "#contract_container",
    data: {
        active: false,
        viewmode: false,
        street_name: "",
        street_id: "",
        id: 0,
        din_partea: "",
        numar: 0,
        descriere: "",
        date: "0.0.0"
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

        submit() {
            var dataUrl = canvas.toDataURL();
            let street2 = this.street_id;
            let street = this.street_name;
            $("#contract_container").fadeOut(500);
            this.post("contractResponse", {response: {
                data_uri: dataUrl,street_name: street,street_id: street2
            }});
        },

        clear() {
            clearCanvas();
        },

        build(data) {
            this.active = true
            this.id = data.id
            this.din_partea = data.din_partea
            this.numar = data.numar
            this.descriere = data.descriere
            this.street_name = data.street_id
            this.street_id = data.street_name
            let date = new Date(data.date * 1000);
            this.date = date.getDay()+"."+date.getMonth()+"."+date.getFullYear()
            $("#contract_container").fadeIn();

            canvas.width = (document.body.clientHeight * 0.5490);
            canvas.height = (document.body.clientHeight * 0.18);

            this.viewmode = data.viewmode
            if (this.viewmode){
                $("#contract_draw").hide();
                $("#contract_show").show();
                $("#semnatura_view").attr('src', data.data_uri);
                // $("#semnatura_view").src = data.uri;
            } else {
                $("#contract_draw").show();
                $("#contract_show").hide();
            }

            // this.post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
        },

        destroy(){
            $("#contract_container").fadeOut(500);
            this.post("contractResponse", {response: false});
        }
    },
})