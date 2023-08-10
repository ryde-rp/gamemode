window.addEventListener("message",function(event){
    var data = event.data;
    switch(data.action) {
        case 'OpenAlert':
            $('.robbery-alert').show();
            $('.alert-text').text(data.text);
            setTimeout(function(){
                $('.robbery-alert').fadeOut();
            }, 9000);
        break
    }
});