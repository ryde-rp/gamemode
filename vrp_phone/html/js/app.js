async function post(url, data = {}, resource = GetParentResourceName()){
  const response = await fetch(`https://${resource}/${url}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data)
  });
  
  return await response.json();
}

QB = {}
QB.Phone = {}
QB.Screen = {}
QB.Phone.Functions = {}
QB.Phone.Animations = {}
QB.Phone.Notifications = {}
QB.Phone.ContactColors = {
	0: "#9b59b6",
	1: "#3498db",
	2: "#e67e22",
	3: "#e74c3c",
	4: "#1abc9c",
	5: "#9c88ff",
}

QB.Phone.Data = {
	currentApplication: null,
	PlayerData: {},
	Applications: {},
	IsOpen: false,
	CallActive: false,
	MetaData: {},
	AnonymousCall: false,
}

QB.Phone.Data.MaxSlots = 16;

var CanOpenApp = true;
var up = false


QB.Phone.Functions.SetupApplications = function(data) {
	QB.Phone.Data.Applications = data.applications;

	var i;
	for (i = 1; i <= QB.Phone.Data.MaxSlots; i++) {
		var applicationSlot = $(".phone-applications").find('[data-appslot="'+i+'"]');
		$(applicationSlot).html("");
		$(applicationSlot).css({
			"background-color":"transparent"
		});
		$(applicationSlot).prop('title', "");
		$(applicationSlot).removeData('app');
		$(applicationSlot).removeData('placement')
	}

	$.each(data.applications, function(i, app){
		var applicationSlot = $(".phone-applications").find('[data-appslot="'+app.slot+'"]');

		$(applicationSlot).css({"background-color":app.color});
		var icon = '<i class="ApplicationIcon '+app.icon+'" style="'+app.style+'"></i>';
       	if (app.app == "jobs"){
            icon = '<img src="./img/apps/jobcenter.png" style="width: 87%;margin-top: 6%;margin-left: -2%;">';
        } else if (app.app == "mail") {
        	icon = "<img src='https://static.dezeen.com/uploads/2020/10/gmail-google-logo-rebrand-workspace-design_dezeen_2364_sq.jpg' style='border-radius: .55vw; width: 100%;margin-top: 1%;margin-left: -2%;'>";
        } else if (app.app == "taxi") {
			icon = "<img src='https://cdn.fairplay-rp.ro/recovery/taxiapp.png' style='width: 90%;margin-top: 2%;'>";
		}

		$(applicationSlot).html(icon+'<div class="app-unread-alerts">0</div>');
		$(applicationSlot).prop('title', app.tooltipText);
		$(applicationSlot).data('app', app.app);

		if (app.tooltipPos !== undefined) {
			$(applicationSlot).data('placement', app.tooltipPos)
		}
	});

	$('[data-toggle="tooltip"]').tooltip();
}

QB.Phone.Functions.SetupAppWarnings = function(AppData) {
	$.each(AppData, function(i, app){
		var AppObject = $(".phone-applications").find("[data-appslot='"+app.slot+"']").find('.app-unread-alerts');

		if (app.Alerts > 0) {
			$(AppObject).html(app.Alerts);
			$(AppObject).css({"display":"block"});
		} else {
			$(AppObject).css({"display":"none"});
		}
	});
}

QB.Phone.Functions.IsAppHeaderAllowed = function(app) {
	var retval = true;
	$.each(Config.HeaderDisabledApps, function(i, blocked){
		if (app == blocked) {
			retval = false;
		}
	});
	return retval;
}

$(document).on('click', '.phone-application', function(e){
	e.preventDefault();
	var PressedApplication = $(this).data('app');
	var AppObject = $("."+PressedApplication+"-app");

	if (AppObject.length !== 0) {
		if (CanOpenApp) {
			if (QB.Phone.Data.currentApplication == null) {
				QB.Phone.Animations.TopSlideDown('.phone-application-container', 300, 0);
				QB.Phone.Functions.ToggleApp(PressedApplication, "block");

				if (QB.Phone.Functions.IsAppHeaderAllowed(PressedApplication)) {
					QB.Phone.Functions.HeaderTextColor("black", 300);
				}

				QB.Phone.Data.currentApplication = PressedApplication;

				if (PressedApplication == "settings") {
					$("#myPhoneNumber").text(QB.Phone.Data.PlayerData.phone);
					$("#mySerialNumber").text("RydeOS AXK2023X0A2");

				} else if (PressedApplication == "whatsapp") {
					$.post("https://vrp_phone/pwGetFrontMessages", "{}", (frontMessages) => {
						QB.Phone.Functions.pwLoadFrontMessages(frontMessages);
					});

				} else if (PressedApplication == "phone") {
					$.post('https://vrp_phone/GetMissedCalls', JSON.stringify({}), function(recent){
						QB.Phone.Functions.SetupRecentCalls(recent);
					});
					$.post('https://vrp_phone/ClearGeneralAlerts', JSON.stringify({
						app: "phone"
					}));

				} else if(PressedApplication == "bank") {
					QB.Phone.Functions.setupBankApp();

				} else if(PressedApplication == "mail") {
                    QB.Phone.Functions.HeaderTextColor("white", 300);
                    $.post('https://vrp_phone/GetMails', JSON.stringify({}), function(mails){
                        setupMailsApp(mails);
                    });
                    $.post('https://vrp_phone/ClearGeneralAlerts', JSON.stringify({
                        app: "mail"
                    }));
                    
				} else if(PressedApplication == "twitter") {
			        $.post('https://vrp_phone/GetTweets', JSON.stringify({}), function (Tweets) {
			            setupTweets(Tweets);
			        });
			        $.post('https://vrp_phone/GetSelfTweets', JSON.stringify({}), function (selfTweets) {
			            setupUserTweets(selfTweets)
			        })

				} else if (PressedApplication == "store") {
					$.post('https://vrp_phone/SetupStoreApps', JSON.stringify({}), function(data){
						SetupAppstore(data);
					});
				} else if (PressedApplication == "gallery") {
					$.post('https://vrp_phone/GetGalleryData', JSON.stringify({}), function(data){
						setUpGalleryData(data);
					});
				} else if (PressedApplication == "camera") {
					$.post('https://vrp_phone/TakePhoto', JSON.stringify({}),function(url){
						setUpCameraApp(url)
					});
					QB.Phone.Functions.Close();
				} else if (PressedApplication == "jobs") {
					setupJobs();
				}
				
			}
		}
	} else {
		if (PressedApplication != null){
			
			if (PressedApplication == "invest"){
				$.post("https://vrp/openInvestMenu", JSON.stringify({}));
				return;
			} else if (PressedApplication == "premiumshop"){
				return post("openPremiumShop");
			}


			QB.Phone.Notifications.Add("fas fa-exclamation-circle", "System", "Aplicatia nu poate fi deschisa!")
		}
	}
});

$(document).on('click', '.phone-home-container', function(event){
	event.preventDefault();

	if (QB.Phone.Data.currentApplication === null) {
		QB.Phone.Functions.Close();
	} else {
		QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
		QB.Phone.Animations.TopSlideUp('.'+QB.Phone.Data.currentApplication+"-app", 400, -160);
		CanOpenApp = false;
		setTimeout(function() {
			QB.Phone.Functions.ToggleApp(QB.Phone.Data.currentApplication, "none");
			CanOpenApp = true;
		}, 400)
		QB.Phone.Functions.HeaderTextColor("white", 300);

		if (QB.Phone.Data.currentApplication == "whatsapp") {
			setTimeout(function() {
				$("#whatsapp-openedchat-back").trigger("click");
			}, 450);
		} else if(QB.Phone.Data.currentApplication == "gallery") {
			QB.Phone.Functions.cancelSendingPhoto();
		}

		QB.Phone.Data.currentApplication = null;
	}
});

QB.Phone.Functions.Open = function() {
	if(!QB.Phone.Data.IsOpen) {
		QB.Phone.Animations.BottomSlideUp('.container', 300, 0);
		QB.Phone.Data.IsOpen = true;

		var oneDate = new Date();
	    var hours = oneDate.getHours();
	    var minutes = oneDate.getMinutes();

	    if (hours < 10)
	        hours = "0" + hours;

	    if (minutes < 10) {
	        minutes = "0" + minutes;
	    }

	    oneDate = {hour: hours, minute: minutes}
	    QB.Phone.Functions.UpdateTime(oneDate);
	}
}

QB.Phone.Functions.ToggleApp = function(app, show) {
	$("."+app+"-app").css({"display":show});
}

QB.Phone.Functions.Close = function() {
	if(QB.Phone.Data.IsOpen) {

		$('[data-toggle="tooltip"]').tooltip("hide");

		if(QB.Phone.Data.InPhoneCall) {
			if(QB.Phone.Data.currentApplication !== null) {
				QB.Phone.Animations.TopSlideUp('.phone-application-container', 0, -160);
				QB.Phone.Animations.TopSlideUp('.'+QB.Phone.Data.currentApplication+"-app", 200, -160);
				CanOpenApp = false;
				QB.Phone.Functions.ToggleApp(QB.Phone.Data.currentApplication, "none");
				CanOpenApp = true;
				QB.Phone.Functions.HeaderTextColor("white", 300);
			}

			QB.Phone.Animations.BottomSlideUp('.container', 300, -55);
		} else {
			QB.Phone.Animations.BottomSlideDown('.container', 300, -70);
		}

		$.post('https://vrp_phone/Close');
		QB.Phone.Data.IsOpen = false;
	}
}

QB.Phone.Functions.HeaderTextColor = function(newColor, Timeout) {
	$(".phone-header").animate({color: newColor}, Timeout);
}

QB.Phone.Animations.BottomSlideUp = function(Object, Timeout, Percentage) {
	$(Object).css({'display':'block'}).animate({
		bottom: Percentage+"%",
	}, Timeout);
}

QB.Phone.Animations.BottomSlideDown = function(Object, Timeout, Percentage) {
	$(Object).css({'display':'block'}).animate({
		bottom: Percentage+"%",
	}, Timeout, function(){
		$(Object).css({'display':'none'});
	});
}

QB.Phone.Animations.TopSlideDown = function(Object, Timeout, Percentage) {
	$(Object).css({'display':'block'}).animate({
		top: Percentage+"%",
	}, Timeout);
}

QB.Phone.Animations.TopSlideUp = function(Object, Timeout, Percentage, cb) {
	$(Object).css({'display':'block'}).animate({
		top: Percentage+"%",
	}, Timeout, function(){
		$(Object).css({'display':'none'});
	});
}

QB.Phone.Notifications.Add = function(icon, title, text, color, timeout) {
	$.post('https://vrp_phone/HasPhone', JSON.stringify({}), function(HasPhone){
		if (HasPhone) {
			if (timeout == null && timeout == undefined) {
				timeout = 1500;
			}
			if (QB.Phone.Notifications.Timeout == undefined || QB.Phone.Notifications.Timeout == null) {
				if (color != null || color != undefined) {
					$(".notification-icon").css({"color":color});
					// $(".notification-title").css({"color":color});
				} else if (color == "default" || color == null || color == undefined) {
					$(".notification-icon").css({"color":"#e74c3c"});
					$(".notification-title").css({"color":"#e74c3c"});
				}
				if (!QB.Phone.Data.IsOpen) {
					QB.Phone.Animations.BottomSlideUp('.container', 300, -52);
				}
				QB.Phone.Animations.TopSlideDown(".phone-notification-container", 200, 8);
				if (icon !== "politie") {
					$(".notification-icon").html('<i class="'+icon+'"></i>');
				} else {
					$(".notification-icon").html('<img src="./img/politie.png" class="police-icon-notify">');
				}
				$(".notification-title").html(title);
				$(".notification-text").html(text);
				if (QB.Phone.Notifications.Timeout !== undefined || QB.Phone.Notifications.Timeout !== null) {
					clearTimeout(QB.Phone.Notifications.Timeout);
				}
				QB.Phone.Notifications.Timeout = setTimeout(function() {
					QB.Phone.Animations.TopSlideUp(".phone-notification-container", 200, -8);
					if (!QB.Phone.Data.IsOpen) {
						QB.Phone.Animations.BottomSlideUp('.container', 300, -100);
					}
					QB.Phone.Notifications.Timeout = null;
				}, timeout);
			} else {
				if (color != null || color != undefined) {
					$(".notification-icon").css({"color":color});
					// $(".notification-title").css({"color":color});
				} else {
					$(".notification-icon").css({"color":"#e74c3c"});
					$(".notification-title").css({"color":"#e74c3c"});
				}
				if (!QB.Phone.Data.IsOpen) {
					QB.Phone.Animations.BottomSlideUp('.container', 300, -52);
				}
				$(".notification-icon").html('<i class="'+icon+'"></i>');
				$(".notification-title").html(title);
				$(".notification-text").html(text);
				if (QB.Phone.Notifications.Timeout !== undefined || QB.Phone.Notifications.Timeout !== null) {
					clearTimeout(QB.Phone.Notifications.Timeout);
				}
				QB.Phone.Notifications.Timeout = setTimeout(function() {
					QB.Phone.Animations.TopSlideUp(".phone-notification-container", 200, -8);
					if (!QB.Phone.Data.IsOpen) {
						QB.Phone.Animations.BottomSlideUp('.container', 300, -100);
					}
					QB.Phone.Notifications.Timeout = null;
				}, timeout);
			}
		}
	});
}

QB.Phone.Functions.RoAlertNotification = function(msg) {
	$.post('https://vrp_phone/HasPhone', JSON.stringify({}), function(HasPhone) {
		if (HasPhone) {
			if(msg) {
				$(".phone-roalert-container > .roalert-text > hr").remove();
				$(".phone-roalert-container > .roalert-text").text(msg).prepend("<hr/>");
			}

			$(".notification-icon").html("<i class='fas fa-triangle-exclamation'></i></div>");
			$(".notification-title").html("<p>RO Alert</p></div>");
			$(".notification-text").html("<p>Click pentru a vedea</p></div>");

			$(".notification-icon").css({"color": "#FB3640"});
			if (!QB.Phone.Data.IsOpen) {
				QB.Phone.Animations.BottomSlideUp('.container', 300, -52);
			}
			QB.Phone.Animations.TopSlideDown(".phone-roalert-container", 200, 8);
			$(".phone-roalert-container").addClass("pulse-animation");
			if (QB.Phone.Notifications.Timeout !== undefined || QB.Phone.Notifications.Timeout !== null) {
				clearTimeout(QB.Phone.Notifications.Timeout);
			}
			QB.Phone.Notifications.Timeout = setTimeout(function() {
				QB.Phone.Animations.TopSlideUp(".phone-roalert-container", 200, -8);
				$(".phone-roalert-container").removeClass("pulse-animation");
				if (!QB.Phone.Data.IsOpen) {
					QB.Phone.Animations.BottomSlideUp('.container', 300, -100);
				}
				QB.Phone.Notifications.Timeout = null;
			}, 10000);
		}
	});
}

let roAlertAnim = false;

function openRoalert(obj) {
	if(roAlertAnim) return;
	roAlertAnim = true;
	if (!obj.classList.contains("roalert-clicked")) {
		obj.classList.remove("pulse-animation");
		clearTimeout(QB.Phone.Notifications.Timeout);
		QB.Phone.Notifications.Timeout = null;

		$(".phone-roalert-container > .notification-text").fadeOut(400, () => {
			$(".phone-roalert-container > .notification-title").animate({"top": "2vh", "left": "9vh"}, 300, () => {
				obj.classList.add("roalert-clicked");
				setTimeout(() => {
					$(".phone-roalert-container > .roalert-text").fadeIn();
					roAlertAnim = false;
				}, 1000);
			});
		});

	} else {
		$(".phone-roalert-container > .roalert-text").fadeOut();
		obj.classList.remove("roalert-clicked");
		setTimeout(() => {
			QB.Phone.Animations.TopSlideUp(".phone-roalert-container", 200, -8);
			setTimeout(() => {
				$(".phone-roalert-container > .notification-text").show();
				$(".phone-roalert-container > .notification-title").css({"top": "1vh", "left": "4.5vh"});

				roAlertAnim = false;
			}, 2000);
		}, 1000);
		
	}
}

QB.Phone.Functions.LoadPhoneData = function(data) {
	QB.Phone.Data.PlayerData = data.PlayerData;
	QB.Phone.Data.MetaData = data.PhoneData.MetaData;
	QB.Phone.Functions.LoadMetaData(data.PhoneData.MetaData);
	QB.Phone.Functions.LoadContacts(data.PhoneData.Contacts);
	QB.Phone.Functions.SetupApplications(data);
}

QB.Phone.Functions.UpdateTime = function(data) {
	$("#phone-time").html("<span>" + data.hour + ":" + data.minute + "</span>");
}

QB.Phone.Functions.formatTime = (date, inverse = false) => {

	let seconds = 0;

	if(inverse) {
		seconds = Math.floor(date - (new Date() / 1000));
	} else {
		seconds = Math.floor((new Date() / 1000) - date)
	}

	let interval = seconds / 2592000;
	if (interval > 1) {
		let d = new Date(date*1000);

		let day = d.getDate();
		if(day < 10) day = "0" + day;

		let month = d.getMonth() + 1;
		if(month < 10) month = "0" + month;

		return day + "." + month + "." + d.getFullYear();
	}
	interval = seconds / 86400;
	if (interval > 1) {
		return Math.floor(interval) + " zile";
	}
	interval = seconds / 3600;
	if (interval > 1) {
		return Math.floor(interval) + " ore";
	}
	interval = seconds / 60;
	if (interval > 1) {
		return Math.floor(interval) + " minute";
	}
	return "Acum";
}

var NotificationTimeout = null;

QB.Screen.Notification = function(title, content, icon, timeout, color) {
	$.post('https://vrp_phone/HasPhone', JSON.stringify({}), function(HasPhone){
		if (HasPhone) {
			if (color != null && color != undefined) {
				$(".screen-notifications-container").css({"background-color":color});
			}
			$(".screen-notification-icon").html('<i class="'+icon+'"></i>');
			$(".screen-notification-title").text(title);
			$(".screen-notification-content").text(content);
			$(".screen-notifications-container").css({'display':'block'}).animate({
				right: 5+"vh",
			}, 200);

			if (NotificationTimeout != null) {
				clearTimeout(NotificationTimeout);
			}

			NotificationTimeout = setTimeout(function(){
				$(".screen-notifications-container").animate({
					right: -35+"vh",
				}, 200, function(){
					$(".screen-notifications-container").css({'display':'none'});
				});
				NotificationTimeout = null;
			}, timeout);
		}
	});
}

$(document).on('keydown', function(event) {
	if(QB.Phone.Data.IsOpen) {
		if(event.keyCode == 27) {
			if (up){
				$('#popup').fadeOut('slow');
				$('.popupclass').fadeOut('slow');
				$('.popupclass').html("");
				up = false;
			} else {
				QB.Phone.Functions.Close();
			}
		}
	}
	
}).on("mousedown", function(event) {
	if(QB.Phone.Data.IsOpen) {
		if(event.which == 3) {
			$.post("https://vrp_phone/toggleFocus");
		}
	}
});

QB.Screen.popUp = function(source){
	if(!up){
		$('#popup').fadeIn('slow');
		$('.popupclass').fadeIn('slow');
		$('<img  src='+source+' style = "width:100%; height: 100%;">').appendTo('.popupclass')
		up = true
	}
}

QB.Screen.popDown = function(){
	if(up){
		$('#popup').fadeOut('slow');
		$('.popupclass').fadeOut('slow');
		$('.popupclass').html("");
		up = false
	}
}

$(document).ready(function(){
	window.addEventListener('message', function(event) {
		switch(event.data.action) {
			case "open":
				QB.Phone.Functions.Open();
				QB.Phone.Functions.SetupAppWarnings(event.data.AppData);
				QB.Phone.Functions.SetupCurrentCall(event.data.CallData);
				QB.Phone.Data.PlayerData = event.data.PlayerData;
				break;
			case "LoadPhoneData":
				QB.Phone.Functions.LoadPhoneData(event.data);
				break;
			case "UpdateTime":
				QB.Phone.Functions.UpdateTime(event.data);
				break;
			case "Notification":
				QB.Screen.Notification(event.data.NotifyData.title, event.data.NotifyData.content, event.data.NotifyData.icon, event.data.NotifyData.timeout, event.data.NotifyData.color);
				break;
			case "PhoneNotification":
				QB.Phone.Notifications.Add(event.data.PhoneNotify.icon || "fa-solid fa-bell", event.data.PhoneNotify.title, event.data.PhoneNotify.text, event.data.PhoneNotify.color, event.data.PhoneNotify.timeout);
				break;
			case "RefreshAppAlerts":
				QB.Phone.Functions.SetupAppWarnings(event.data.AppData);
				break;
			case "UpdateTweets":
				setupTweets(event.data.Tweets);
				setupUserTweets(event.data.SelfTweets);
				break;
            case "UpdateMails":
                setupMailsApp(event.data.Mails);
                break;
			case "UpdateBank":
				$(".bank-app-account-balance").html("&#36; "+event.data.NewBalance);
				$(".bank-app-account-balance").data('balance', event.data.NewBalance);
				break;
			case "AddMessage":
				if (QB.Phone.Data.currentApplication == "whatsapp") {
					QB.Phone.Functions.pwAddChatMessage(event.data.number, event.data.msg);
				} else if(QB.Phone.Data.PlayerData.phone !== event.data.number) {
					$.post("https://vrp_phone/getContactName", JSON.stringify({
						number: event.data.number
					}), (contactName) => {
						switch(event.data.msg[3]) {
							case 0:
								QB.Phone.Notifications.Add("fab fa-whatsapp", contactName, event.data.msg[0], "#25D366", 3000);
								break;
							case 1:
								QB.Phone.Notifications.Add("fab fa-whatsapp", contactName, "<i class='fas fa-map-marker'></i> Locatie", "#25D366", 3000);
								break;
							case 2:
								QB.Phone.Notifications.Add("fab fa-whatsapp", contactName, "<i class='fas fa-images'></i> Fotografie", "#25D366", 3000);
								break;
						}
					});
				}
				break;
			case "UpdatePlayerStatus":
				QB.Phone.Functions.setContactStatus(event.data.number, event.data.isOnline);
				break;
			case "RefreshWhatsappAlerts":
				QB.Phone.Functions.ReloadWhatsappAlerts(event.data.Chats);
				break;
			case "CancelOutgoingCall":
				$.post('https://vrp_phone/HasPhone', JSON.stringify({}), function(HasPhone){
					if (HasPhone) {
						CancelOutgoingCall();
					}
				});
				break;
			case "AutoAnswerPhoneCall":
				setTimeout(function() {
					$.post('https://vrp_phone/AnswerCall');
				}, 1000);
				break;
			case "IncomingCallAlert":
				$.post('https://vrp_phone/HasPhone', JSON.stringify({}), function(HasPhone){
					if (HasPhone) {
						IncomingCallAlert(event.data.CallData, event.data.Canceled, event.data.AnonymousCall);
					}
				});
				break;
			case "SetupHomeCall":
				QB.Phone.Functions.SetupCurrentCall(event.data.CallData);
				break;
			case "AnswerCall":
				QB.Phone.Functions.AnswerCall(event.data.CallData);
				break;
			case "UpdateCallTime":
				var CallTime = event.data.Time;
				var date = new Date(null);
				date.setSeconds(CallTime);
				var timeString = date.toISOString().substr(11, 8);
				// if (!QB.Phone.Data.IsOpen) {
				// 	if ($(".call-notifications").css("right") !== "52.1px") {
				// 		$(".call-notifications").css({"display":"block"});
				// 		$(".call-notifications").animate({right: 5+"vh"});
				// 	}
				// 	$(".call-notifications-title").html("In apel ("+timeString+")");
				// 	$(".call-notifications-content").html(event.data.Name);
				// 	$(".call-notifications").removeClass('call-notifications-shake');
				// } else {
				// 	$(".call-notifications").animate({
				// 		right: -35+"vh"
				// 	}, 400, function(){
				// 		$(".call-notifications").css({"display":"none"});
				// 	});
				// }
				$(".phone-call-ongoing-time").html(timeString);
				$(".phone-currentcall-title").html("Apel ("+timeString+")");
				break;
			case "CancelOngoingCall":
				// $(".call-notifications").animate({right: -35+"vh"}, function(){
				// 	$(".call-notifications").css({"display":"none"});
				// });
				QB.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
				setTimeout(function(){
					QB.Phone.Functions.ToggleApp("phone-call", "none");
					$(".phone-application-container").css({"display":"none"});
				}, 400)
				QB.Phone.Functions.HeaderTextColor("white", 300);

				QB.Phone.Data.CallActive = false;
				QB.Phone.Data.currentApplication = null;

				if(!QB.Phone.Data.IsOpen) {
					QB.Phone.Animations.BottomSlideDown('.container', 300, -70);
				}
				break;
			case "UpdateApplications":
				QB.Phone.Functions.SetupApplications(event.data);
				break;
			case "RefreshAlerts":
				QB.Phone.Functions.SetupAppWarnings(event.data.AppData);
				break;
			case "RoAlert":
				QB.Phone.Functions.RoAlertNotification(event.data.msg);
				break;
		}
	})
});