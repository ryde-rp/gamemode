var OpenedMail = null;

const setupMailsApp = (Mails) => {
    var oneDate = new Date();
    var hours = oneDate.getHours();
    var minutes = oneDate.getMinutes();

    if (hours < 10)
        hours = "0" + hours;

    if (minutes < 10) {
        minutes = "0" + minutes;
    }

    oneDate = hours+":"+minutes;
    
    if (QB.Phone.Data.PlayerData.firstname){
        $("#mail-header-mail").html((QB.Phone.Data.PlayerData.firstname.charAt(0).toLowerCase()) + QB.Phone.Data.PlayerData.name.toLowerCase() + "@ryde.mail");
        $("#mail-header-lastsync").html("Ultima sincronizare "+oneDate);

        if (Object.keys(Mails).length > 0) {
            $(".mail-list").html("");
            $.each(Mails, function(i, mail){
                var element = '<div class="mail" id="mail-'+mail.mailid+'"><div class="mail-firstletter" style="background-color: #ffffff20;">'+mail.sender.charAt(0).toUpperCase()+'</div><span class="mail-sender" style="font-weight: bold;">'+mail.sender+'</span> <div class="mail-text"><p>'+mail.message+'</p></div></div>';

                $(".mail-list").prepend(element);
                $("#mail-"+mail.mailid).data('MailData', mail);
            });
        } else {
            $(".mail-list").html("<center style='color: #888; font-size: 2vh; margin-top: 8vh;'><i class='fas fa-frown'></i><br/>Nu ai nici un mail.</center>");
        }   
    }
}

const setupOneMail = (MailData) => {
    $(".mail-subject").html("<p><span style='font-weight: bold;'>"+MailData.sender+"</span><br>"+MailData.subject+"</p>");
    $(".mail-date").html("<p>"+"</p>");
    $(".mail-content").html("<p>"+MailData.message+"</p>");

    var AcceptElem = '<div class="opened-mail-footer-item" id="accept-mail"><i class="fas fa-check-circle mail-icon"></i></div>';
    var RemoveElem = '<div class="opened-mail-footer-item" id="remove-mail"><i class="fas fa-trash-alt mail-icon"></i></div>';

    $(".opened-mail-footer").html("");    

    if (MailData.button !== undefined && MailData.button !== null) {
        $(".opened-mail-footer").append(AcceptElem);
        $(".opened-mail-footer").append(RemoveElem);
        $(".opened-mail-footer-item").css({"width":"50%"});
    } else {
        $(".opened-mail-footer").append(RemoveElem);
        $(".opened-mail-footer-item").css({"width":"100%"});
    }
}

$(document).on('click', '.mail', function(e){
    e.preventDefault();

    $(".mail-home").animate({
        left: 30+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: 0+"vh"
    }, 300);

    var MailData = $("#"+$(this).attr('id')).data('MailData');
    setupOneMail(MailData);

    OpenedMail = $(this).attr('id');
}).on('click', '.mail-back', function(e){
    e.preventDefault();

    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
    OpenedMail = null;
}).on('click', '#accept-mail', function(e){
    e.preventDefault();
    var MailData = $("#"+OpenedMail).data('MailData');
    $.post('http://vrp_phone/AcceptMailButton', JSON.stringify({
        buttonEvent: MailData.button.buttonEvent,
        buttonData: MailData.button.buttonData,
        mailId: MailData.mailid,
    }));
    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
}).on('click', '#remove-mail', function(e){
    e.preventDefault();
    var MailData = $("#"+OpenedMail).data('MailData');
    $.post('https://vrp_phone/RemoveMail', JSON.stringify({
        mailId: MailData.mailid
    }));
    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
}).on("click", "#mail-header-deleteall", (e) => {
    e.preventDefault();
    $.post('https://vrp_phone/RemoveMail', JSON.stringify({
        deleteAll: true,
    }));
    $(".mail-home").animate({
        left: 0+"vh"
    }, 300);
    $(".opened-mail").animate({
        left: -30+"vh"
    }, 300);
});