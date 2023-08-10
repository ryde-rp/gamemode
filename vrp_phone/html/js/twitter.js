var CurrentTwitterTab = "twitter-home";
let clicked = false;
let photos = [];

const homeTabObj = $(".twitter-home-tab");
const selfTabObj = $(".twitter-self-tab");

const setupTweets = (Tweets) => {
    Tweets = Tweets.reverse();

    if (Tweets !== null && Tweets !== undefined && Tweets !== "" && Tweets.length > 0) {
        homeTabObj.html("");
        $.each(Tweets, function (i, Tweet) {
            let TwtMessage = Tweet.msg;
            var TimeAgo = QB.Phone.Functions.formatTime(Tweet.time);
            
            if (TimeAgo == "Acum") {
            	TimeAgo = "cateva secunde"
            }

            let usernameFormat = Tweet.firstName + ' ' + Tweet.lastName
            let PictureUrl = "./img/default.png"

            if (!Tweet.url) {
            	Tweet.url = "";
            }

            if (Tweet.url == "" && Tweet.msg != "") {
                let TweetElement = '<div class="twitter-tweet" data-twtid = "' + Tweet.id + '" data-twthandler="@' + usernameFormat.replace(" ", "_") + '">' +
                    '<div class="tweet-tweeter">' + Tweet.firstName + ' ' + Tweet.lastName + ' &nbsp;<span><br> <span style="opacity: .5;"><i class="far fa-clock"></i> &nbsp; Postat acum ' + TimeAgo + '</span></span></div>' +
                    '<div class="tweet-message">' + Tweet.msg + '</div>' +
                    '<div class="twt-img" style="top: 1vh;"><img src="' + PictureUrl + '" class="tweeter-image"></div>' +
                    '<div class="tweet-reply"><i class="fas fa-reply"></i> &nbsp; Răspunde</div>'
                '</div>';

                homeTabObj.prepend(TweetElement);
            } else if (Tweet.url != "" && Tweet.msg == "") {
                let TweetElement = '<div class="twitter-tweet" data-twtid = "' + Tweet.id + '" data-twthandler="@' + usernameFormat.replace(" ", "_") + '">' +
                    '<div class="tweet-tweeter">' + Tweet.firstName + ' ' + Tweet.lastName + ' &nbsp;<span><br> <span style="opacity: .5;"><i class="far fa-clock"></i> &nbsp; Postat acum ' + TimeAgo + '</span></span></div>' +
                    '<div class="tweet-message"></div>' +
                    '<img class="image" src= "' + Tweet.url + '" style="border-radius: 2px; width: 68%; position: relative; z-index: 1; left: 2.5vw; margin: .6rem .5rem .6rem 1rem; height: auto;">' +
                    '<div class="twt-img" style="top: 1vh;"><img src="' + PictureUrl + '" class="tweeter-image"></div>' +
                    '<div class="tweet-reply"><i class="fas fa-reply"></i> &nbsp; Răspunde</div>'
                '</div>';


                homeTabObj.prepend(TweetElement);
            } else if (Tweet.url != "" && Tweet.msg != "") {
                let TweetElement = '<div class="twitter-tweet" data-twtid = "' + Tweet.id + '" data-twthandler="@' + usernameFormat.replace(" ", "_") + '">' +
                    '<div class="tweet-tweeter">' + Tweet.firstName + ' ' + Tweet.lastName + ' &nbsp;<span><br> <span style="opacity: .5;"><i class="far fa-clock"></i> &nbsp; Postat acum ' + TimeAgo + '</span></span></div>' +
                    '<div class="tweet-message">' + Tweet.msg + '</div>' +
                    '<img class="image" src= "' + Tweet.url + '" style="border-radius: 2px; width: 68%; position: relative; z-index: 1; left: 2.5vw; margin: .6rem .5rem .6rem 1rem; height: auto;">' +
                    '<div class="twt-img" style="top: 1vh;"><img src="' + PictureUrl + '" class="tweeter-image"></div>' +
                    '<div class="tweet-reply"><i class="fas fa-reply"></i> &nbsp; Răspunde</div>'
                '</div>';

                homeTabObj.prepend(TweetElement);
            }

        });
    } else {
        homeTabObj.html(`<center style='color: #888; font-size: 2vh; margin-top: 8vh;'><i class='fas fa-frown'></i><br/>Nu sunt tweet-uri postate.</center>`);

    }

}

const setupUserTweets = (Tweets) => {
    Tweets = Tweets.reverse();

    if (Tweets !== null && Tweets !== undefined && Tweets !== "" && Tweets.length > 0) {
        selfTabObj.html("");
        $.each(Tweets, function (i, Tweet) {
            var TimeAgo = QB.Phone.Functions.formatTime(Tweet.time);
            
            if (TimeAgo == "Acum") {
            	TimeAgo = "cateva secunde"
            }

            let usernameFormat = Tweet.firstName + ' ' + Tweet.lastName
            let PictureUrl = "./img/default.png"

            if (!Tweet.url) {
            	Tweet.url = "";
            }

            if (Tweet.url == "" && Tweet.msg != "") {
                let TweetElement = '<div class="twitter-tweet" data-twtid = "' + Tweet.id + '" data-twthandler="@' + usernameFormat.replace(" ", "_") + '">' +
                    '<div class="tweet-tweeter">' + Tweet.firstName + ' ' + Tweet.lastName + ' &nbsp;<span><br> <span style="opacity: .5;"><i class="far fa-clock"></i> &nbsp; Postat acum ' + TimeAgo + '</span></span></div>' +
                    '<div class="tweet-message">' + Tweet.msg + '</div>' +
                    '<div class="twt-img" style="top: 1vh;"><img src="' + PictureUrl + '" class="tweeter-image"></div>' +
                    '<div class="tweet-delete"><i class="fas fa-trash-alt"></i> &nbsp; Șterge</div>'
                '</div>';

                selfTabObj.prepend(TweetElement);
            } else if (Tweet.url != "" && Tweet.msg == "") {
                let TweetElement = '<div class="twitter-tweet" data-twtid = "' + Tweet.id + '" data-twthandler="@' + usernameFormat.replace(" ", "_") + '">' +
                    '<div class="tweet-tweeter">' + Tweet.firstName + ' ' + Tweet.lastName + ' &nbsp;<span><br> <span style="opacity: .5;"><i class="far fa-clock"></i> &nbsp; Postat acum ' + TimeAgo + '</span></span></div>' +
                    '<div class="tweet-message"></div>' +
                    '<img class="image" src= "' + Tweet.url + '" style="border-radius: 2px; width: 68%; position: relative; z-index: 1; left: 2.5vw; margin: .6rem .5rem .6rem 1rem; height: auto;">' +
                    '<div class="twt-img" style="top: 1vh;"><img src="' + PictureUrl + '" class="tweeter-image"></div>' +
                    '<div class="tweet-delete"><i class="fas fa-trash-alt"></i> &nbsp; Șterge</div>'
                '</div>';


                selfTabObj.prepend(TweetElement);
            } else if (Tweet.url != "" && Tweet.msg != "") {
                let TweetElement = '<div class="twitter-tweet" data-twtid = "' + Tweet.id + '" data-twthandler="@' + usernameFormat.replace(" ", "_") + '">' +
                    '<div class="tweet-tweeter">' + Tweet.firstName + ' ' + Tweet.lastName + ' &nbsp;<span><br> <span style="opacity: .5;"><i class="far fa-clock"></i> &nbsp; Postat acum ' + TimeAgo + '</span></span></div>' +
                    '<div class="tweet-message">' + Tweet.msg + '</div>' +
                    '<img class="image" src= "' + Tweet.url + '" style="border-radius: 2px; width: 68%; position: relative; z-index: 1; left: 2.5vw; margin: .6rem .5rem .6rem 1rem; height: auto;">' +
                    '<div class="twt-img" style="top: 1vh;"><img src="' + PictureUrl + '" class="tweeter-image"></div>' +
                    '<div class="tweet-delete"><i class="fas fa-trash-alt"></i> &nbsp; Șterge</div>'
                '</div>';

                selfTabObj.prepend(TweetElement);
            }

        });
    } else {
        selfTabObj.html(`<center style='color: #888; font-size: 2vh; margin-top: 8vh;'><i class='fas fa-frown'></i><br/>Nu ai postat nici un tweet.</center>`);

    }

}

const catchMentionTag = (elem) => {
    var $temp = $("<input>");
    $("body").append($temp);
    $temp.val($(elem).data('mentiontag')).select();
    QB.Phone.Notifications.Add("fab fa-twitter", "Twitter", $(elem).data('mentiontag') + " copiat!", "rgb(27, 149, 224)", 1250);
    document.execCommand("copy");
    $temp.remove();
}

$(document).on('click', '.twitter-header-tab', function(e) {
    e.preventDefault();

    var PressedTwitterTab = $(this).data('twittertab');
    var PreviousTwitterTabObject = $('.twitter-header').find('[data-twittertab="' + CurrentTwitterTab + '"]');

    if (PressedTwitterTab !== CurrentTwitterTab) {
        $(this).addClass('selected-twitter-header-tab');
        $(PreviousTwitterTabObject).removeClass('selected-twitter-header-tab');

        $("." + CurrentTwitterTab + "-tab").css({"display": "none"});
        $("." + PressedTwitterTab + "-tab").css({"display": "block"});

        if (PressedTwitterTab == "twitter-home") {

            $.post('https://vrp_phone/GetTweets', JSON.stringify({}), function (Tweets) {
                setupTweets(Tweets);

            });

        }

        if (PressedTwitterTab == "twitter-self") {
            $.post('https://vrp_phone/GetSelfTweets', JSON.stringify({}), function (selfdata) {
                setupUserTweets(selfdata)
            })

        }

        CurrentTwitterTab = PressedTwitterTab;
    } else if (CurrentTwitterTab == "twitter-home" && PressedTwitterTab == "twitter-home") {
        event.preventDefault();

        $.post('https://vrp_phone/GetTweets', JSON.stringify({}), function (Tweets) {
            setupTweets(Tweets);
        });
    } else if (CurrentTwitterTab == "twitter-self" && PressedTwitterTab == "twitter-self") {
        event.preventDefault();

        $.post('https://vrp_phone/GetSelfTweets', JSON.stringify({}), function (selfTweets) {
            setupUserTweets(selfTweets)
        })
    }


}).on('click', '.twitter-new-tweet', function(e) {
    e.preventDefault();
    QB.Phone.Animations.TopSlideDown(".twitter-new-tweet-tab", 450, 0);
}).on('click', '.tweet-reply', function(e) {
    e.preventDefault();
    var TwtName = $(this).parent().data('twthandler');
    var text = $(this).parent().data();
    $("#tweet-new-message").val(TwtName + " ");
    QB.Phone.Animations.TopSlideDown(".twitter-new-tweet-tab", 450, 0);
}).on('click', '.tweet-delete', function(e) {
    e.preventDefault();
    var id = $(this).parent().data('twtid');
    
    $.post('https://vrp_phone/DeleteTweet', JSON.stringify({
        id: id,
    }));
}).on('click', '#send-tweet', function(e) {
    e.preventDefault();

    var TweetMessage = $("#tweet-new-message").val();
    var TweetUrl = $("#tweet-new-url").val();

    if (TweetMessage != "" || TweetUrl != "") {
        let CurrentDate = new Date();

        if (TweetUrl.length < 2) {
        	TweetUrl = null;
        }

        $.post('https://vrp_phone/PostNewTweet', JSON.stringify({
            msg: TweetMessage,
            img: TweetUrl,
        }));

        QB.Phone.Animations.TopSlideUp(".twitter-new-tweet-tab", 450, -120);
        $('#tweet-new-url').val("")
        $("#tweet-new-message").val("");
    } else {
        QB.Phone.Notifications.Add("fab fa-twitter", "Twitter", "Scrie un mesaj!", "#1DA1F2");
    }
}).on('click', '#send-photo', function(e) {
    e.preventDefault();

    QB.Phone.Functions.sendPhoto((photoUrl) => {
        if (!photoUrl)
            return false;

        $('#tweet-new-url').val(photoUrl.replace(/"/g, ""));
    });
}).on('click', '#cancel-tweet', function(e) {
    e.preventDefault();
    $('#tweet-new-url').val("")
    $("#tweet-new-message").val("");
    QB.Phone.Animations.TopSlideUp(".twitter-new-tweet-tab", 450, -120);
}).on('click', '.mentioned-tag', function(e) {
    e.preventDefault();
    catchMentionTag(this);
}).on('click', '.image', function(e) {
    if (!clicked) {
        var n = $(this).clone()

        $(n).appendTo('.tt').css({ "position": "absolute", "width": "500px", "height": "auto", "left": "-520px", "top": "-10px", "border-radius": "1rem" })

        clicked = true;
        photos.push(n)
    } else {
        for (var i = 0; i < photos.length; i++) {
            photos[i].remove();
        }

        clicked = false;
    }
});