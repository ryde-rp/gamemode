window.addEventListener('message', function(event) {
    if (event.data.act == "createIdentity") {
        document.body.style.display = "block";
    }
});

function checkName() {
    var lastname = $('#name-input').val();

    if (isNaN(lastname)) {
        document.getElementById('name-input').style.backgroundColor = '#1ed76065';
        document.getElementById('name-input').style.color = 'white';
    } else {
        document.getElementById('name-input').style.backgroundColor = '#ff5c5c80';
        document.getElementById('name-input').style.color = 'white';
    }
}

function checkLastName() {
    var lastname = $('#lastname-input').val();

    if (isNaN(lastname)) {
        document.getElementById('lastname-input').style.backgroundColor = '#1ed76065';
        document.getElementById('lastname-input').style.color = 'white';
    } else {
        document.getElementById('lastname-input').style.backgroundColor = '#ff5c5c80';
        document.getElementById('lastname-input').style.color = 'white';
    }
}


function checkDOB() {
    var date = new Date($('#dateofbirth-input').val());
    day = date.getDate();
    month = date.getMonth() + 1;
    year = date.getFullYear();
    if (isNaN(month) || isNaN(day) || isNaN(year)) {
        document.getElementById('dateofbirth-input').style.backgroundColor = '#ff5c5c80';
        document.getElementById('dateofbirth-input').style.color = 'white';
    }
    else {
        var dateInput = [month, day, year].join('/');

        var regExp = /^(\d{1,2})(\/|-)(\d{1,2})(\/|-)(\d{4})$/;
        var dateArray = dateInput.match(regExp);

        if (dateArray == null){
            return false;
        }

        month = dateArray[1];
        day= dateArray[3];
        year = dateArray[5];        

        if (month < 1 || month > 12){
            document.getElementById('dateofbirth-input').style.backgroundColor = '#ff5c5c80';
            document.getElementById('dateofbirth-input').style.color = 'white';
        }
        else if (day < 1 || day> 31) { 
            document.getElementById('dateofbirth-input').style.backgroundColor = '#ff5c5c80';
            document.getElementById('dateofbirth-input').style.color = 'white';
        }
        else if ((month==4 || month==6 || month==9 || month==11) && day ==31) {
            document.getElementById('dateofbirth-input').style.backgroundColor = '#ff5c5c80';
            document.getElementById('dateofbirth-input').style.color = 'white';
        }
        else if (month == 2) {
            var isLeapYear = (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0));
            if (day> 29 || (day ==29 && !isLeapYear)){
                document.getElementById('dateofbirth-input').style.backgroundColor = '#ff5c5c80';
                document.getElementById('dateofbirth-input').style.color = 'white';
            }
        }
        else if ( year <= 1900) {
            document.getElementById('dateofbirth-input').style.backgroundColor = '#ff5c5c80';
            document.getElementById('dateofbirth-input').style.color = 'white';
        }
        else if ( (new Date().getFullYear()) - year < 18) {
            document.getElementById('dateofbirth-input').style.backgroundColor = '#ff5c5c80';
            document.getElementById('dateofbirth-input').style.color = 'white';
        }
        else {
            document.getElementById('dateofbirth-input').style.backgroundColor = '#1ed76065';
            document.getElementById('dateofbirth-input').style.color = 'white';	
        }				
    }
}

function checkHeight() {
    var height = $('#height-input').val();

    if (height < 100 || height > 190) {
        document.getElementById('height-input').style.backgroundColor = '#ff5c5c80';
        document.getElementById('height-input').style.color = 'white';
    } else {
        document.getElementById('height-input').style.backgroundColor = '#1ed76065';
        document.getElementById('height-input').style.color = 'white';
    }
}

function register() {
    var dateCheck = new Date($("#dateofbirth-input").val());
    var sex = $("input[type='radio'][name='sex']:checked").val();
    var firstname = $("#name-input").val();
    var lastname = $("#lastname-input").val()
    var height = $("#height-input").val()

    if (dateCheck == "Invalid Date") {
        document.getElementById('dateofbirth-input').style.backgroundColor = '#ff5c5c80';
        document.getElementById('dateofbirth-input').style.color = 'white';
    }
    if (sex == 'undefined') {
    }
    if (firstname == '') {
        document.getElementById('name-input').style.backgroundColor = '#ff5c5c80';
        document.getElementById('name-input').style.color = 'white';
    }
    if (lastname == '') {
        document.getElementById('lastname-input').style.backgroundColor = '#ff5c5c80';
        document.getElementById('lastname-input').style.color = 'white';
    }
    if (height == '' || height > 190) {
        document.getElementById('height-input').style.backgroundColor = '#ff5c5c80';
        document.getElementById('height-input').style.color = 'white';
    }
    else {
        var ye = new Intl.DateTimeFormat('en', { year: 'numeric' }).format(dateCheck)        
        var varsta = (new Date().getFullYear()) - parseInt(ye);
        if (varsta < 18) {
            varsta = 18;
        }

        $.post('https://vrp_identity/createIdentity', JSON.stringify({
            firstname: firstname,
            name: lastname,
            age: parseInt(varsta),
            sex: sex.toUpperCase(),
        }));

        document.body.style.display = "none";
    }
}