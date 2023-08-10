let sendingPhoto = false, canCloseSendingPhoto = false, reOpenGalleryApp = false;

function setUpGalleryData(Images){
    $(".gallery-images").html("");
    if (Images != null) {
        $.each(Images, function(i, image){
            var Element = '<div class="gallery-image"><img src="'+image.image+'" data-gallery-date="'+image.date+'" class="tumbnail"></div>';
            
            $(".gallery-images").append(Element);
        });
    }
}

QB.Phone.Functions.cancelSendingPhoto = function() {
    if(sendingPhoto !== false) {
        sendingPhoto = false;
        canCloseSendingPhoto = false;
        reOpenGalleryApp = false;
        $(".use-photo-container").css({bottom: "-25%"});
    }
}

QB.Phone.Functions.sendPhoto = function(cb) {
    if(sendingPhoto) return false;

    $(".use-photo-container").animate({
        bottom: "0%"
    }, function() {
        sendingPhoto = cb;
        canCloseSendingPhoto = true;
    });
}

$(".use-photo-container").on("click", "#use-camera", function(e) {

    if(sendingPhoto !== false) {
        canCloseSendingPhoto = false;
        e.preventDefault();
        QB.Phone.Functions.Close();
        $.post('https://vrp_phone/TakePhoto', "{}", (url) => {
            if(url) {
                $(".use-photo-container").css({bottom: "-25%"});
                QB.Phone.Functions.Open();
                sendingPhoto(url);
                sendingPhoto = false;
            }
        });
    }
    
}).on("click", "#use-gallery", function(e) {
    if(sendingPhoto !== false) {

        $.post('https://vrp_phone/GetGalleryData', JSON.stringify({}), function(data){
            setUpGalleryData(data);
        });

        canCloseSendingPhoto = false;
        e.preventDefault();
        $(".use-photo-container").animate({
            bottom: "-25%"
        }, function() {

            reOpenGalleryApp = QB.Phone.Data.currentApplication;
            QB.Phone.Animations.TopSlideUp('.gallery-application-container', 400, -160);
            QB.Phone.Animations.TopSlideUp('.'+QB.Phone.Data.currentApplication+"-app", 400, -160);
            setTimeout(function(){
                QB.Phone.Functions.ToggleApp(QB.Phone.Data.currentApplication, "none");
                
                setTimeout(function() {
                    QB.Phone.Animations.TopSlideDown('.gallery-application-container', 300, 0);
                    QB.Phone.Functions.ToggleApp("gallery", "block");
                }, 200)
            
            }, 400)
            QB.Phone.Functions.HeaderTextColor("white", 300);

            QB.Phone.Data.currentApplication = "gallery";
        });


    }
});

$(".gallery-app").on('click', '.tumbnail', function(e) {
    e.preventDefault();

    let source = $(this).attr('src');

    if(sendingPhoto !== false) {

        QB.Phone.Animations.TopSlideUp('.'+reOpenGalleryApp+'-application-container', 400, -160);
        QB.Phone.Animations.TopSlideUp('.'+QB.Phone.Data.currentApplication+"-app", 400, -160);
        setTimeout(function(){
            QB.Phone.Functions.ToggleApp(QB.Phone.Data.currentApplication, "none");
            
            setTimeout(function() {
                QB.Phone.Animations.TopSlideDown('.'+reOpenGalleryApp+'-application-container', 300, 0);
                QB.Phone.Functions.ToggleApp(reOpenGalleryApp, "block");
            }, 200)
        
        }, 400)
        QB.Phone.Data.currentApplication = reOpenGalleryApp;

        sendingPhoto(source);
        sendingPhoto = false;

    } else {
        // QB.Screen.popUp(source)
        $(".gallery-homescreen").animate({
            right: "30vh"
        }, 200);
        $(".gallery-detailscreen").animate({
            right: "0vh"
        }, 200);
        $('#imagedata').attr("src", source);


        let date = parseInt(this.dataset.galleryDate);
        let d = new Date(date*1000);

        let minute = d.getMinutes();
        if(minute < 10) minute = "0" + minute;

        let hour = d.getHours();
        if(hour < 10) hour = "0" + hour;

        let day = d.getDate();
        if(day < 10) day = "0" + day;

        let month = d.getMonth() + 1;
        if(month < 10) month = "0" + month;

        $('#gallery-date').html('<i class="fas fa-calendar-days"></i> &nbsp; ' + day + "." + month + "." + d.getFullYear() + " " + hour + ":" + minute);

        setTimeout(function() {
            $("#gallery-back").fadeIn();
            $("#gallery-delete").fadeIn();
        }, 300);
    }


}).on('click', '#gallery-take-photo', function(e) {
    e.preventDefault();
    $.post('https://vrp_phone/TakePhoto', JSON.stringify({}),function(url){
        setUpCameraApp(url)
    });
    QB.Phone.Functions.Close();
}).on('click', '.image', function(e) {
    e.preventDefault();
    let source = $(this).attr('src');
    QB.Screen.popUp(source);
}).on('click', '#gallery-delete', function(e) {
    e.preventDefault();
    let source = $('.image').attr('src');

    setTimeout(() => {
        $.post('https://vrp_phone/DeleteImage', JSON.stringify({image:source}), function(Hashtags){
            setTimeout(()=>{
                $('#gallery-back').click()
                $.post('https://vrp_phone/GetGalleryData', JSON.stringify({}), function(data){
                    setTimeout(()=>{
                        setUpGalleryData(data);
                    },200)
                });
            },200)
        })
        
    }, 200);
}).on('click', '#gallery-back', function(e) {
    e.preventDefault();

    $("#gallery-back").fadeOut(200);
    $("#gallery-delete").fadeOut(200);
    $(".gallery-homescreen").animate({
        right: "0vh"
    }, 200);
    $(".gallery-detailscreen").animate({
        right: "-30vh"
    }, 200);
});



$(window).click(function() {
    if(sendingPhoto !== false && canCloseSendingPhoto) {
        $(".use-photo-container").animate({
            bottom: "-25%"
        });
        sendingPhoto(false);
        sendingPhoto = false;
        canCloseSendingPhoto = false;
    }
});