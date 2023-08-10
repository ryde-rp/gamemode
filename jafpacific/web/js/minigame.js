let minigame_timer_start, minigame_timer_finish, minigame_timer_hide, minigame_timer_time, minigame_good_positions, minigame_best_route, blinking_pos, last_pos, minigame_wrong, minigame_speed, minigame_timerStart;
let minigame_game_started = false;

document.querySelector('.input2 .fa').innerHTML = '&#xf21b;';

const minigameSleep = (ms, fn) => {return setTimeout(fn, ms)};

const range = (start, end, length = end - start + 1) => {
    return Array.from({length}, (_, i) => start + i)
}

const random = (min, max) => {
    return Math.floor(Math.random() * (max - min)) + min;
}

let splash_screen = (show = true) => {
    if(show){
        document.querySelectorAll('.groups, .timer, .question, .answer, .solution').forEach(el =>
            {el.classList.fadeOut();
        });
        $('.splash').fadeIn();
    }
};     

function listener(ev){
    if(!minigame_game_started) return;
    
    let pos_clicked = parseInt(ev.target.dataset.position);
    if(pos_clicked === 0) return;
    
    if(last_pos === 0){
        document.querySelectorAll('.group.breathing').forEach(el => { el.classList.remove('breathing') });
        // document.querySelector('.groups').classList.add('transparent');
        
        if(pos_clicked === blinking_pos || pos_clicked === blinking_pos * 7){
            last_pos = pos_clicked;
            ev.target.classList.add('good');
        }else{
            minigame_wrong++;
            ev.target.classList.add('bad');
        }

        ev.target.classList.remove("transparent");
    }else{
        let pos_jumps = parseInt(document.querySelectorAll('.group')[last_pos].innerText, 10);
        let maxV = maxVertical(last_pos);
        let maxH = maxHorizontal(last_pos);
        
        if(pos_jumps <= maxH && pos_clicked === last_pos + pos_jumps){
            last_pos = pos_clicked;
            ev.target.classList.add('good');
        }else if(pos_jumps <= maxV && pos_clicked === last_pos + (pos_jumps * 7)){
            last_pos = pos_clicked;
            ev.target.classList.add('good');
        }else{
            minigame_wrong++;
            ev.target.classList.add('bad');
        }
    }

    checkMinigame();
}

function addListeners(){
    document.querySelectorAll('.group').forEach(el => {
        el.addEventListener('mousedown', listener);
    });
}

function checkMinigame(){
    if(minigame_wrong === 3){
        minigame_game_started = false;
        $(".groups").fadeOut();
        setTimeout(function(){
            $(".input2").fadeIn();
        }, 1000);
        
        let blocks = document.querySelectorAll('.group');
        minigame_good_positions.push(48);
        minigame_good_positions.forEach( pos => {
            blocks[pos].classList.add('proper');
        });
        setTimeout(function(){
            resetMinigame();
        }, 3000);
        $.post('https://'+GetParentResourceName()+'/Minigame', JSON.stringify({result: false}));
        return;
    }
    if(last_pos === 48){
        stopMinigameTimer();
        $(".groups").fadeOut();
        setTimeout(function(){
            $(".bypass").fadeIn();
        }, 1000);
        $.post('https://'+GetParentResourceName()+'/Minigame', JSON.stringify({result: true}));
    }
}

function maxVertical(pos){
    return Math.floor((48-pos)/7);
}
function maxHorizontal(pos){
    let max = (pos+1) % 7;
    if(max > 0) return 7-max;
        else return 0;
}
function generateNextPosition(pos){
    let maxV = maxVertical(pos);
    let maxH = maxHorizontal(pos);
    if( maxV === 0 ){
        let new_pos = random(random(1, maxH), maxH);
        return [new_pos, pos+new_pos];
    }
    if( maxH === 0 ){
        let new_pos = random(random(1, maxV), maxV);
        return [new_pos, pos+(new_pos*7)];
    }
    if( random(1,1000) % 2 === 0 ){
        let new_pos = random(random(1, maxH), maxH);
        return [new_pos, pos+new_pos];
    }else{
        let new_pos = random(random(1, maxV), maxV);
        return [new_pos, pos+(new_pos*7)];
    }
}

function generateBestRoute(start_pos){
    let route = [];
    if( random(1,1000) % 2 === 0 ){
        start_pos *= 7;
    }
    while(start_pos < 48){
        let new_pos = generateNextPosition(start_pos);
        route[start_pos] = new_pos[0];
        start_pos = new_pos[1];
    }
    
    return route;
}

function resetMinigame(){
    minigame_game_started = false;
    last_pos = 0;

    clearTimeout(minigame_timer_start);
    clearTimeout(minigame_timer_hide);
    clearTimeout(minigame_timer_finish);
    
    startMinigame();

    $('.input2').fadeOut();
    $('.bypass').fadeOut();
};

function startMinigame(){
    minigame_wrong = 0;
    last_pos = 0;
    
    blinking_pos = random(1,4);
    minigame_best_route = generateBestRoute(blinking_pos);
    minigame_good_positions = Object.keys(minigame_best_route);

    $('.input1').fadeIn();
    document.querySelector('.groups').classList.remove('transparent');

    document.querySelectorAll('.group').forEach(el => { el.remove(); });
  
    let div = document.createElement('div');
    div.classList.add('group');
    const groups = document.querySelector('.groups');
    for(let i=0; i < 49; i++){
        let group = div.cloneNode();
        group.dataset.position = i.toString();
        let text;
        switch(i){
            case 0:
                text = '&#xf796;';break;
            case 48:
                text = '&#xf6ff;';break;
            case blinking_pos:
            case (blinking_pos*7):
                group.classList.add('breathing');
                text = random(1,4);
                break;
            default:
                text = random(1,5);
        }
        if( minigame_good_positions.includes( i.toString() ) ){
            text = minigame_best_route[i];
        }
        group.innerHTML = text;
        groups.appendChild(group);
    }

    addListeners();
   
    minigame_timer_start = minigameSleep(4280, function(){
    
    $('.input1').fadeOut();
    setTimeout(function(){
        $('.splash').fadeIn();
    }, 500);

    minigame_timer_start = minigameSleep(3000, function(){
        $('.splash').fadeOut();
        setTimeout(function(){
            $('.groups').fadeIn();
        }, 1000);
        
        minigame_game_started = true;
        // minigame_timer_hide = minigameSleep(6000, function(){
        //     document.querySelector('.groups').classList.add('transparent');
        // });

        startMinigameTimer();
     }); 
   });
}

function startMinigameTimer(){
    minigame_timerStart = new Date();
    minigame_timer_time = setInterval(timer,1);
}

function stopMinigameTimer(){
    clearInterval(minigame_timer_time);
}

window.addEventListener("message",function(event){
    var data = event.data;
    switch(data.action) {
        case 'StartMinigame':
            resetMinigame();
            $('.bank-minigame-wrapper').fadeIn();
        break
        case "CloseMinigame":
            $('.bank-minigame-wrapper').fadeOut();
        break
    }
});