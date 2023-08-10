var usingCursor = false;
var dynamic_menu = new Menu();

const cash = document.getElementById("fairplay-money");
const FairPlayCoins = document.getElementById("fairplay-coins");
const moneyFormat = new Intl.NumberFormat("us-US", {style: 'currency', currency: "USD", maximumFractionDigits: 0, minimumFractionDigits: 0});
const coinFormat = new Intl.NumberFormat("us-US", {style: 'decimal', maximumFractionDigits: 0, minimumFractionDigits: 0});

function addZeroToText(i) {
  if (i < 9)
    return "0" + i;

  return i;
}

function htmlEncode(str){
    return String(str).replace(/[^\w. ]/gi, function(c){
        return '&#'+c.charCodeAt(0)+';';
    });
}

function updateHour(){
  var d = new Date();
  var minutes = d.getMinutes().toString();
  var hour = d.getHours().toString();
  $('#fairplay-ora').text(addZeroToText(hour) + ':' + addZeroToText(minutes));
}

async function post(url, data = {}){
  const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
  });
  
  return await response.json();
}

updateHour();
setInterval(updateHour, 60000);

dynamic_menu.onClose = function(){ $.post("https://vrp/menu",JSON.stringify({act: "close", id: dynamic_menu.id})); }
dynamic_menu.onValid = function(choice,mod){ $.post("https://vrp/menu",JSON.stringify({act: "valid", id: dynamic_menu.id, choice: choice, mod: mod})); }

var current_menu = dynamic_menu;
var divs = {}

var fairplayHud = new Vue({
  el: "#fairplay-rp",
  data: {
    // Anunturi CNN
    anunt_activ: false,
    anunt_text: "Salutare vand Toyota Supra full tunning culoare verde astept mesaj sau sunati-ma! Cat mai repede! Urgent!Salutare vand Toyota Supra full tunning culoare verde astept mesaj sau sunati-ma! Cat mai repede! Urgent!Salutare vand Toyota Supra full tunning culoare verde astept mesaj sau sunati-ma! Cat mai repede!",
    anunt_number: "0123456789",
    anunt_user: 123,

    // Radio System
    radio_active: false,
  },
  methods: {
    // Anunturi CNN
    hide_cnn_announce() {
      if (this.anunt_activ){
        this.anunt_activ = false;
        $(".announce-wrapper").fadeOut();
      };
    },

    // Radio System
    slideUpRadio(){
      $(".radio-wrapper").css("display", "block");
      $(".radio-container").animate({bottom: "6vh",}, 250);
      this.radio_active = true;
    },

    slideDownRadio(){
      $(".radio-container").animate({bottom: "-110vh",}, 400, function(){
          $(".radio-wrapper").css("display", "none");
      });

      this.radio_active = false;
    },

    connectOnRadio(){
      $.post('https://vrp/vRP_radio:joinRadio', JSON.stringify({
        channel: $("#radio-channel").val()
      }));
    },

    leaveTheRadio(){
      $.post('https://vrp/vRP_radio:leaveRadio', JSON.stringify({}));
    },

    increaseRadioVolume(){
      $.post('https://vrp/vRP_radio:volumeUp', JSON.stringify({}));
    },

    decreaseRadioVolume(){
      $.post('https://vrp/vRP_radio:volumeDown', JSON.stringify({}));
    },
  },
});
  
window.addEventListener('keyup', function(e){
  switch(e.code){
    case 'Escape':
      if (fairplayHud.radio_active){
        fairplayHud.slideDownRadio();
        post("vRP_radio:escape");
        post("frontendSound", {dict: "NAV", sound: "HUD_AMMO_SHOP_SOUNDSET"});
      }
    break
  
    case 'Backquote':
      if (usingCursor) {
        usingCursor = false;
        post("setFocus", {state: false});
      }
    break
  }
});

let screenRatio = '1.8';
let speedoFaded = false;

let purifyData
purifyData = function(data){
  if (typeof(data) == "object"){
    for (const key in data) {
      if (Object.hasOwnProperty.call(data, key)) {
        data[key] = purifyData(data[key]) 
      }
    }
  } else if (typeof(data) == "string" ){
    data = DOMPurify.sanitize(data);
  }
  return data
}

window.addEventListener("message",function(evt){
  var data = purifyData(evt.data);

  switch(data.act){
    case "open_menu":
      current_menu.close();
      dynamic_menu.open(data.menudata.name,data.menudata.choices);
      dynamic_menu.id = data.menudata.id;

      var css = data.menudata.css
      if(css.top)
        dynamic_menu.div.style.top = css.top;
      if(css.header_color)
        dynamic_menu.div_header.style.backgroundColor = css.header_color;

      current_menu = dynamic_menu;
    break
    
    case "close_menu":
      current_menu.close();
    break

    case 'prompt':
      requestManager.createPrompt(data.title, data.fields);
    break

    case 'request':
      requestManager.createDialog(data.id, data.title, data.text);
    break

    case 'hint':
      hints.build(data.text, data.timeout);
    break

    case 'server-shop':
      ServerShop.build();
    break

    case 'set_div':
      var div = divs[data.name];
      if(div)
        div.removeDom();

      divs[data.name] = new Div(data)
      divs[data.name].addDom();  
    break

    case 'set_div_css':
      var div = divs[data.name];
      if(div)
        div.setCss(data.css);
    break

    case 'set_div_content':
      var div = divs[data.name];
      if(div)
        div.setContent(data.content);
    break
    
    case 'remove_div':
      var div = divs[data.name];
      if(div)
        div.removeDom();
  
      delete divs[data.name];
    break
    
    case 'sound_manager':
      switch(data.call){
        case "play":
          soundManager.play(data.sound, data.volume);
        break

        case "stop":
          soundManager.stop();
        break
      }
    break

    case "ToggleRadar":
      if (data.radar) {
        $(".radar").fadeIn()
      } else{
        $(".radar").fadeOut()
      }
    break

    case "UpdateRadar":
      const speed = document.getElementById("radar-speed");
      jQuery({ Counter: parseInt(speed.textContent.match(/\d+/)[0]) }).animate({ Counter: data.speed }, {
        duration: 90,
        easing: 'swing',
        step: function () {
          speed.innerText = Math.floor(this.Counter);
        }
      });
      $("#radar-vehicle").text(data.model);
      $(".vehicle-plate").text(data.plate);
    break

    case "set-admin-tickets":
      if (!data.isAdmin)
          return false;

      $('#fairplay-tickete').text(data.count)
      $('#fairplay-hudtickete').fadeIn();
    break

    case "UpdatePlayerCount":
      $("#fairplay-onlineplayers").text(data.onlinePlayers);
    break

    case "SetUserId":
      $("#fairplay-userid").text(data.userId);
    break

    case "ToggleHud":
      switch(data.type){
        case "stats":
          if (data.state){
            $(".survival-wrapper").fadeIn();
          } else{
            $(".survival-wrapper").fadeOut();
          }
        break
        case "vitals":
          if (data.state){
            $(".fairplay-hud-wrapper").fadeIn();
          } else {
            $(".fairplay-hud-wrapper").fadeOut();
          }
        break
        // case "radar":
        //   if (data.state){
        //     $(".map-border").fadeIn();
        //   } else {
        //     $(".map-border").fadeOut();
        //   }
      }
    break

    case "switchAdditionalHud":
      if(data.on) {
        $(".fairplay-hud-boxes").fadeIn();

        let actualCash = parseInt(cash.innerText.match(/\d+/g).join(""));
        let actualCoins = parseInt(FairPlayCoins.innerText.match(/\d+/g).join(""));

        jQuery({ Counter: 0 }).animate({ Counter: actualCash }, {
          duration: 1500,
          easing: 'swing',
          step: function() {
            cash.innerText = moneyFormat.format(Math.floor(this.Counter));
          }
        });
        jQuery({ Counter: 0 }).animate({ Counter: actualCoins }, {
          duration: 1500,
          easing: 'swing',
          step: function() {
            FairPlayCoins.innerText = coinFormat.format(Math.floor(this.Counter));
          }
        });
        
        $.post("https://vrp/aditionalHudState", JSON.stringify({running: true}));

        setTimeout(() => {
          cash.innerText = moneyFormat.format(Math.floor(actualCash));
          FairPlayCoins.innerText = coinFormat.format(Math.floor(actualCoins));
          $.post("https://vrp/aditionalHudState", JSON.stringify({running: false}));
        }, 1510);

      } else {
        $(".fairplay-hud-boxes").fadeOut();
      }
    break

    case "setAspectRatio":
      var lastRatio = screenRatio;
      
      switch (data.aspect) {

        case '1.3': // 4:3 / 5/4
          if (lastRatio != '1.3') {
            screenRatio = '1.3';

            $(".survival-wrapper").css("left", "46vh");
            $(".square").css("width", "41vh");
          }
        break

        case '1.6': // 16:10
          if (lastRatio != '1.6') {
            screenRatio = '1.6';

            $(".survival-wrapper").css("left", "37vh");
            $(".square").css("width", "32vh");
          }
        break

        case '1.8': // 16:9
          if (lastRatio != '1.8') {
            screenRatio = '1.8';

            $(".survival-wrapper").css("left", "34vh");
            $(".square").css("width", "29vh");
          }
        break
      }
    break

    case 'setWeatherData':
      $("#grade").text(data.celsius + " °C");
      $("#tipvreme").text(data.text);
      $("#iconvreme").html("<i class='" + data.icn + "'></i>");
    break

    case 'setSpeedoData':
      switch (data.speedoShown){
        case true:
          if (!speedoFaded) {
            $(".speedometer-layout").fadeIn();
            speedoFaded = true;
          }

          vehSpeedometer.speed = data.speed;
          vehSpeedometer.tank = data.tank;
          vehSpeedometer.rpm = data.rpm;
          vehSpeedometer.gear = data.gear;
          vehSpeedometer.odometer = data.odometer;
          vehSpeedometer.engine = data.vehicleon;
          vehSpeedometer.seatbelt = data.seatbelt;
          vehSpeedometer.lights = data.lights;
          vehSpeedometer.doors = data.doors;
        break
        
        case false:
          if (speedoFaded) {
            $(".speedometer-layout").fadeOut();
            speedoFaded = false;
          }
        break
      }
    break

    case "createAnunt":
      fairplayHud.anunt_text = data.text;
      fairplayHud.anunt_number = data.number;
      fairplayHud.anunt_user = data.user_id;
      $(".announce-wrapper").fadeIn();
      fairplayHud.anunt_activ = true;

      setTimeout(() => {
        $(".announce-wrapper").fadeOut();
        fairplayHud.anunt_activ = false;
      }, 15000);
    break

    case 'event':
      switch(data.event){
        case 'openMap':
          if (!data.state) {
            $("#fairplay-rp").fadeOut();
            // $(".map-border").fadeOut();
            $(".survival-wrapper").fadeOut();
          } else {
            $("#fairplay-rp").fadeIn();
            // $(".map-border").fadeIn();
            $(".survival-wrapper").fadeIn();
          }
        break

        case 'showDaily':
          dailymissions.build(data.missions,data.reward);
        break

        case 'slots':
          _slotScript.build();
        break

        case 'showDailyTimer':
          dailymissions.buildTimer(data.tog,data.rewardtype);
        break

        case 'updateDailyTimer':
          dailymissions.updateDailyTimer(data.ore,data.minute);
        break

        case "toggleRadioMenu":
          fairplayHud.radio_active = data.state;

          if (data.state){
            fairplayHud.slideUpRadio();
          } else {
            fairplayHud.slideDownRadio();
          }
        break

        case 'reloadRadioList':
          let list = data.list;
          let show = data.show;
          let rl_body = $("#radioList")
          if (show){
            rl_body.fadeIn(500);
            for (const key in list) {
              const element = list[key];
              if (element && element != null){
                let inList = document.querySelector("#radioList #user-"+element.user_id)
                if (!inList){
                  let div = document.createElement("div");
                  div.innerHTML = "["+element.user_id+"] "+element.name;
                  div.id = "user-"+element.user_id;
                  rl_body.append(div);
                }
              }
            }
          } else {
            rl_body.fadeOut(500);
          }
        break

        case "unloadRadioList":{
          let rl_body = $("#radioList")
          rl_body.empty();
          break
        }

        case "radioTalk":{
          let serverid = data.serverid
          let talking = $("#radioList #user-"+serverid)
          console.log(data.on,serverid);
          if (data.on){
            $(talking).addClass("talking");
          } else {
            $(talking).removeClass("talking");
          }
          break
        }

        case 'addUserToRadio': {
          let rl_body = $("#radioList")
          let pData = data.data;
          let div = document.createElement("div");
          div.innerHTML = "["+pData.user_id+"] "+pData.name;
          div.id = "user-"+pData.user_id;
          rl_body.append(div);
        break }

        case 'remUserToRadio': {
          let pData = data.data;
          $("#radioList #user-"+pData.serverid).remove();
        break }

        case 'setHudData':
          cash.innerText = data.cash;
          FairPlayCoins.innerText = data.coins;
        break

        case "setDependenciesData":
          updateHud(data);
        break

        case "setDisplayLocation":
          $("#zone").text(data.firstStreet);
          $("#street").text(data.secondStreet);
        break

        case "setVoiceLevel":
          setTalkingLevel(data.lvl);
        break

        case 'notificare':
          createNotify(data.type || 'info', data.ntime || 5000, data.text, data.icon);
        break
      
        case 'UP':
          current_menu.moveUp();
        break

        case 'DOWN':
          current_menu.moveDown();
        break

        case 'LEFT':
          current_menu.valid(-1);
        break

        case 'RIGHT':
          current_menu.valid(1);
        break

        case 'SELECT':
          current_menu.valid(0);
        break

        case 'CANCEL':
          current_menu.close();
        break

        case 'F5':
          requestManager.useDialog(true);
        break

        case 'F6':
          requestManager.useDialog(false);
        break
        
      }
    break

    case "keyRequest":
      switch(data.request){
        case "use":
          requestManager.requestKey(data.key, data.text);
        break

        case "hide":
          requestManager.hideKey();
        break
      }
    break

    case 'police-alert':
      $(".police-backup").fadeIn();
      $(".alert-code").text(data.code);
      $(".backup-name").text(data.backupName);
      $("#alert-location").text(data.location);
      $("#alert-text").text(data.text);
      $("alert-time").text(data.time);
      $(".cop-name").text(data.cop);

      setTimeout(() => {
        $(".police-backup").fadeOut();
      }, 4800)
    break

    case "useCursor":
      usingCursor = true;
    break

    case "job":
      switch(data.target) {
        case "taxi":
          var rqsComponent = data.component;
          
          if (rqsComponent == "workerMenu"){
            taxiCompanyMenu.build(data.data);
          } else if (rqsComponent == "managerMenu"){
            taxiManagement.build(data.data);
          } else if (rqsComponent == "commandsList"){
            taxiCmds.build(data.data);
          } else if (rqsComponent == "updateCmdsList"){
            taxiCmds.update(data.data);
          } else if (rqsComponent == "newCallAlert"){
            taxiCmds.showAlert("DISPECERAT", "<p>Compania de taxi tocmai a inregistrat o noua comanda.</p><p>Apasa 'J' pentru a prelua o comanda.</p>");
          } else if (rqsComponent == "takenCallAlert"){
            taxiCmds.showAlert(data.company.toUpperCase(), "<p>Un taximetrist ti-a preluat</p><p>comanda si urmeaza sa ajunga la tine</p>");
          } else if (rqsComponent == "sentCallAlert"){
            taxiCmds.showAlert("TAXI SERVICE", "<p>Tocmai ai sunat la serviciul</p><p>de taxi, asteapta un raspuns.")
          } else if (rqsComponent == "taximeter"){
            var theAction = data.state;

            if (theAction == "updateCost"){
              taximeter.setCost(data.cost);
            } else if (theAction == "updateTime"){
              taximeter.setTime(data.time);
            } else if (theAction == "build"){
              taximeter.build();
            } else if (theAction == "hide"){
              taximeter.destroy();
            }
          }
        break
        case 'electrician':
          electrician.build(data.data)
        break
        case 'constructor':
          constructor.build(data.data);
        break
        case 'scafandru':
          scafandru.build(data.data);
        break
        case 'gunoier':
          gunoier.build(data.data);
        break
        case 'petrolist':
          petrolist.build(data.data);
        break
        case 'culegator_de_mere':
          culegator_de_mere.build(data.data);
        break
        case 'gradinar':
          gradinar.build(data.data);
        break
        case 'farmerChoice':
          farmerChoice.build(data.data);
          break;
        case 'petrolistChoice':
          petrolistChoice.build(data.data);
          break;
        case 'farmer':
          farmer.build(data.data);
        break;
        case 'agricultor':
          agricultor.build(data.data);
        break;
        case 'trucker':
          trucker.build(data.data);
        break
        case 'forester':
          forester.build(data.data);
        break
        case 'glovo':
          glovo.build(data.data);
        break
        case 'pescar':
          fisher.build(data.data);
        break
        case 'busdriver':
          busdriver.build(data.data);
        break
        case 'miner':
          miner.build(data.data)
        break
        case 'mechanic':
          if(data.component != undefined) {
            if (data.component == "newCallAlert"){
              mechanicCmds.showAlert("DISPECERAT", "<p>Tocmai ce a fost inregistrat</p><p> o noua comanda.</p>");
            } else if (data.component == "takenCallAlert"){
              mechanicCmds.showAlert(data.company.toUpperCase(), "<p>Un mecanic ti-a preluat</p><p>comanda si urmeaza sa ajunga la tine</p>");
            } else if (data.component == "sentCallAlert"){
              mechanicCmds.showAlert("MECHANIC SERVICE", "<p>Tocmai ai sunat la serviciul</p><p>de mecanici, asteapta un raspuns.")
            }
          } else mechanic.build(data.data)
        break
      }
    break

    case "interface":
      switch(data.target) {
        case "garage":
          var action = data.event;

          if (action == "show"){
            basic_garage.build(data.vehicles, data.garageName);
          }
        break

        case "case":
          houses.build(data);
        break

        case "tasks":
          var action = data.event;

          if (action){
            Tasks[action](...data.data);
          }
        break

        case "eastershop":
          eastershop.build(data.oua);
        break

        case "market":
          basic_markets.build(data.data);
        break

        case "investitii":
          investment.build(data.investData, data.hours);
        break

        case "pedDialog":
          dialogPeds.build(data.fields, data.text, data.desc, data.name);
        break

        case "factionStore":
          factionStore.build(data.items, data.type, data.faction);
        break

        case "factionEquipment":
          factionEquipment.build(data.group);
        break

        case "djBoot":
          dj.build(data.data.playing,data.data.history);
        break    

        case "factionCalls":
          var action = data.event;
          var calls = data.calls;

          if (action == "show"){
            factionCalls.build(calls, data.logo);
          } else if (action == "update") {
            factionCalls.update(calls);
          }
        break

        case "factionCloset":
          var action = data.event;

          if (action == "build") {
            factionCloset.build(data.data);
          } else if (action == "update") {
            factionCloset.update(data.current);
          }
        break

        case "gunShop":
          gunStore.build();
        break

        case "vehicleMenu":
          vehicleMenu.build();
        break

        case "dealership":
          setTimeout(() => {
            dealership.build();
          }, 2500)
        break

        case "testdrive":
          testDrive.build(data.model);
        break

        case "moneyWasher":
          moneyWasher.build(data.bizData, data.bizId);
        break

        case "contract":
          Contract.build(data.data);
        break

        case "asigurareauto":
          AsigurareAuto.build(data.data);
        break

        case "rovinieta":
          Rovinieta.build(data.data);
        break

        case "bank":
          Banking.build(data.money, data.identity[0].toUpperCase(), data.identity[1], data.hasFaction, data.factionLeader, data.budget);
        break

        case "panelReminder":
          panelReminder.build(data.code);
        break

        case "accountStats":
          accountStats.build(data.user_id, data.username, data.sex, data.userObj, data.userWarns)
        break

        case "deathscreen":
          var action = data.event;

          if (action == "show"){
            deathScreen.build();
          } else if (action == "update") {
            deathScreen.update(data.respawnTime, data.time, data.canRespawn);
          } else if (action == "hide") {
            deathScreen.destroy();
          }
        break

        case "adminAnnounce":
          adminAnnounce.build(data.admin, data.text);
        break

        case "procesare":
          meniuProcesare.build(data.recipe, data.result, data.title.toUpperCase(), data.icon, data.time);
        break

        case "drivingSchool":
          dmvExam.build();
        break
      }
    break
  }
});