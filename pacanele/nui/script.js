const AudioList = ['bet', 'double', 'roll', 'win', 'alarm', 'collect', 'button', 'stop'];
const AudioElements = {};

const Lines = [
  [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0]],
  [[0, 1], [1, 1], [2, 1], [3, 1], [4, 1]],
  [[0, 2], [1, 2], [2, 2], [3, 2], [4, 2]],
  [[0, 0], [1, 1], [2, 2], [3, 1], [4, 0]],
  [[0, 2], [1, 1], [2, 0], [3, 1], [4, 2]],
  [[0, 1], [1, 0], [2, 0], [3, 0], [4, 1]],
  [[0, 1], [1, 2], [2, 2], [3, 2], [4, 1]],
  [[0, 0], [1, 0], [2, 1], [3, 2], [4, 2]],
  [[0, 2], [1, 2], [2, 1], [3, 0], [4, 0]],
  [[0, 1], [1, 2], [2, 1], [3, 0], [4, 1]]
];

const WinTable = [
  [0],
  [1, 0.5, 1, 1.5, 3],
  [1, 1, 1, 2, 3.5],
  [1, 1, 1, 2, 3.5],
  [1, 1, 2, 2.5, 5],
  [1, 1, 2.5, 3, 6],
  [1, 1, 3.5, 4, 10],
  [1, 1, 10, 80, 350]
];

const SLOTS_PER_REEL = 12;
const REEL_RADIUS = 209;

// Functions

const PlaySoundEffect = name => {
  const active = $('#sounds').is(':checked');

  if (active && AudioList.includes(name)) {
    let element = AudioElements[name];
    element.play();
  }
}

const toggleContent = () => {
  const paytable = document.getElementById('paytable');

  if (paytable.style.display == 'block') 
    paytable.style.display = 'none';
  else 
    paytable.style.display = 'block';
}

const formatNumber = number => new Intl.NumberFormat('ro-RO').format(number);

this.stopNextReel = function () {
  _iNumReelsStopped++;

  if (_iNumReelsStopped % 2 === 0) {

    PlaySoundEffect('stop');

    _iNextColToStop = _aReelSequence[_iNumReelsStopped / 2];
    if (_iNumReelsStopped === (NUM_REELS * 2)) {
      this._endReelAnimation();
    }
  }
};

var _iNumReelsStopped;

var coins = 0;
var bet = 10;

var backCoins = coins * 2;
var backBet = bet * 2;

var rolling = 0;

function insertCoin(amount) {
  coins += amount;
  backCoins = coins * 2;
  $('#ownedCoins').empty().append(formatNumber(coins));
}

function setBet(amount) {
  if (amount > 0) {
    if (amount > coins) {
      amount = 50;
    }
    bet = amount;
    backBet = bet * 2;
    $('#ownedBet').empty().append(formatNumber(bet));
    PlaySoundEffect('bet');
  }
}

var tbl1 = [],
  tbl2 = [],
  tbl3 = [],
  tbl4 = [],
  tbl5 = [];
var crd1 = [],
  crd2 = [],
  crd3 = [],
  crd4 = [],
  crd5 = [];

function createSlots(ring, id) {
  var slotAngle = 360 / SLOTS_PER_REEL;
  var seed = getSeed();

  for (var i = 0; i < SLOTS_PER_REEL; i++) {
    var slot = document.createElement('div');
    var transform = 'rotateX(' + (slotAngle * i) + 'deg) translateZ(' + REEL_RADIUS + 'px)';
    slot.style.transform = transform;

    var imgID = (seed + i) % 7 + 1;
    seed = getSeed();
    if (imgID == 7) {
      imgID = (seed + i) % 7 + 1;
    }

    slot.className = 'slot' + ' fruit' + imgID;
    slot.id = id + 'id' + i;
    $(slot).empty().append('<p>' + createImage(imgID) + '</p>');

    ring.append(slot);
  }
}

function createImage(id) {
  return '<img src="img/item' + id + '.png" style="border-radius: 20px;" width=100 height=100>';
}

function getSeed() {
  return Math.floor(Math.random() * (SLOTS_PER_REEL));
}

function setWinner(cls, level) {
  if (level >= 1) {
    var cl = (level == 1) ? 'winner1' : 'winner2';
    $(cls).addClass(cl);
  }
}

function reverseStr(str) {
  return str.split("").reverse().join("");
}

var canDouble = 0;
var colorHistory = [-1];

var dubleDate = 0;

function endWithWin(x, sound) {
  $('#win').empty().append(new Intl.NumberFormat('ro-RO').format(x));
  $('.win').show();

  $('.betUp').empty().append("RED");
  $('.betUp').css('background-color', 'red');
  $('.betDown').empty().append("BLACK");
  $('.betDown').css('background-color', 'black');

  canDouble = x;

  if (sound == 1) {
    PlaySoundEffect('double');
    dubleDate++;
    if (dubleDate >= 4) {
      pressROLL();
    }
  }
}

function looseDouble() {
  canDouble = 0;
  dubleDate = 0;
  $('.win').hide();

  $('.betUp').empty().append('BET +10');
  $('.betUp').css('background-color', 'rgb(0, 160, 40)');
  $('.betDown').empty().append('BET -10');
  $('.betDown').css('background-color', 'rgb(255, 104, 104)');
}

function voteColor(x, color) {
  var rcolor = Math.floor(Math.random() * (2));
  colorHistory[colorHistory.length] = rcolor;

  var pls = 1;
  for (var cont = colorHistory.length; cont >= colorHistory.length - 8; cont--) {
    var imgColor = "none";
    if (colorHistory[cont] == 1) {
      imgColor = 'black';
    }
    if (colorHistory[cont] == 0) {
      imgColor = 'red';
    }
    $('#h' + pls).empty();
    if (imgColor !== "none") {
      $('#h' + pls).append("<img src='img/" + imgColor + ".png' width=30px height=30px/>");
      pls++;
    }
  }

  if (rcolor == color) {
    endWithWin(x * 2, 1);
  } else {
    looseDouble();
  }
}

function spin(timer) {
  var winnings = 0;
  PlaySoundEffect('roll');
  for (var i = 1; i < 6; i++) {

    var z = 2;
    var oldSeed = -1;

    var oldClass = $('#ring' + i).attr('class');
    if (oldClass.length > 4) {
      oldSeed = parseInt(oldClass.slice(10));
    }
    var seed = getSeed();
    while (oldSeed == seed) {
      seed = getSeed();
    }

    var pSeed = seed
    for (var j = 1; j <= 5; j++) {
      pSeed += 1;
      if (pSeed == 12) {
        pSeed = 0;
      }
      if (j >= 3) {
        var msg = $('#' + i + 'id' + pSeed).attr('class');
        switch (i) {
          case 1:
            tbl1[z] = reverseStr(msg)[0];
            crd1[z] = '#' + i + 'id' + pSeed
            _iNumReelsStopped = 0
            break;
          case 2:
            tbl2[z] = reverseStr(msg)[0];
            crd2[z] = '#' + i + 'id' + pSeed

            break;
          case 3:
            tbl3[z] = reverseStr(msg)[0];
            crd3[z] = '#' + i + 'id' + pSeed

            break;
          case 4:
            tbl4[z] = reverseStr(msg)[0];
            crd4[z] = '#' + i + 'id' + pSeed

            break;
          case 5:
            tbl5[z] = reverseStr(msg)[0];
            crd5[z] = '#' + i + 'id' + pSeed

            break;
        }
        z -= 1;
      }
    }

    $('#ring' + i)
      .css('animation', 'back-spin 1s, spin-' + seed + ' ' + (timer + i * 0.5) + 's')

      .attr('class', 'ring spin-' + seed);
  }
  var table = [tbl1, tbl2, tbl3, tbl4, tbl5];
  var cords = [crd1, crd2, crd3, crd4, crd5];

  for (var k in Lines) {
    var wins = 0,
      last = table[Lines[k][0][0]][Lines[k][0][1]],
      lvl = 0;

    for (var x = 1 in Lines[k]) {
      if (last == table[Lines[k][x][0]][Lines[k][x][1]]) {
        wins++;
        last = table[Lines[k][x][0]][Lines[k][x][1]];
      } else break;
    }

    switch (wins) {
      case 2:
        if (last == 1) {
          lvl = 1;
          setTimeout(PlaySoundEffect, 3950, 'win');
        }
        break;
      case 3:
        lvl = 1;
        setTimeout(PlaySoundEffect, 3950, 'win');
        break;
      case 4:
        lvl = 2;
        setTimeout(PlaySoundEffect, 3200 + 700 + 0.3 * k * 1000, 'alarm');
        break;
      case 5:
        lvl = 2;
        setTimeout(PlaySoundEffect, 3200 + 0.3 * k * 1000, 'alarm');
        break;
      default:
        0;
    }
    if (lvl > 0) {
      winnings = winnings + bet * WinTable[table[Lines[k][wins - 1][0]][Lines[k][wins - 1][1]]][wins - 1];
      setTimeout(endWithWin, 4400, winnings, 0);
    }

    for (var p = wins - 1; p >= 0; p--) {
      setTimeout(setWinner, 3200 + 0.4 * p * 1000 + 0.3 * k * 1000, cords[Lines[k][p][0]][Lines[k][p][1]], lvl);
    }
  }
  setTimeout(function () {
    rolling = 0;
  }, 4500);
}

function pressROLL() {
  if (rolling == 0) {
    if (canDouble == 0) {
      if (backCoins / 2 !== coins) {
        coins = backCoins / 2;
      }
      if (backBet / 2 !== bet) {
        bet = backBet / 2;
      }

      PlaySoundEffect('button');
      $('.slot').removeClass('winner1 winner2');
      if (coins >= bet && coins !== 0) {
        insertCoin(-bet);

        rolling = 1;
        var timer = 2;
        spin(timer);
      } else if (bet != coins && bet != 50) {
        setBet(coins);
      }
    } else {
      setTimeout(insertCoin, 200, canDouble);
      PlaySoundEffect('collect');
      looseDouble();
    }
  }
}

function pressBLACK() {
  if (canDouble == 0) {
    setBet(bet - 10);
  } else {
    voteColor(canDouble, 1);
  }
}

function pressRED() {
  if (canDouble == 0) {
    setBet(bet + 10);
  } else {
    voteColor(canDouble, 0);
  }
}

var allFile;

function resetRings() {
  var rng1 = $("#ring1"),
    rng2 = $("#ring2"),
    rng3 = $("#ring3"),
    rng4 = $("#ring4"),
    rng5 = $("#ring5");

  rng1.empty()
    .removeClass()
    .addClass("ring")
    .removeAttr('id')
    .attr('id', 'ring1');


  rng2.empty()
    .removeClass()
    .addClass("ring")
    .removeAttr('id')
    .attr('id', 'ring2');

  rng3.empty()
    .removeClass()
    .addClass("ring")
    .removeAttr('id')
    .attr('id', 'ring3');

  rng4.empty()
    .removeClass()
    .addClass("ring")
    .removeAttr('id')
    .attr('id', 'ring4');

  rng5.empty()
    .removeClass()
    .addClass("ring")
    .removeAttr('id')
    .attr('id', 'ring5');

  createSlots($('#ring1'), 1);
  createSlots($('#ring2'), 2);
  createSlots($('#ring3'), 3);
  createSlots($('#ring4'), 4);
  createSlots($('#ring5'), 5);
}

function togglePacanele(start, banuti) {
  if (start == true) {
    allFile.css("display", "block");
    coins = 0;
    insertCoin(banuti);

    resetRings();

    rolling = 0;
  } else {
    allFile.css("display", "none");
    $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({ amount: parseInt(backCoins / 2) }));
    insertCoin(-coins);
  }
}

const toggleAmount = (state, money) => {
  if (state) {
    $('.amount').css('display', 'flex');
  } else {
    $('.amount').css('display', 'none');
    $.post(`https://${GetParentResourceName()}/setCoins`, JSON.stringify({
      amount: parseInt(money)
    }));
  }
}

window.addEventListener('message', event => {
  if (event.data.action == 'openAmount')
    return toggleAmount(true);
  if (event.data.action == 'open')
    return togglePacanele(true, parseInt(event.data.amount));
});

$(document).ready(function () {
  allFile = $("#stage, #overlay,#aio, .imgback, #paytable");

  createSlots($('#ring1'), 1);
  createSlots($('#ring2'), 2);
  createSlots($('#ring3'), 3);
  createSlots($('#ring4'), 4);
  createSlots($('#ring5'), 5);

  AudioList.forEach(audio => {
    let element = document.createElement('audio');

    element.volume = 0.7;
    element.id = audio;
    element.setAttribute('src', `audio/${audio}.wav`);

    AudioElements[audio] = element;
  });

  $('.win').hide();

  $('#ownedCoins').empty().append(new Intl.NumberFormat('en-US').format(coins));
  $('#ownedBet').empty().append(new Intl.NumberFormat('en-US').format(bet));

  $('body').keyup(function (e) {
    switch (e.keyCode) {
      case 32:
        pressROLL();
        break;
      case 13:
        pressROLL(); 
        break;
      case 37:
        pressRED(); 
        break;
      case 39:
        pressBLACK(); 
        break;
      case 38:
        setBet(bet + 10);
        break;
      case 40:
        setBet(bet - 10); 
        break;
      case 27:
        if (document.getElementById('overlay').style.display !== 'none') 
          return togglePacanele(false, 0);
        toggleAmount(false);
        break;
      case 80:
        if (document.getElementById('overlay').style.display !== 'none') 
          return togglePacanele(false, 0);
        toggleAmount(false);
        break;
    }
  });

  $('.betUp').on('click', () => pressRED());
  $('.betUp100').on('click', () => setBet(bet + 100));
  $('.betUp1000').on('click', () => setBet(bet + 1000));
  $('.betUp10000').on('click', () => setBet(bet + 10000));

  $('.betDown').on('click', () => pressBLACK());
  $('.betDown100').on('click', () => setBet(bet - 100));
  $('.betDown1000').on('click', () => setBet(bet - 1000));
  $('.betDown10000').on('click', () => setBet(bet - 10000));

  $('.roll').on('click', function () {
    pressROLL();
  })

  $('.insert-button').on('click', () => {
    const value = parseInt($('#bet-amount').val());

    if (value > 0)
      return toggleAmount(false, $('#bet-amount').val());
  });
});
