
// Search

let WhatsappSearchActive = false;
let ExtraButtonsOpen = false;
const searchInput = $("#whatsapp-search-input");

$(document).ready(function(){
	searchInput.on("keyup", function() {
		var value = $(this).val().toLowerCase();
		$(".whatsapp-chats .whatsapp-chat").filter(function() {
			$(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
		});
	});
});

$(document).on('click', '#whatsapp-search-chats', function(e){
	e.preventDefault();

	if (searchInput.css('display') == "none") {
		searchInput.fadeIn(150);
		WhatsappSearchActive = true;
	} else {
		searchInput.fadeOut(150);
		WhatsappSearchActive = false;
	}
}).on('click', '#whatsapp-openedchat-message-extras', function(e){
	e.preventDefault();

	if (!ExtraButtonsOpen) {
		$(".whatsapp-extra-buttons").css({"display":"block"}).animate({
			left: 0+"vh"
		}, 250);
		ExtraButtonsOpen = true;
	} else {
		$(".whatsapp-extra-buttons").animate({
			left: -10+"vh"
		}, 250, function(){
			$(".whatsapp-extra-buttons").css({"display":"block"});
			ExtraButtonsOpen = false;
		});
	}
});

///

let openedChat = null;
const chatList = $(".whatsapp-chats");

QB.Phone.Functions.pwLoadFrontMessages = function(frontMessages) {
	chatList.html("");
	$.each(frontMessages, (index, element) => {

		element[1] = "img/default.png"; // De refacut poza custom.
		
		let div = '<div class="whatsapp-chat" data-number="'+element[0]+'" data-img="'+element[1]+'" data-name="'+element[2]+'"><div class="whatsapp-chat-picture" style="background-image: url('+element[1]+');"></div><div class="whatsapp-chat-name"><p>'+element[2]+'</p></div><div class="whatsapp-chat-lastmessage"><p>'+element[3]+'</p></div> <div class="whatsapp-chat-lastmessagetime"><p>'+QB.Phone.Functions.formatTime(element[4])+'</p></div></div>';
		chatList.append(div);
		
	});
}

const msgList = $(".whatsapp-openedchat-messages");
let msgCount = 0;

function addMessagesToChat(messages, liveMsg = false) {
	msgCount += messages.length;

	if(!liveMsg && messages.length < 15) {
		$("#whatsapp-openedchat-loadmsg").css("display", "none");
	}

	$.each(messages, (index, element) => {

		let div = "";
		switch(element[3]) {
			case 0:
				div = '<div class="whatsapp-openedchat-message whatsapp-openedchat-message-'+(element[2] ? 'me' : 'other')+'">'+element[0]+'<div class="whatsapp-openedchat-message-time">'+QB.Phone.Functions.formatTime(element[1])+'</div></div><div class="clearfix"></div>';
				break;
			case 1:
				div = '<div class="whatsapp-openedchat-message whatsapp-openedchat-message-'+(element[2] ? 'me' : 'other')+' whatsapp-shared-location" data-x="'+element[0].x+'" data-y="'+element[0].y+'"><span style="font-size: 1.2vh;"><i class="fas fa-map-marker-alt" style="font-size: 1vh;"></i> Locatie distribuita</span><div class="whatsapp-openedchat-message-time">'+QB.Phone.Functions.formatTime(element[1])+'</div></div><div class="clearfix"></div>'
				break;
			case 2:
				div = '<div class="whatsapp-openedchat-message whatsapp-openedchat-message-'+(element[2] ? 'me' : 'other')+'"><img class="wppimage" src='+element[0]+' style="border-radius:4px; width: 100%; position:relative; z-index: 1; right:1px;height: auto;"></div><div class="whatsapp-openedchat-message-time">'+QB.Phone.Functions.formatTime(element[1])+'</div></div><div class="clearfix"></div>'
				break;
		}
		
		if(liveMsg) {
			msgList.append(div);
		} else {
			$("#whatsapp-openedchat-loadmsg").after(div);
		}
	});

	let listObj = document.getElementsByClassName("whatsapp-openedchat-messages")[0];
	listObj.scroll(0, listObj.scrollHeight);
}

QB.Phone.Functions.pwAddChatMessage = function(number, theMessage) {
	if(openedChat === number) {
		addMessagesToChat([theMessage], true);
	}
	let contactDiv = $("[data-number="+number+"]");
	contactDiv.children(".whatsapp-chat-lastmessage").children("p").text((theMessage[2] ? 'Dvs.: ' : '') + theMessage[0]);
	contactDiv.children(".whatsapp-chat-lastmessagetime").children("p").text(QB.Phone.Functions.formatTime(theMessage[1]));
	chatList.prepend(contactDiv);
}

$(document).on('click', '.whatsapp-chat', function(e){
	e.preventDefault();

	let picture = $(this).attr('data-img');
	let number = $(this).attr('data-number');
	let name = $(this).attr('data-name');

	msgList.html('<div id="whatsapp-openedchat-loadmsg">Incarca mai multe...</div>');

	openedChat = number;
	msgCount = 0;

	if (WhatsappSearchActive) {
		searchInput.fadeOut(150);
	}

	$.post("https://vrp_phone/pwGetMessages", JSON.stringify({
		number: number,
		skip: msgCount
	}), (messages) => {
		addMessagesToChat(messages);
	});

	$(".whatsapp-openedchat").css({"display":"block"});
	$(".whatsapp-openedchat").animate({
		left: 0+"vh"
	},200);

	$(".whatsapp-chats").animate({
		left: 30+"vh"
	},200, function(){
		$(".whatsapp-chats").css({"display":"none"});
	});

	$(".whatsapp-openedchat-name").text(name);
	$(".whatsapp-openedchat-picture").css({"background-image":"url("+picture+")"});

}).on('click', "#whatsapp-openedchat-loadmsg", function(e) {
	e.preventDefault();

	if(openedChat) {
		let listObj = document.getElementsByClassName("whatsapp-openedchat-messages")[0];
		let beforeHeight = listObj.scrollHeight;

		$.post("https://vrp_phone/pwGetMessages", JSON.stringify({
			number: openedChat,
			skip: msgCount
		}), (messages) => {
			addMessagesToChat(messages);
			listObj.scroll(0, listObj.scrollHeight - beforeHeight);
		});
	}

}).on('click', '#whatsapp-openedchat-send', function(e){
	e.preventDefault();

	if(openedChat) {

		isNumberBlockedMe(openedChat, (blocked) => {
			if(!blocked) {
				let msg = $("#whatsapp-openedchat-message").val();

				if(typeof msg === "string" && msg.length > 0) {
					$.post("https://vrp_phone/SendMessage", JSON.stringify({
						msg: msg,
						to: openedChat
					}));
				}

				$("#whatsapp-openedchat-message").val('');
			} else {
				QB.Phone.Notifications.Add("fa-solid fa-ban", "Blocked", "Numarul tau este blocat");
			}
		});
	}

}).on('click', '#send-location', function(e){
		e.preventDefault();
		$("#whatsapp-openedchat-message-extras").trigger("click");
		if(openedChat) {

			isNumberBlockedMe(openedChat, (blocked) => {
				if(!blocked) {
					$.post('https://vrp_phone/SendMessage', JSON.stringify({
						msg: false,
						to: openedChat,
						msgType: 1
					}));
				} else {
					QB.Phone.Notifications.Add("fa-solid fa-ban", "Blocked", "Numarul tau este blocat");
				}
			});
		}
}).on('click', '.whatsapp-shared-location', function(e){
		e.preventDefault();

		let messageCoords = {
			x: $(this).data('x'),
			y: $(this).data('y')
		};

		$.post('https://vrp_phone/SharedLocation', JSON.stringify({
			coords: messageCoords
		}));
}).on('click', '#whatsapp-openedchat-back', function(e){
	e.preventDefault();

	if(openedChat) {
		openedChat = false;

		$(".whatsapp-chats").css({"display":"block"});
		$(".whatsapp-chats").animate({
			left: 0+"vh"
		}, 200);
		$(".whatsapp-openedchat").animate({
			left: -30+"vh"
		}, 200, function(){
			$(".whatsapp-openedchat").css({"display":"none"});
		});
	}

}).on('click', '#whatsapp-openedchat-call', function(e){
	e.preventDefault();

	if(openedChat) {
		QB.Phone.Functions.writeNumberInDial(openedChat);
	}

}).on('click', '#send-image', function(e) {
	if(openedChat) {
		let to = openedChat;
		e.preventDefault();
		$("#whatsapp-openedchat-message-extras").trigger("click");

		// $.post('https://vrp_phone/TakePhoto', "{}", function(url) {
		// 	if(url) {
		// 		QB.Phone.Functions.Open();
		// 		$.post("https://vrp_phone/SendMessage", JSON.stringify({
		// 			msg: url,
		// 			to: to,
		// 			msgType: 2
		// 		}));
		// 	}
		// });
		// QB.Phone.Functions.Close();


		isNumberBlockedMe(to, (blocked) => {
			if(!blocked) {
				QB.Phone.Functions.sendPhoto(function(url) {
					if(url !== false) {
						$.post("https://vrp_phone/SendMessage", JSON.stringify({
							msg: url,
							to: to,
							msgType: 2
						}));
					}
				});
			} else {
				QB.Phone.Notifications.Add("fa-solid fa-ban", "Blocked", "Numarul tau este blocat");
			}
		});

	}
}).on('click', '.wppimage', function(e){
		e.preventDefault();
		let source = $(this).attr('src')
		QB.Screen.popUp(source)
}).keydown(function(e) {

	if(openedChat) {
		if(e.which === 13) {
			e.preventDefault();
			$("#whatsapp-openedchat-send").trigger("click");
		} else if(e.which === 8) {
			if(!$('#whatsapp-openedchat-message').is(':focus')) {
				e.preventDefault();
				$("#whatsapp-openedchat-back").trigger("click");
			}
		}
	}
	

});
