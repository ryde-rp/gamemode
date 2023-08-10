let completedLights = [0, 0, 0, 0];
let isOpen = false;

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
            isOpen = true;
          } else {
            miniGame.fadeOut();
            isOpen = false;
          }
    }
});

document.onkeyup = function(data) {
  if(data.which == 27 && isOpen) {
    $.post(`https://${GetParentResourceName()}/closeMinigame`);
    isOpen = false;
  }
};