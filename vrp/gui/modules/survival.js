var Microphone = new CircleProgress(".progress1");
  Microphone.max = 3;
  Microphone.value = 1;
  Microphone.textFormat = "none"

var Health = new CircleProgress(".progress2");
  Health.max = 100;
  Health.value = 10;
  Health.textFormat = "none"

var Armour = new CircleProgress(".progress3");
  Armour.max = 100;
  Armour.value = 0;
  Armour.textFormat = "none"

var Hunger = new CircleProgress(".progress4");
  Hunger.max = 100;
  Hunger.value = 10;
  Hunger.textFormat = "none"

var Thirst = new CircleProgress(".progress5");
  Thirst.max = 100;
  Thirst.value = 1;
  Thirst.textFormat = "none"


const updateHud = (data) => {
  Health.value = data.health;
  Hunger.value = data.hunger;
  Thirst.value = data.thirst;
  Armour.value = data.armour;

  if (data.armour > 0){
    $(".progress3").fadeIn();
  } else {
    $(".progress3").fadeOut();
  }

  if (data.talking) {
    $("#microfon").css("opacity", "1");
  } else {
    $("#microfon").css("opacity", "0.5");
  }
}

const setTalkingLevel = (lvl) => {
  Microphone.value = lvl;
}