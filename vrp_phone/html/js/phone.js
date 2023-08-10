var ContactSearchActive = false;
var CurrentFooterTab = "contacts";
var CallData = {};
var ClearNumberTimer = null;
var keyPadHTML = "";


function isNumberBlockedMe(number, cb) {
	$.post("https://vrp_phone/isContactBlockedMe", JSON.stringify({number: number}), (result) => {
		cb(result)
	});
}

$(document).on('click', '.phone-app-footer-button', function(e){
	e.preventDefault();

	var PressedFooterTab = $(this).data('phonefootertab');

	if (PressedFooterTab !== CurrentFooterTab) {
		$('.phone-app-footer').find('[data-phonefootertab="'+CurrentFooterTab+'"]').removeClass('phone-selected-footer-tab');
		$(this).addClass('phone-selected-footer-tab');

		$(".phone-"+CurrentFooterTab).hide();
		$(".phone-"+PressedFooterTab).show();

		if (PressedFooterTab == "recent") {
			$.post('https://vrp_phone/ClearRecentAlerts');
		}

		CurrentFooterTab = PressedFooterTab;
	}
});

$(document).on("click", "#phone-search-icon", function(e){
	e.preventDefault();

	if (!ContactSearchActive) {
		$("#phone-plus-icon, #phone-blocked-icon").animate({
			opacity: "0.0",
			"display": "none"
		}, 150, function(){
			$("#contact-search").css({"display":"block"}).animate({
				opacity: "1.0",
			}, 150);
		});
	} else {
		$("#contact-search").animate({
			opacity: "0.0"
		}, 150, function(){
			$("#contact-search").css({"display":"none"});
			$("#phone-plus-icon, #phone-blocked-icon").animate({
				opacity: "1.0",
				display: "block",
			}, 150);
		});
	}

	ContactSearchActive = !ContactSearchActive;
});


QB.Phone.Functions.SetupRecentCalls = function(recentcalls) {
	$(".phone-recent-calls").html("");

	recentcalls = recentcalls.reverse();

	$.each(recentcalls, function(i, recentCall) {
		let FirstLetter = (recentCall.name).charAt(0);
		let TypeIcon = 'fa-solid fa-phone-missed';
		let IconStyle = "color: #e74c3c;";


		if (recentCall.type === "outgoing") {
			TypeIcon = 'fa-solid fa-phone-arrow-down-left';
			IconStyle = "color: #2ecc71;"; // font-size: 1.4vh;
		} else if(recentCall.type == "incoming") {
			TypeIcon = 'fa-solid fa-phone-arrow-up-right';
			IconStyle = "color: #2ecc71;"; // font-size: 1.4vh;
		}
		
		if (recentCall.anonymous) {
			FirstLetter = "A";
			recentCall.name = "Număr Ascuns";
		}
		var elem = '<div class="phone-recent-call" id="recent-'+i+'"><div class="phone-recent-call-image">'+FirstLetter+'</div> <div class="phone-recent-call-name">'+recentCall.name+'</div> <div class="phone-recent-call-type"><i class="'+TypeIcon+'" style="'+IconStyle+'"></i></div> <div class="phone-recent-call-time">'+recentCall.time+'</div> </div>'

		$(".phone-recent-calls").append(elem);
		if(!recentCall.anonymous) {
			$("#recent-"+i).data('recentData', recentCall);
		} else {
			$("#recent-"+i).data('recentData', {anonymous: true});
		}
	});
}

$(document).on('click', '.phone-recent-call', function(e) {
	e.preventDefault();
	var RecendId = $(this).attr('id');
	var RecentData = $("#"+RecendId).data('recentData');
	if(!RecentData.anonymous) {
		if(RecentData.number !== RecentData.name) {
			cData = {
				number: RecentData.number,
				name: RecentData.name
			}

			isNumberBlockedMe(cData.number, (blocked) => {
				if(!blocked) {
					$.post('https://vrp_phone/CallContact', JSON.stringify({
						ContactData: cData,
						Anonymous: QB.Phone.Data.AnonymousCall
					}), function(status){
						if (cData.number !== QB.Phone.Data.PlayerData.phone) {
							if (status.IsOnline) {
								if (status.CanCall) {
									if (!status.InCall) {
										if (QB.Phone.Data.AnonymousCall) {
											QB.Phone.Notifications.Add("fas fa-phone", "Phone", "You started a anonymous call!");
										}
										$(".phone-call-outgoing").css({"display":"block"});
										$(".phone-call-incoming").css({"display":"none"});
										$(".phone-call-ongoing").css({"display":"none"});
										$(".phone-call-outgoing-caller").html(cData.name);
										QB.Phone.Functions.HeaderTextColor("white", 400);
										QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
										setTimeout(function(){
											$(".phone-app").css({"display":"none"});
											QB.Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
											QB.Phone.Functions.ToggleApp("phone-call", "block");
										}, 450);

										CallData.name = cData.name;
										CallData.number = cData.number;

										QB.Phone.Data.currentApplication = "phone-call";
										QB.Phone.Functions.SetupCurrentCall({CallType: "outgoing", InCall: true, TargetData: CallData});
									} else {
										QB.Phone.Notifications.Add("fas fa-phone", "Phone", "Esti deja intr-un apel!");
									}
								} else {
									QB.Phone.Notifications.Add("fas fa-phone", "Phone", "Persoana este ocupată!");
								}
							} else {
								QB.Phone.Notifications.Add("fas fa-phone", "Phone", "Persoana nu este disponibila!");
							}
						} else {
							QB.Phone.Notifications.Add("fas fa-phone", "Phone", "Nu te poti apela singur!");
						}
					});
				} else {
					QB.Phone.Notifications.Add("fa-solid fa-ban", "Blocked", "Numarul tau este blocat");
				}
			});
		} else {
			QB.Phone.Functions.writeNumberInDial(RecentData.number);
		}
	} else {
		QB.Phone.Notifications.Add("fa-solid fa-question", "Phone", "Apelant ascuns");
	}	
});

$(document).on('click', ".phone-keypad-key-call", function(e){
	e.preventDefault();

	var InputNum = keyPadHTML;

	cData = {
		number: InputNum,
		name: InputNum,
	}

	isNumberBlockedMe(cData.number, (blocked) => {
		if(!blocked) {
			$.post('https://vrp_phone/CallContact', JSON.stringify({
				ContactData: cData,
				Anonymous: QB.Phone.Data.AnonymousCall,
			}), function(status){
				if (cData.number !== QB.Phone.Data.PlayerData.phone) {
					if (status.IsOnline) {
						if (status.CanCall) {
							if (!status.InCall) {
								$(".phone-call-outgoing").css({"display":"block"});
								$(".phone-call-incoming").css({"display":"none"});
								$(".phone-call-ongoing").css({"display":"none"});
								$(".phone-call-outgoing-caller").html(cData.name);
								QB.Phone.Functions.HeaderTextColor("white", 400);
								QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
								setTimeout(function(){
									$(".phone-app").css({"display":"none"});
									QB.Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
									QB.Phone.Functions.ToggleApp("phone-call", "block");
								}, 450);

								CallData.name = cData.name;
								CallData.number = cData.number;

								QB.Phone.Data.currentApplication = "phone-call";
								QB.Phone.Functions.SetupCurrentCall({CallType: "outgoing", InCall: true, TargetData: CallData});
							} else {
								QB.Phone.Notifications.Add("fas fa-phone", "Phone", "You're already in a call!");
							}
						} else {
							QB.Phone.Notifications.Add("fas fa-phone", "Phone", "This person is busy!");
						}
					} else {
						QB.Phone.Notifications.Add("fas fa-phone", "Phone", "This person is not available!");
					}
				} else {
					QB.Phone.Notifications.Add("fas fa-phone", "Phone", "You can't call yourself!");
				}
			});
		} else {
			QB.Phone.Notifications.Add("fa-solid fa-ban", "Blocked", "Numarul tau este blocat");
		}
	});
	
});

QB.Phone.Functions.setContactStatus = function(number, isOnline) {
	$(".phone-contact").each(function() {
		let data = $(this).data('contactData');

		if(data.number === number) {
			if(isOnline && !data.status) {

				$(this).find(".phone-contact-firstletter").css("background-color", "#2ecc71");
				let callBtn = '<i class="fas fa-phone-volume" id="phone-start-call"></i> ';
				$(this).find(".phone-contact-actions").prepend(callBtn);

				data.status = true;
			} else if(!isOnline && data.status) {

				$(this).find(".phone-contact-firstletter").css("background-color", "#e74c3c");
				$(this).find("#phone-start-call").remove();

				data.status = false;
			}
			$(this).data('contactData', data);
			return false;
		}
	})
}

QB.Phone.Functions.LoadContacts = function(myContacts) {
	var ContactsObject = $(".phone-contact-list");
	$(ContactsObject).html("");

	var TotalContacts = 0;

	$(".phone-contacts").hide();
	$(".phone-recent").hide();
	$(".phone-keypad").hide();

	$(".phone-"+CurrentFooterTab).show();

	$("#contact-search").on("keyup", function() {
		var value = $(this).val().toLowerCase();
		$(".phone-contact-list .phone-contact").filter(function() {
		  $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
		});
	});

	if (myContacts !== null) {

		QB.Phone.Data.Contacts = myContacts;

		$.each(myContacts, function(i, contact){
			contact.name = DOMPurify.sanitize(contact.name , {
				ALLOWED_TAGS: [],
				ALLOWED_ATTR: []
			});
			if (contact.name == '') contact.name = 'Hmm, I shouldn\'t be able to do this...'
			let ContactElement = '<div class="phone-contact" data-contactid="'+i+'"><div class="phone-contact-firstletter" style="background-color: #e74c3c;">'+((contact.name).charAt(0)).toUpperCase()+'</div><div class="phone-contact-name">'+contact.name+'</div><div class="phone-contact-actions"><i class="fab fa-whatsapp" id="new-chat-phone"></i> <i class="fas fa-user-edit" id="edit-contact"></i></div></div>'
			if (contact.status) {
				ContactElement = '<div class="phone-contact" data-contactid="'+i+'"><div class="phone-contact-firstletter" style="background-color: #2ecc71;">'+((contact.name).charAt(0)).toUpperCase()+'</div><div class="phone-contact-name">'+contact.name+'</div><div class="phone-contact-actions"><i class="fas fa-phone-volume" id="phone-start-call"></i> <i class="fab fa-whatsapp" id="new-chat-phone"></i> <i class="fas fa-user-edit" id="edit-contact"></i></div></div>'
			}
			TotalContacts = TotalContacts + 1
			$(ContactsObject).append(ContactElement);
			$("[data-contactid='"+i+"']").data('contactData', contact);
		});

		if(TotalContacts == 0) {
			$(ContactsObject).html("<center style='color: #888; font-size: 2vh; margin-top: 8vh;'><i class='fas fa-frown'></i><br/>Nu ai nici un contact</center>");
		}

		$("#total-contacts").text(TotalContacts + " contacte");
	} else {
		$("#total-contacts").text("0 contacte");
	}
};

QB.Phone.Functions.writeNumberInDial = function(number) {
	if(QB.Phone.Data.currentApplication !== "phone") {
		if(QB.Phone.Data.currentApplication) {
			QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
			QB.Phone.Animations.TopSlideUp('.'+QB.Phone.Data.currentApplication+"-app", 400, -160);
			setTimeout(function(){
				QB.Phone.Functions.ToggleApp(QB.Phone.Data.currentApplication, "none");
				
				setTimeout(function() {
					QB.Phone.Animations.TopSlideDown('.phone-application-container', 300, 0);
					QB.Phone.Functions.ToggleApp("phone", "block");
				}, 200)
			
			}, 400)
			QB.Phone.Functions.HeaderTextColor("white", 300);
		} else {
			QB.Phone.Animations.TopSlideDown('.phone-application-container', 300, 0);
			QB.Phone.Functions.ToggleApp("phone", "block");
		}
	}
	QB.Phone.Data.currentApplication = "phone";

	if(CurrentFooterTab !== "keypad") {
		$('.phone-app-footer').find('[data-phonefootertab="'+CurrentFooterTab+'"]').removeClass('phone-selected-footer-tab');
		$('.phone-app-footer').find('[data-phonefootertab="keypad"]').addClass('phone-selected-footer-tab');

		$(".phone-"+CurrentFooterTab).hide();
		$(".phone-keypad").show();

		CurrentFooterTab = "keypad";
	}

	$("#phone-keypad-input").text(number);
	keyPadHTML = number;
}

$(document).on('click', '#new-chat-phone', function(e){
	var ContactId = $(this).parent().parent().data('contactid');
	var ContactData = $("[data-contactid='"+ContactId+"']").data('contactData');

	if (ContactData.number !== QB.Phone.Data.PlayerData.phone) {
		$.post("https://vrp_phone/pwGetFrontMessages", "{}", (frontMessages) => {
			
			QB.Phone.Animations.TopSlideUp('.whatsapp-application-container', 400, -160);
			QB.Phone.Animations.TopSlideUp('.'+QB.Phone.Data.currentApplication+"-app", 400, -160);
			setTimeout(function(){
				QB.Phone.Functions.ToggleApp(QB.Phone.Data.currentApplication, "none");
				
				setTimeout(function() {
					QB.Phone.Animations.TopSlideDown('.whatsapp-application-container', 300, 0);
					QB.Phone.Functions.ToggleApp("whatsapp", "block");
				}, 200)
			
			}, 400)
			QB.Phone.Functions.HeaderTextColor("white", 300);

			QB.Phone.Data.currentApplication = "whatsapp";

			setTimeout(() => {
				QB.Phone.Functions.pwLoadFrontMessages(frontMessages);
				if($("[data-number="+ContactData.number+"]").length >= 1) {
					$("[data-number="+ContactData.number+"]").trigger("click");
				} else {
					let avatarUrl = "img/default.png"; // De refacut poza custom.
					let div = '<div class="whatsapp-chat" data-number="'+ContactData.number+'" data-img="'+avatarUrl+'" data-name="'+ContactData.name+'"><div class="whatsapp-chat-picture" style="background-image: url('+avatarUrl+');"></div><div class="whatsapp-chat-name"><p>'+ContactData.name+'</p></div><div class="whatsapp-chat-lastmessage"><p>Contact Nou !</p></div><div class="whatsapp-chat-lastmessagetime"><p>Now</p></div></div>';
					$(".whatsapp-chats").prepend(div);
					$("[data-number="+ContactData.number+"]").trigger("click");
				}
			}, 700);

		});

	} else {
		QB.Phone.Notifications.Add("fa fa-phone-alt", "Phone", "Nu poti sa-ti trimiti singur mesaje..", "default", 3500);
	}
});

var currentContactNumber = null;

$(document).on('click', '#edit-contact', function(e){
	e.preventDefault();
	var ContactId = $(this).parent().parent().data('contactid');
	var ContactData = $("[data-contactid='"+ContactId+"']").data('contactData');

	currentContactNumber = ContactData.number;

	$(".phone-edit-contact-header").text(ContactData.name+" Edit")
	$(".phone-edit-contact-name").val(ContactData.name);
	$(".phone-edit-contact-number").val(ContactData.number);

	QB.Phone.Animations.TopSlideDown(".phone-edit-contact", 200, 0);
});

$(document).on('click', '#edit-contact-save', function(e){
	e.preventDefault();

	var ContactName = DOMPurify.sanitize($(".phone-edit-contact-name").val() , {
		ALLOWED_TAGS: [],
		ALLOWED_ATTR: []
	});
	if (ContactName == '') ContactName = 'Hmm, I shouldn\'t be able to do this...'
	var ContactNumber = $(".phone-edit-contact-number").val();

	if (ContactName != "" && ContactNumber != "") {
		$.post('https://vrp_phone/EditContact', JSON.stringify({
			CurrentContactName: ContactName,
			CurrentContactNumber: ContactNumber,
			OldContactNumber: currentContactNumber
		}), function(PhoneContacts){
			QB.Phone.Functions.LoadContacts(PhoneContacts);
		});
		QB.Phone.Animations.TopSlideUp(".phone-edit-contact", 250, -100);
		setTimeout(function(){
			$(".phone-edit-contact-number").val("");
			$(".phone-edit-contact-name").val("");
		}, 250)
	} else {
		QB.Phone.Notifications.Add("fas fa-exclamation-circle", "Edit Contact", "Fill out all fields!");
	}
});

$(document).on('click', '#edit-contact-delete', function(e){
	e.preventDefault();

	var ContactNumber = $(".phone-edit-contact-number").val();

	$.post('https://vrp_phone/DeleteContact', JSON.stringify({
		CurrentContactNumber: ContactNumber
	}), function(PhoneContacts){
		QB.Phone.Functions.LoadContacts(PhoneContacts);
	});
	QB.Phone.Animations.TopSlideUp(".phone-edit-contact", 250, -100);
	setTimeout(function(){
		$(".phone-edit-contact-number").val("");
		$(".phone-edit-contact-name").val("");
	}, 250);
});

$(document).on('click', '#edit-contact-cancel', function(e){
	e.preventDefault();

	QB.Phone.Animations.TopSlideUp(".phone-edit-contact", 250, -100);
	setTimeout(function(){
		$(".phone-edit-contact-number").val("");
		$(".phone-edit-contact-name").val("");
	}, 250)
});

$(document).on('click', '.phone-keypad-key', function(e){
	e.preventDefault();
	var PressedButton = $(this).data('keypadvalue');
	if(keyPadHTML.length <= 15) {
		if (!isNaN(PressedButton)) {
			$("#phone-keypad-input").text(keyPadHTML + PressedButton)
		} else if (PressedButton == "-") {
			$("#phone-keypad-input").text(keyPadHTML + PressedButton)
		}
	}
	if (PressedButton == "*") {
		$("#phone-keypad-input").text(keyPadHTML.slice(0,-1));
	}

	keyPadHTML = $("#phone-keypad-input").text();
}).keydown(function(e) {
	if(CurrentFooterTab == "keypad" && QB.Phone.Data.currentApplication == "phone") {
		e.preventDefault();

		if(keyPadHTML.length <= 15) {
			if(e.keyCode >= 48 && e.keyCode <= 57) {
				let number = (e.keyCode - 48);
				$("#phone-keypad-input").text(keyPadHTML + number);
			} else if(e.keyCode >= 96 && e.keyCode <= 105) {
				let number = (e.keyCode - 96);
				$("#phone-keypad-input").text(keyPadHTML + number);
			}
		}
		if(e.keyCode == 8) {
			$("#phone-keypad-input").text(keyPadHTML.slice(0,-1));
		}

		keyPadHTML = $("#phone-keypad-input").text();
	}
});


$(document).on('click', '#phone-plus-icon', function(e){
	e.preventDefault();

	QB.Phone.Animations.TopSlideDown(".phone-add-contact", 200, 0);
}).on('click', "#phone-keypad-add", function(e) {
	e.preventDefault();

	if(keyPadHTML.length >= 1) {
		$("[data-phonefootertab='contacts']").click();
		setTimeout(() => {
			$("#add-contact-number").val(keyPadHTML);
			QB.Phone.Animations.TopSlideDown(".phone-add-contact", 200, 0);
		}, 500);
	} else {
		QB.Phone.Notifications.Add("fas fa-exclamation-circle", "Eroare", "Scrie un numar");
	}
});

const blockedListObj = $("#phone-blocked-list"); 
$(document).on('click', '#phone-blocked-icon', function(e){
	e.preventDefault();

	$.post("https://vrp_phone/getBlockedContacts", JSON.stringify({}), function(blockedList) {
		blockedListObj.empty();

		console.log(blockedList);

		if(blockedList.length > 0) {
			$.each(blockedList, (index, elem) => {
				blockedListObj.append(`<div>${elem}<i class="fa-solid fa-ban"></i></div>`);
			});
		} else {
			blockedListObj.html("<center style='color: #888; font-size: 2vh; margin-top: 8vh;'><i class='fas fa-face-smile'></i><br/>Nu ai nici un contact blocat.</center>")
		}
		
		QB.Phone.Animations.TopSlideDown(".phone-blocked-contact", 200, 0);
	})
});

$(document).on('click', '#add-contact-save', function(e){
	e.preventDefault();

	var ContactName = DOMPurify.sanitize($(".phone-add-contact-name").val() , {
		ALLOWED_TAGS: [],
		ALLOWED_ATTR: []
	});
	if (ContactName == '') ContactName = 'Hmm, I shouldn\'t be able to do this...'
	var ContactNumber = $("#add-contact-number").val();

	if (ContactName != "" && ContactNumber != "") {
		$.post('https://vrp_phone/AddNewContact', JSON.stringify({
			ContactName: ContactName,
			ContactNumber: ContactNumber
		}), function(PhoneContacts){
			QB.Phone.Functions.LoadContacts(PhoneContacts);
		});
		QB.Phone.Animations.TopSlideUp(".phone-add-contact", 250, -100);
		setTimeout(function(){
			$("#add-contact-number").val("");
			$(".phone-add-contact-name").val("");
		}, 250)
	} else {
		QB.Phone.Notifications.Add("fas fa-exclamation-circle", "Add Contact", "Fill out all fields!");
	}
});

$(document).on('click', '#add-contact-cancel', function(e){
	e.preventDefault();

	QB.Phone.Animations.TopSlideUp(".phone-add-contact", 250, -100);
	setTimeout(function(){
		$("#add-contact-number").val("");
		$(".phone-add-contact-name").val("");
	}, 250)
});

$(document).on('click', '#blocked-contact-save', function(e){
	e.preventDefault();

	var ContactNumber = $("#blocked-contact-number").val();

	if (ContactNumber != "") {
		$.post('https://vrp_phone/blockContact', JSON.stringify({
			number: ContactNumber
		}));
		QB.Phone.Animations.TopSlideUp(".phone-blocked-contact", 250, -100);
		setTimeout(function(){
			$("#blocked-contact-number").val("");
		}, 250)
	} else {
		QB.Phone.Notifications.Add("fas fa-exclamation-circle", "Block Contact", "Scrie un numar");
	}
}).on('click', '#blocked-contact-cancel', function(e){
	e.preventDefault();

	QB.Phone.Animations.TopSlideUp(".phone-blocked-contact", 250, -100);
	setTimeout(function(){
		$("#blocked-contact-number").val("");
	}, 250)
}).on('click', "#phone-blocked-list div i", function(e) {
	e.preventDefault();

	let obj = $(this).parent();
	let number = obj.text();

	$.post("https://vrp_phone/unblockContact", JSON.stringify({
		number: number
	}));
	
	obj.fadeOut(400, function() {
		$(this).remove();
	});
});


$(document).on('click', '#phone-start-call', function(e){
	e.preventDefault();

	var ContactId = $(this).parent().parent().data('contactid');
	var ContactData = $("[data-contactid='"+ContactId+"']").data('contactData');

	SetupCall(ContactData);
});

SetupCall = function(cData) {
	var retval = false;

	isNumberBlockedMe(cData.number, (blocked) => {
		if(!blocked) {
			$.post('https://vrp_phone/CallContact', JSON.stringify({
				ContactData: cData,
				Anonymous: QB.Phone.Data.AnonymousCall,
			}), function(status){
				if (cData.number !== QB.Phone.Data.PlayerData.phone) {
					if (status.IsOnline) {
						if (status.CanCall) {
							if (!status.InCall) {
								$(".phone-call-outgoing").css({"display":"block"});
								$(".phone-call-incoming").css({"display":"none"});
								$(".phone-call-ongoing").css({"display":"none"});
								$(".phone-call-outgoing-caller").html(cData.name);
								QB.Phone.Functions.HeaderTextColor("white", 400);
								QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
								setTimeout(function(){
									$(".phone-app").css({"display":"none"});
									QB.Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
									QB.Phone.Functions.ToggleApp("phone-call", "block");
								}, 450);

								CallData.name = cData.name;
								CallData.number = cData.number;

								QB.Phone.Data.currentApplication = "phone-call";
								QB.Phone.Functions.SetupCurrentCall({CallType: "outgoing", InCall: true, TargetData: CallData});
							} else {
								QB.Phone.Notifications.Add("fas fa-phone-slash", "Phone", "Ești deja într-un apel !");
							}
						} else {
							QB.Phone.Notifications.Add("fas fa-phone-slash", "Phone", "Linia apelată este momentan ocupată !");
						}
					} else {
						QB.Phone.Notifications.Add("fas fa-phone-slash", "Phone", "Persoana apelată are telefonul închis !");
					}
				} else {
					QB.Phone.Notifications.Add("fas fa-phone-slash", "Phone", "Linia apelată este momentan ocupată !");
				}
			});
		} else {
			QB.Phone.Notifications.Add("fa-solid fa-ban", "Blocked", "Numarul tau este blocat");
		}
	});

	
}

CancelOutgoingCall = function() {
	if (QB.Phone.Data.currentApplication == "phone-call") {
		QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
		QB.Phone.Animations.TopSlideUp('.'+QB.Phone.Data.currentApplication+"-app", 400, -160);
		setTimeout(function(){
			QB.Phone.Functions.ToggleApp(QB.Phone.Data.currentApplication, "none");
		}, 400)
		QB.Phone.Functions.HeaderTextColor("white", 300);

		QB.Phone.Data.CallActive = false;
		QB.Phone.Data.currentApplication = null;
	}
	QB.Phone.Functions.SetupCurrentCall({InCall: false});
}

$(document).on('click', '#outgoing-cancel', function(e){
	e.preventDefault();

	QB.Phone.Functions.SetupCurrentCall({InCall: false});
	$.post('https://vrp_phone/CancelOutgoingCall');
});

$(document).on('click', '#incoming-deny', function(e){
	e.preventDefault();

	QB.Phone.Functions.SetupCurrentCall({InCall: false});
	$.post('https://vrp_phone/DenyIncomingCall');
});

$(document).on('click', '#ongoing-cancel', function(e){
	e.preventDefault();

	QB.Phone.Functions.SetupCurrentCall({InCall: false});
	$.post('https://vrp_phone/CancelOngoingCall');
});

IncomingCallAlert = function(CallData, Canceled, AnonymousCall) {
	if (!Canceled) {

		QB.Phone.Functions.SetupCurrentCall({CallType: "incoming", InCall: true, TargetData: CallData});

		if(!QB.Phone.Data.IsOpen) {
			QB.Phone.Animations.BottomSlideUp('.container', 300, -55);
		}

		if (!QB.Phone.Data.CallActive) {

			$(".phone-call-outgoing").css({"display":"none"});
			$(".phone-call-incoming").css({"display":"block"});
			$(".phone-call-ongoing").css({"display":"none"});
			
			$(".phone-call-incoming-caller").html(CallData.name);
			QB.Phone.Data.CallActive = true;
		}
		// setTimeout(function(){
		// 	$(".call-notifications").addClass('call-notifications-shake');
		// 	setTimeout(function(){
		// 		$(".call-notifications").removeClass('call-notifications-shake');
		// 	}, 1000);
		// }, 400);
	} else {

		QB.Phone.Functions.SetupCurrentCall({InCall: false});

		if(!QB.Phone.Data.IsOpen) {
			QB.Phone.Animations.BottomSlideDown('.container', 300, -70);
		}

		// $(".call-notifications").animate({
		// 	right: -35+"vh"
		// }, 400);
		QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
		QB.Phone.Animations.TopSlideUp('.'+QB.Phone.Data.currentApplication+"-app", 400, -160);
		setTimeout(function(){
			$("."+QB.Phone.Data.currentApplication+"-app").css({"display":"none"});
			$(".phone-call-outgoing").css({"display":"none"});
			$(".phone-call-incoming").css({"display":"none"});
			$(".phone-call-ongoing").css({"display":"none"});
			// $(".call-notifications").css({"display":"block"});
		}, 400)
		QB.Phone.Functions.HeaderTextColor("white", 300);
		QB.Phone.Data.CallActive = false;
		QB.Phone.Data.currentApplication = null;
	}
}

QB.Phone.Functions.SetupCurrentCall = function(cData) {
	if (cData.InCall) {
		// CallData = cData;
		$(".phone-currentcall-container").css({"display":"block"});

		if (cData.CallType == "incoming") {
			$(".phone-currentcall-title").html("Incoming call");
		} else if (cData.CallType == "outgoing") {
			$(".phone-currentcall-title").html("Outgoing call");
		}

		// else if (cData.CallType == "ongoing") {
		// 	// $(".phone-currentcall-title").html("Apel ("+cData.CallTime+")");
		// }

		QB.Phone.Data.InPhoneCall = true;

		$(".phone-currentcall-contact").html(CallData.TargetData?.name || cData.TargetData?.name);
	} else {
		QB.Phone.Data.InPhoneCall = false;
		$(".phone-currentcall-container").css({"display":"none"});
	}
}

$(document).on('click', '.phone-currentcall-container', function(e){
	e.preventDefault();

	if (CallData.CallType == "incoming") {
		$(".phone-call-incoming").css({"display":"block"});
		$(".phone-call-outgoing").css({"display":"none"});
		$(".phone-call-ongoing").css({"display":"none"});
	} else if (CallData.CallType == "outgoing") {
		$(".phone-call-incoming").css({"display":"none"});
		$(".phone-call-outgoing").css({"display":"block"});
		$(".phone-call-ongoing").css({"display":"none"});
	} else if (CallData.CallType == "ongoing") {
		$(".phone-call-incoming").css({"display":"none"});
		$(".phone-call-outgoing").css({"display":"none"});
		$(".phone-call-ongoing").css({"display":"block"});
	}
	$(".phone-call-ongoing-caller").html(CallData.name);

	QB.Phone.Functions.HeaderTextColor("white", 500);
	QB.Phone.Animations.TopSlideDown('.phone-application-container', 500, 0);
	QB.Phone.Animations.TopSlideDown('.phone-call-app', 500, 0);
	QB.Phone.Functions.ToggleApp("phone-call", "block");

	QB.Phone.Data.currentApplication = "phone-call";
});

$(document).on('click', '#incoming-answer', function(e){
	e.preventDefault();

	$.post('https://vrp_phone/AnswerCall');
});

QB.Phone.Functions.AnswerCall = function(CallData) {
	$(".phone-call-incoming").css({"display":"none"});
	$(".phone-call-outgoing").css({"display":"none"});
	$(".phone-call-ongoing").css({"display":"block"});
	$(".phone-call-ongoing-caller").html(CallData.TargetData.name);

	// QB.Phone.Functions.Close();
}


$(".service-contact").click(function(e) {
	let serviceName = $(this).data("service");
	let icon = $(this).find("i").clone();

	$.post("https://vrp_phone/callService", JSON.stringify({service: serviceName}), function(hasActiveCall) {
		if(!hasActiveCall && !QB.Phone.Data.InPhoneCall) {

			$(".phone-call-outgoing").css({"display":"block"});
			$(".phone-call-incoming").css({"display":"none"});
			$(".phone-call-ongoing").css({"display":"none"});
			$(".phone-call-outgoing-caller").html(serviceName);
			$(".phone-call-outgoing-picture").html(icon);

			$(".phone-currentcall-contact").html(serviceName);
			$(".phone-call-ongoing-caller").html(serviceName);

			QB.Phone.Functions.HeaderTextColor("white", 400);
			QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
			setTimeout(function(){
				$(".phone-app").css({"display":"none"});
				QB.Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
				QB.Phone.Functions.ToggleApp("phone-call", "block");
			}, 450);

			CallData.name = serviceName;
			CallData.picture = icon;

			QB.Phone.Data.currentApplication = "phone-call";
			QB.Phone.Functions.SetupCurrentCall({CallType: "outgoing", InCall: true, TargetData: CallData});
		} else {
			QB.Phone.Notifications.Add("fas fa-exclamation-circle", "Nu poti", "Ai deja un apel activ !");
		}
	});
});