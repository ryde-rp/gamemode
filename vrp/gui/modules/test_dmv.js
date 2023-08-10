// Credits: Redutzu;

const QUESTION_TITLE = document.getElementById('dmv-question_title');
const QUESTION_LIST = document.getElementById('dmv-question_list');
const QUESTION_IMAGE = document.getElementById('dmv-question_image');
const QUESTION_CONTENT = document.querySelector('.dmv-question-content');
const TIMER = document.getElementById('dmv-timer');
const MODIFY_BUTTON = document.getElementById('dmv-modify');
const LATER_BUTTON = document.getElementById('dmv-later');
const SEND_BUTTON = document.getElementById('dmv-send');
const TOTAL = document.getElementById('dmv-total');
const REMAINING = document.getElementById('dmv-remaining');
const CORRECT = document.getElementById('dmv-correct');
const WRONG = document.getElementById('dmv-wrong');
const INFORMATII = document.getElementById('dmv-info-close');

let ACTIVE_QUESTIONS = [];
let SELECTED_ANSWERS = [];
let CORRECT_ANSWERS = 0;
let WRONG_ANSWERS = 0;
let SKIPPED = 0;
let interval = null;

const NumberToLetter = number => {
    const code = 'A'.charCodeAt(0);
    return String.fromCharCode(code + number);
}

const WatchModifyButton = () => SELECTED_ANSWERS.length > 0 ? MODIFY_BUTTON.disabled = false : MODIFY_BUTTON.disabled = true;
const WatchSendButton = () => SELECTED_ANSWERS.length > 0 ? SEND_BUTTON.disabled = false : SEND_BUTTON.disabled = true;

const ClearSelectedAnswers = () => {
    SELECTED_ANSWERS.forEach(answer => answer.element.id = '');
    SELECTED_ANSWERS = [];
    WatchModifyButton();
    WatchSendButton();
}

const CreateAnswer = (answer, index) => {
    let element = document.createElement('div');

    element.className = 'dmv-question-button';
    element.innerHTML = `<div class='dmv-variant'>${NumberToLetter(index)}</div><div class='dmv-q-title'>${answer.label}</div>`;
    
    element.addEventListener('click', () => {
        let active = element.id === 'active';
        if (!active) {
            element.id = 'active';
            SELECTED_ANSWERS.push({ index, answer, element });
            WatchModifyButton();
            WatchSendButton();
        }
    });

    return element;
}

const ResetData = () => {
    let container = document.querySelector('.dmv-question-content');

    container.innerHTML = '';

    WatchModifyButton();
    WatchSendButton();

    CORRECT_ANSWERS = 0;
    WRONG_ANSWERS = 0;

    TOTAL.innerText = QUESTIONS_PER_TEST;
    REMAINING.innerText = QUESTIONS_PER_TEST;
    TIMER.innerText = '30 : 00';
    SKIPPED = 0;
}

const PickRandomQuestion = () => QUESTIONS[Math.floor(Math.random() * QUESTIONS.length)];
const QuestionAlreadyExists = question => ACTIVE_QUESTIONS.indexOf(question) === -1 ? false : true;
const AppendQuestion = question => ACTIVE_QUESTIONS.push(question);

const GenerateRandomQuestions = () => {
    for (let i = 1; i <= QUESTIONS_PER_TEST; i++) {
        let question = PickRandomQuestion();
     
        if (QuestionAlreadyExists(question))
            question = PickRandomQuestion();
     
        AppendQuestion(question);
    }
}

const FinishTest = verdict => {
    QUESTION_CONTENT.innerHTML = '';
    QUESTION_CONTENT.id = 'type-one';
    clearInterval(interval);

    MODIFY_BUTTON.disabled = true;
    SEND_BUTTON.disabled = true;
    LATER_BUTTON.disabled = true;

    if (verdict) {
        QUESTION_CONTENT.innerHTML = `
            <div class='dmv-question-content'>
                <div class='dmv-result' id='success'>
                    <i class="fa-solid fa-circle-check"></i>
                    <h1>Testul a luat sfarsit. Ati fost declarat <b>ADMIS</b> la examenul de teorie!</h1>
                </div>
            </div>
        `;

        setTimeout(() => {
            $('.dmv-wrapper').fadeOut(1000);
            $.post("https://vrp/dmv_result", JSON.stringify({ verdict: true }));
        }, 1000);
    } else {
        QUESTION_CONTENT.innerHTML = `
            <div class='dmv-question-content'>
                <div class='dmv-result' id='error'>
                    <i class="fa-solid fa-circle-xmark"></i>
                    <h1>Testul a luat sfarsit. Ati fost declarat <b>RESPINS</b> la examenul de teorie.</h1>
                </div>
            </div>
        `;
        setTimeout(() => {
            $('.dmv-wrapper').fadeOut(1000);
            $.post("https://vrp/dmv_result", JSON.stringify({ verdict: false }));
        }, 1000);
    }
}

const SetQuestion = content => {
    let container = document.querySelector('.dmv-question-content');

    container.innerHTML = `
        <div class='dmv-title'>
            <h1 id='question_title'>${content.title}</h1>
        </div>
        <div class="dmv-list" id='question_list'></div>
        <div class="image" id='question_image' style='display: ${content.image ? 'block' : 'none'}'>
            ${content.image ? `<img id='dmv-question_img' src='${content.image}' />` : ''}
        </div>
    `;

    if (content.image) QUESTION_CONTENT.id = 'type-two';
    else QUESTION_CONTENT.id = 'type-one';
    
    content.answers.forEach((answer, index) => {
        let parent = document.getElementById('question_list');
        let child = CreateAnswer(answer, index);
        parent.appendChild(child);
    });
}

const NextQuestion = () => {
    ACTIVE_QUESTIONS = ACTIVE_QUESTIONS.slice(1);
    SetQuestion(ACTIVE_QUESTIONS[0]);
}

MODIFY_BUTTON.addEventListener('click', ClearSelectedAnswers);

const calculateRequiredScore = answers => {
    let value = 0;
    answers.forEach(option => { if (option.correct) value++; });
    return value;
}

LATER_BUTTON.addEventListener('click', () => {
    let remaining_questions = QUESTIONS_PER_TEST - (CORRECT_ANSWERS + WRONG_ANSWERS);
    
    if (SKIPPED < QUESTIONS_PER_TEST &&  remaining_questions > 1) {
        let question = ACTIVE_QUESTIONS[0];
        ACTIVE_QUESTIONS = ACTIVE_QUESTIONS.slice(1);
        ACTIVE_QUESTIONS.push(question);
        SetQuestion(ACTIVE_QUESTIONS[0]);
        SKIPPED++;
        if (SKIPPED < QUESTIONS_PER_TEST)
            return LATER_BUTTON.disabled = false;
    }
});

SEND_BUTTON.addEventListener('click', () => {
    let answers = ACTIVE_QUESTIONS[0].answers;
    let requiredScore = calculateRequiredScore(answers);
    let score = 0;

    SELECTED_ANSWERS.forEach(option => {
        if (option.answer.correct && answers[option.index].correct) return score++; 
        else return score--;
    });

    if (score >= requiredScore) {
        CORRECT_ANSWERS++;
    } else {
        WRONG_ANSWERS++;
    }

    ClearSelectedAnswers();

    let remaining_questions = QUESTIONS_PER_TEST - (CORRECT_ANSWERS + WRONG_ANSWERS);
    REMAINING.innerText = remaining_questions;


    if (remaining_questions > 0) {
        return NextQuestion();
    } else {
        if (WRONG_ANSWERS > 2) {
            return FinishTest(false);
        } else {
            return FinishTest(true);
        }
    }
});

const StartTimer = options => {
    const format = n => n < 10 ? '0' + n.toString() : n.toString();

    options.minutes = options.minutes || 0;
    options.seconds = options.seconds || 0;

    TIMER.innerText = `${format(options.minutes)} : ${format(options.seconds)}`;
    
    let miliseconds = options.minutes * 60 * 1000 + options.seconds * 1000;

    interval = setInterval(function() {
        miliseconds -= 1000;
        let minutes = Math.floor(miliseconds / (1000 * 60));
        let seconds = Math.floor((miliseconds % (1000 * 60)) / 1000)
        TIMER.innerText = `${format(minutes)} : ${format(seconds)}`;
        if (miliseconds <= 0)
            return FinishTest(REMAINING > CORRECT_REQUIRED + 1 ?  false : true);
    }, 1000);
}

const StartTestDMV = (type) => {
    ResetData();
    GenerateRandomQuestions();
    SetQuestion(ACTIVE_QUESTIONS[0]);
    StartTimer({ minutes: 30, seconds: 0 });

    $(".dmv-wrapper").fadeIn();
    $.post("https://vrp/setFocus", JSON.stringify({state: true}));
}