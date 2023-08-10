var electricianDriver = new Vue({
    el: ".electrician-container",
    data: {
        userSkill: 1,
        selectedSkill: 1,
        jobActive: false,
    },
    methods:{
        startelectrician: function() {
            this.Post("startElectrician", {skill: this.selectedSkill});
            $(".electrician-container").fadeOut();
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
                $(".electrician-container").fadeOut();
                $(".jobs-container").fadeOut();
                this.Post("CloseElectrician", {close: true});
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
        onMessage() {
            let data = event.data;
            if (data.action == "OpenElectrician") {
                $(".electrician-container").fadeIn();
                $(".jobs-container").fadeIn();
                this.UpdateSkills(data.skill);
                this.jobActive = data.jobActive;
            }
        },
        StopJob() {
          this.Post("job:quit", {job: "electrician"});
          $(".electrician-container").fadeOut();
          $(".jobs-container").fadeOut();
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

// Minigame Electrician

let completedLights = [0, 0, 0, 0];

const colorsClasses = [
  {outline: "m", inner: "n"},
  {outline: "o", inner: "p"},
  {outline: "q", inner: "r"},
  {outline: "s", inner: "t"}
]

let combination = [2, 1, 3, 4];
function generateCombination() {
  // shuffle
  for(i = combination.length - 1; i >= 0; i--) {
    let rnd = Math.floor(Math.random()*(combination.length));
    [combination[i], combination[rnd]] = [combination[rnd], combination[i]];
  }

  // culori
  for(i = 0; i < combination.length; i++) {
    document.getElementById("outline-" + combination[i]).classList = colorsClasses[i].outline;
    document.getElementById("inner-" + combination[i]).classList = colorsClasses[i].inner;
  }
}

function getRequiredY(line) {
  let diff = combination[line - 1] - line;
  return (diff*188);
}

function testLine(line, y) {
  if(getRequiredY(line) === y) {
    toggleLight(combination[line - 1], true)
  } else {
    reset('.drag-' + line, '.line-' + line, 70, (185*line));
    toggleLight(combination[line - 1], false);
  }
}

Draggable.create('.drag-1', {
  onDrag: function () { updateLine('.line-1', this.x + 120, this.y + 185); },
  onRelease: function () { testLine(1, this.y); },
  liveSnap: {points: [
    {x: 670, y: 0},
    {x: 670, y: 188},
    {x: 670, y: 376},
    {x: 670, y: 564}
  ], radius: 40}
});


Draggable.create('.drag-2', {
  onDrag: function () { updateLine('.line-2', this.x + 120, this.y + 375); },
  onRelease: function () { testLine(2, this.y); },
  liveSnap: {points: [
    {x: 670, y: -188},
    {x: 670, y: 0},
    {x: 670, y: 188},
    {x: 670, y: 376}
  ], radius: 40}
});


Draggable.create('.drag-3', {
  onDrag: function () { updateLine('.line-3', this.x + 120, this.y + 560); },
  onRelease: function () { testLine(3, this.y); },
  liveSnap: {points: [
    {x: 670, y: -376},
    {x: 670, y: -188},
    {x: 670, y: 0},
    {x: 670, y: 188}
  ], radius: 40}
});


Draggable.create('.drag-4', {
  onDrag: function () { updateLine('.line-4', this.x + 120, this.y + 745); },
  onRelease: function () { testLine(4, this.y); },
  liveSnap: {points: [
    {x: 670, y: -564},
    {x: 670, y: -376},
    {x: 670, y: -188},
    {x: 670, y: 0}
  ], radius: 40}
});


function updateLine(selector, x, y) {
  gsap.set(selector, {
    attr: {
      x2: x,
      y2: y
    }
  });
}

function resetAll() {
  reset('.drag-1', '.line-1', 60, 185);
  reset('.drag-2', '.line-2', 60, 375);
  reset('.drag-3', '.line-3', 60, 560);
  reset('.drag-4', '.line-4', 60, 745);
  toggleLight(1, false);
  toggleLight(2, false);
  toggleLight(3, false);
  toggleLight(4, false);

  generateCombination();
}

function toggleLight(selector, visibility) {
  if (visibility) {
    completedLights[selector - 1] = 1;
    if (completedLights[0] === 1 && completedLights[1] === 1 && completedLights[2] === 1 && completedLights[3] === 1) {
      
      $.post(`https://${GetParentResourceName()}/winMinigame`);
      window.setTimeout(resetAll, 2000);
    }
  } else {
    completedLights[selector - 1] = 0;
  }
  
  gsap.to(`.light-${selector}`, {
    opacity: visibility ? 1 : 0,
    duration: 0.3
  });
}

function reset(drag, line, x, y) {
  gsap.to(drag, {
    duration: 0.3,
    ease: 'power2.out',
    x: 0,
    y: 0
  });
  gsap.to(line, {
    duration: 0.3,
    ease: 'power2.out',
    attr: {
      x2: x,
      y2: y
    }
  });
}

const miniGame = $("#electricianGame");
window.addEventListener('message', function(event) {
    if (event.data.action == 'ToggleElectricianMinigame') {
        if(event.data.open === true) {
            resetAll();
            miniGame.fadeIn();
          } else {
            miniGame.fadeOut();
          }
    }
});

document.onkeyup = function(data) {
  if(data.which == 27) {
    $.post(`https://${GetParentResourceName()}/closeMinigame`);
  }
};