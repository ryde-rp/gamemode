let timer_start, timer_game, timer_finish, timer_time, answer, wrong, right, speed, numbers, timerStart, positions;
let game_started = false;

let audio_splashgood = document.querySelector('.splashgood audio');
let audio_splashbad = document.querySelector('.splashbad audio');

const sleep = (ms, fn) => {return setTimeout(fn, ms)};

const rangeNumbers = (length = 4) => {
    return Array.from({length}, _ => Math.floor(Math.random() * 10))
}

document.querySelector('.btn_again').addEventListener('click', function(){
    reset();
});

document.querySelector('.minigame .numbers').addEventListener('keydown', function(e) {
    if (e.ctrlKey === true && e.key === 'c'){
        e.preventDefault();
        return false;
    }
});
document.querySelector('#answer').addEventListener('keydown', function(e) {
    if (e.key === 'Enter' && document.querySelector('.solution').offsetHeight === 0) {
        clearTimeout(timer_finish);
        check();
    }
});

document.querySelector('#answer').addEventListener('drop', function(e) {
    e.preventDefault();
    return false;
});

function check(){
    stopTimer();

    let response = document.querySelector('#answer').value.toLowerCase().trim();

    if(game_started && response === answer.join('')){
      document.querySelector('.minigame').classList.add('hidden');
      document.querySelector('.minigamegood').classList.remove('hidden');
      document.querySelector('.splashgood').classList.remove('hidden');
      audio_splashgood.play();
      document.querySelector('.minigame').classList.add('hidden');
      $.post('https://'+GetParentResourceName()+'/PasswordMinigame', JSON.stringify({result: true}));
    }else{
        answer.forEach( (number, pos) => {
            let span = document.createElement('span');
            span.innerText = number;
            if( response.length > pos ){
                if( response[pos] === number.toString() ){
                    span.classList.add('good');
                }else{
                    span.classList.add('bad');
                }
            }else{
                span.classList.add('bad');
            }
            $.post('https://'+GetParentResourceName()+'/PasswordMinigame', JSON.stringify({result: false}));
            document.querySelector('.solution').append(span);
            document.querySelector('.minigame').classList.add('hidden');
            document.querySelector('.minigamebad').classList.remove('hidden'); 
            document.querySelector('.splashbad').classList.remove('hidden');
            audio_splashbad.play();
            setTimeout(function(){
                reset();
            }, 3000);
        });
    }
}

function reset(){
    game_started = false;

    resetTimer();
    clearTimeout(timer_start);
    clearTimeout(timer_game);
    clearTimeout(timer_finish);
    
    document.querySelector('.opensplash').classList.add('hidden');
    document.querySelector('.minigame').classList.remove('hidden');
    document.querySelector('.splash').classList.remove('hidden');

    document.querySelector('.minigamebad').classList.add('hidden'); 
    document.querySelector('.splashbad').classList.add('hidden');
    document.querySelector('.minigame .input').classList.add('hidden');

    document.querySelector('.minigamegood').classList.add('hidden');
    document.querySelector('.splashgood').classList.add('hidden');

    start();
}

function start(){
    numbers = $('.numbers').value;
    answer = rangeNumbers(numbers);
    document.querySelector('.minigame .numbers').innerHTML = answer.join('');

    timer_start = sleep(2000, function(){
        document.querySelector('.splash').classList.add('hidden');
        document.querySelector('.minigame .numbers').classList.remove('hidden');

        timer_game = sleep(4000, function(){
            document.querySelector('.minigame .numbers').classList.add('hidden');
            document.querySelector('.minigame .input').classList.remove('hidden');

            game_started = true;
            startTimer();

            document.querySelector('#answer').focus({preventScroll: true});
        });
    });
}

function startTimer(){
    timerStart = new Date();
    timer_time = setInterval(timer,1);
}
function timer(){
    let timerNow = new Date();
    let timerDiff = new Date();
    timerDiff.setTime(timerNow - timerStart);
    let ms = timerDiff.getMilliseconds();
    let sec = timerDiff.getSeconds();
    if (ms < 10) {ms = "00"+ms;}else if (ms < 100) {ms = "0"+ms;}
}
function stopTimer(){
    clearInterval(timer_time);
}
function resetTimer(){
    clearInterval(timer_time);
}

window.addEventListener("message",function(event){
    var data = event.data;
    switch(data.action) {
        case 'StartPasswordMinigame':
            $('.minigame-wrapper').fadeIn();
            reset();
        break
        case "ClosePasswordMinigame":
            $('.minigame-wrapper').fadeOut();
        break
    }
});