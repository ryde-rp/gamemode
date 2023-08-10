QB.Phone.Settings = {};
QB.Phone.Settings.Background = "default-1";
QB.Phone.Settings.OpenedTab = null;
QB.Phone.Settings.Backgrounds = {
    'default-1': {label: "Standard 1"},
    'default-2': {label: "Standard 2"},
    'default-3': {label: "Standard 3"},
    'default-4': {label: "Standard 4"},
    'default-5': {label: "Standard 5"},
    'default-6': {label: "Standard 6"},
    'default-7': {label: "Standard 7"}
};

var PressedBackground = null;
var PressedBackgroundObject = null;
var OldBackground = null;
var IsChecked = null;

$(document).on('click', '.settings-app-tab', function(e){
    e.preventDefault();
    var PressedTab = $(this).data("settingstab");

    if (PressedTab == "background") {
        QB.Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        QB.Phone.Settings.OpenedTab = PressedTab;
    } else if (PressedTab == "numberrecognition") {
        var checkBoxes = $(".numberrec-box");
        QB.Phone.Data.AnonymousCall = !checkBoxes.prop("checked");
        checkBoxes.prop("checked", QB.Phone.Data.AnonymousCall);

        if (!QB.Phone.Data.AnonymousCall) {
            $("#numberrecognition > p").html('Dezactivat');
        } else {
            $("#numberrecognition > p").html('Activat');
        }
    }
});

$(document).on('click', '#accept-background', function(e){
    e.preventDefault();
    var hasCustomBackground = QB.Phone.Functions.IsBackgroundCustom();

    if (hasCustomBackground === false) {
        QB.Phone.Notifications.Add("fas fa-paint-brush", "Setari", "Imaginea "+QB.Phone.Settings.Backgrounds[QB.Phone.Settings.Background].label+" a fost setata ca imagine de fundal!")
        QB.Phone.Animations.TopSlideUp(".settings-"+QB.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+QB.Phone.Settings.Background+".png')"})
    } else {
        QB.Phone.Notifications.Add("fas fa-paint-brush", "Setari", "Imaginea a fost setata!")
        QB.Phone.Animations.TopSlideUp(".settings-"+QB.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('"+QB.Phone.Settings.Background+"')"});
    }

    $.post('https://vrp_phone/SetBackground', JSON.stringify({
        background: QB.Phone.Settings.Background,
    }))
});

QB.Phone.Functions.LoadMetaData = function(MetaData) {
    if (MetaData.background !== null && MetaData.background !== undefined) {
        QB.Phone.Settings.Background = MetaData.background;
    } else {
        QB.Phone.Settings.Background = "default-1";
    }

    var hasCustomBackground = QB.Phone.Functions.IsBackgroundCustom();

    if (!hasCustomBackground) {
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+QB.Phone.Settings.Background+".png')"})
    } else {
        $(".phone-background").css({"background-image":"url('"+QB.Phone.Settings.Background+"')"});
    }
}

$(document).on('click', '#cancel-background', function(e){
    e.preventDefault();
    QB.Phone.Animations.TopSlideUp(".settings-"+QB.Phone.Settings.OpenedTab+"-tab", 200, -100);
});

QB.Phone.Functions.IsBackgroundCustom = function() {
    var retval = true;
    $.each(QB.Phone.Settings.Backgrounds, function(i, background){
        if (QB.Phone.Settings.Background == i) {
            retval = false;
        }
    });
    return retval
}

$(document).on('click', '.background-item', function(e){
    e.preventDefault();
    PressedBackground = $(this).data('background');
    PressedBackgroundObject = this;
    OldBackground = $(this).parent().find('.fa-check-circle');
    IsChecked = $(this).find('.fa-check-circle');

    if (IsChecked.length === 0) {
        if (PressedBackground != "custom-background") {
            QB.Phone.Settings.Background = PressedBackground;
            $(OldBackground).fadeOut(50, function(){
                $(OldBackground).remove();
            });
            $(PressedBackgroundObject).append('<i class="fas fa-check-circle"></i>');
        } else {
            QB.Phone.Animations.TopSlideDown(".background-custom", 200, 13);
        }
    }
});

$(document).on('click', '#accept-custom-background', function(e){
    e.preventDefault();

    QB.Phone.Settings.Background = $(".custom-background-input").val();
    $(OldBackground).fadeOut(50, function(){
        $(OldBackground).remove();
    });
    $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
    QB.Phone.Animations.TopSlideUp(".background-custom", 200, -23);
});

$(document).on('click', '#cancel-custom-background', function(e){
    e.preventDefault();

    QB.Phone.Animations.TopSlideUp(".background-custom", 200, -23);
});