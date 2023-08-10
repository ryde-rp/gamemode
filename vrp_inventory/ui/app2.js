const Inventory = {
	MaxSlots: 20,
	MaxTrunkSlots: 30,
	ChestSlots: 42,
}

async function post(url, data) {
	const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: data
	});

	return await response.json();
}

async function RefreshUtilitati() {
    $('.quick-hotbar').find('.item-box').remove()
	let data = await post("GetItems", JSON.stringify({
		refresh: true
	}));

    for(i=1;i<6;i++){
        $('.quick-hotbar').append(`
             <div data-utilitati-slot="slot-${i}" class="item-box">
                 <div class="item-hotbar-key">${i}</div>
             </div>
        `)
    }

    $(".item-box").droppable({
		hoverClass: 'button-hover',
		drop: async function(event, ui) {
			if (!isOverflowing(event, $(this).parent().parent()) || $(this).parent().parent().attr('data-inventory') != 'player') {
				var toinventory = $(this).parent().parent().attr('data-inventory') || $(this).parent().attr('data-inventory')
				var frominventory = ui.draggable.parent().parent().attr('data-inventory')  || ui.draggable.parent().attr('data-inventory')

				if ($(this).data('name') == ui.draggable.data('name') || $(this).data('name') == undefined) {
					if (toinventory == 'quick' && frominventory == 'player') {
						let toSlot = $(this).attr('data-utilitati-slot');
						$.post('https://' + GetParentResourceName() + '/EquipItem', JSON.stringify({
							tip: toSlot,
							name: ui.draggable.data('name'),
						}))
						RefreshUtilitati()
					} else if (toinventory == 'player' && frominventory == 'quick') {
						let fromSlot = ui.draggable.attr('data-utilitati-slot');

						console.log("SECOND VERS")

                        $.post('https://' + GetParentResourceName() + '/UnequipItem', JSON.stringify({
                            tip: fromSlot,
                            name: ui.draggable.data('name'),
                        }))
                        RefreshUtilitati()
					}
				}
			}
		}
	});

	$.each(data, function(k, v) {
		if (v) {
			$('.quick-hotbar').find(`[data-utilitati-slot=${k}]`).html(`
                <img src="nui://vrp/gui/items/${v.name}.webp">
                <div class="item-amount">${v.amount}</div>
            `).attr('data-name', v.name).draggable({
                helper: 'clone',
                appendTo: ".inventory",
                revert: 'invalid',
                containment: 'document'
            })
		}
	})
}

RefreshUtilitati()

function InventoryPrompt(Title, itemNumber) {
	return new Promise((resolve, reject) => {
		$('#prompt-title').text(Title);
		$('#prompt-description').text("CANTIATE ITEM " + itemNumber + "X")
		$('.prompt-wrapper').show();

		$(document).on("click", '#prompt-button', async function(event) {
			event.preventDefault();
			let value = $('#prompt-input').val();
			$('.prompt-wrapper').hide();
			resolve(value);
		});
	})
}

var selectedItem = false;
let openItemSelector = (oneItem, itemName, itemDesc, itemWeight, itemAmount, dom) => {
	selectedItem = {
		amount: itemAmount,
		item: oneItem,
		label: itemName,
	};

	let element = $('.iteminfo-container');
	let itemOffset = $(dom).offset();
	element.css('top', itemOffset.top);

	let leftOffset = itemOffset.left + 100;
	if (leftOffset + element.width() > $(window).width()) {
		leftOffset = $(window).width() - element.width() - 20;
	}

	element.css('left', leftOffset);
	$("#iteminfo-name").text(itemName);
	$("#iteminfo-desc").text(itemDesc);
	$("#iteminfo-weight").text(itemWeight);
}

function closeChest() {
	$('.cloth-inv').show();
	$('.other-inventory').hide();
}

const isOverflowing = (event, $droppableContainer) => {
	var cTop = $droppableContainer.offset().top;
	var cLeft = $droppableContainer.offset().left;
	var cBottom = cTop + $droppableContainer.height();
	var cRight = cLeft + $droppableContainer.width();
	if (event.pageY >= cTop && event.pageY <= cBottom && event.pageX >= cLeft && event.pageX <= cRight) {
		return false;
	} else {
		return true;
	}
}

async function openInventory(items, totalWeight, maxWeight, refresh, other, PlayerInfo, isInVehicle) {
	if (!refresh) {
		$('.inventory').fadeIn();
	}

	$("#perchezitioneaza").show();

	if (isInVehicle) {
		$('#cere-torpedou').show();
		$('#cere-portbagaj').hide();
	} else {
		$('#cere-torpedou').hide();
		$('#cere-portbagaj').show();
	}

	$('.player-inventory').find('.item-box').remove()
	$('.other-inventory').find('.item-box').remove()
	$("#player-kg").text(totalWeight + " / " + maxWeight + " KG");

	var chestProgressbar = (totalWeight / maxWeight) * 100
	if (chestProgressbar > 100) {
		chestProgressbar = 100;
	}

	$(".progress").css("width", chestProgressbar + "%");

	for (i = 1; i < Inventory.MaxSlots + 13; i++) { // Main Inventory
		$('.player-inventory .player-items').append(`<div data-slot="${i}" class="item-box"></div>`)
	}

	for (i = 1; i < (other != undefined && other.isVehicle != true && Inventory.ChestSlots) + 1; i++) { // Other Inventory
		$('.other-inventory .other-items').append(`<div data-other-slot="${i}" class="item-box"></div>`)
	}

	for (i = 1; i < (other != undefined && other.isVehicle && Inventory.MaxTrunkSlots) + 1; i++) { // Other Inventory
		$('.other-inventory .other-items').append(`<div data-other-slot="${i}" class="item-box"></div>`)
	}

	if (other) {
		$('.cloth-inv').hide();
		$('.other-inventory').show().attr('data-inventory', other.id)


		if (other.isVehicle) {
			$('#car-inventory').show();
			$('.other-inventory-head').show();
			$('.other-inventory-head').text(other.name)
			$(".other-inv-kg").attr("data-kg", (other.totalChestWeight + " / " + other.maxChestWeight + " KG"));
			$('#chest-inventory').hide();
		} else {
			$('#car-inventory').hide();
			$('.other-inventory').css('top', '20.2vh');
			$('#chest-inventory').show();

			$('.other-inventory-head').hide();
			$("#chest-kg").text(other.totalChestWeight + " / " + other.maxChestWeight + " KG")
			$('#chest-name').text(other.name);
			var chestProgressbar = (other.totalChestWeight / other.maxChestWeight) * 100
			if (chestProgressbar > 100) {
				chestProgressbar = 100;
			}
			$(".chest-progress").css("width", chestProgressbar + "%");
		}

		$.each(other.inventory, function(k, v) {
			if (v != null) {
				$('.inventory').find(`[data-other-slot="${v.slot}"]`).html(`
                    <img src="nui://vrp/gui/items/${v.name}.webp">
                    <div class="item-amount">${v.amount}</div>
                `).attr('data-name', v.name).attr('data-label', v.label).attr('data-description', v.description).attr('data-amount', v.amount).attr('data-weight', v.weight).attr('data-chest', true)
			}
		})
	} else {
		$('.cloth-inv').show();
		$('.other-inventory').hide();
	}

	$.each(items, function(k, v) {
		if (v != null) {
			$('.inventory').find(`[data-slot="${v.slot}"]`).html(`
                <img src="nui://vrp/gui/items/${v.name}.webp">
                <div class="item-amount">${v.amount}</div>
            `).attr('data-name', v.name).attr('data-label', v.label).attr('data-description', v.description).attr('data-amount', v.amount).attr('data-weight', v.weight)
		}
	})

	$('.item-box').each(function() {
		if ($(this).data('name')) {
			if ($(this).parent().hasClass('other-items')) {
				$(this).draggable({
					helper: 'clone',
					appendTo: ".inventory",
					revert: 'invalid',
					containment: 'document',
				})
			} else {
				$(this).draggable({
					helper: 'clone',
					appendTo: ".inventory",
					revert: 'invalid',
					containment: 'document'
				})
			}
		}
	})

	$(".item-box").droppable({
		hoverClass: 'button-hover',
		drop: async function(event, ui) {
			if (!isOverflowing(event, $(this).parent().parent()) || $(this).parent().parent().attr('data-inventory') != 'player') {
				var toinventory = $(this).parent().parent().attr('data-inventory') || $(this).parent().attr('data-inventory')
				var frominventory = ui.draggable.parent().parent().attr('data-inventory')  || ui.draggable.parent().attr('data-inventory')
				let ownedAmm = parseInt(ui.draggable.children(".item-amount").text());

                if (frominventory == undefined) {
                    frominventory = "other";
                } else if (toinventory == undefined) {
                    toinventory = "other";
                }

				if ($(this).data('name') == ui.draggable.data('name') || $(this).data('name') == undefined) {
					if (frominventory == 'player' && toinventory == 'other') {
						var amount = 1;
						if (ownedAmm > 1) {
							let obj = await InventoryPrompt("SELECTEAZĂ CANTITATEA", ownedAmm);
							amount = parseInt(obj);
						}
						$.post('https://' + GetParentResourceName() + '/SetInventoryData', JSON.stringify({
							frominventory: "player",
							toinventory: "other",
							isPlayer: PlayerInfo,
							item: ui.draggable.data('name'),
							amount: amount || 1
						}))
					} else if (frominventory == 'other' && toinventory == 'player') {
						var amount = 1;
						if (ownedAmm > 1) {
							let obj = await InventoryPrompt("SELECTEAZĂ CANTITATEA", ownedAmm);
							amount = parseInt(obj);
						}
						$.post('https://' + GetParentResourceName() + '/SetInventoryData', JSON.stringify({
							frominventory: "other",
							toinventory: toinventory,
							isPlayer: PlayerInfo,
							item: ui.draggable.data('name'),
							amount: amount || 1
						}))
					} else if (toinventory == 'quick' && frominventory == 'player') {
						let toSlot = $(this).attr('data-utilitati-slot');
						$.post('https://' + GetParentResourceName() + '/EquipItem', JSON.stringify({
							tip: toSlot,
							name: ui.draggable.data('name'),
						}))
						RefreshUtilitati()
					} else if (toinventory == 'player' && frominventory == 'quick') {
						let fromSlot = ui.draggable.attr('data-utilitati-slot');

						console.log("SECOND VERS")

                        $.post('https://' + GetParentResourceName() + '/UnequipItem', JSON.stringify({
                            tip: fromSlot,
                            name: ui.draggable.data('name'),
                        }))
                        RefreshUtilitati()
					}
				}
			}
		}
	});

	$('.cloth-items .item-box').off().click(function() {
		$.post('https://' + GetParentResourceName() + '/ChangeVariation', JSON.stringify({
			component: $(this).attr('id')
		}))
	})
	$(".item-amount").each(() => {
		var t = $(this).html().length;
		4 == t ? $(this).css({
			top: "2vh"
		}) : 3 == t ? $(this).css({
			top: "2.2vh"
		}) : 2 == t ? $(this).css({
			top: "2.5vh"
		}) : 1 == t && $(this).css({
			top: "2.7vh"
		})
	});
}

const closeInventory = () => {
	$.post('https://' + GetParentResourceName() + '/CloseInventory')

	if (selectedItem) {
		selectedItem = false;
		$(".iteminfo-container").hide();
	}

	$('.prompt-wrapper').hide();
	$('.inventory').fadeOut();
}

// Utils

window.addEventListener('message', function(event) {
	switch (event.data.action) {
		case 'openInventory':
			openInventory(event.data.inventory, event.data.totalWeight, event.data.maxWeight, false, event.data.other, event.data.playerData, event.data.isInVehicle)
		break;

		case 'refreshUtilitati':
			RefreshUtilitati();
		break

		case 'close':
			closeInventory();
		break;

		case 'refresh':
			openInventory(event.data.inventory, event.data.totalWeight, event.data.maxWeight, true, event.data.other, event.data.playerData)
		break;
	}
})

$(document).on('keydown', function(event) {
	switch (event.keyCode) {
		case 27: // ESC
			closeInventory()
			break;
	}
}).on("mousedown", ".item-box", function(e) {
	e.preventDefault();
	if (e.which == 3) {
		if ($(this).data("label") != null && !$(this).data("chest")) {
			$(".iteminfo-container").show()
			openItemSelector($(this).data("name"), $(this).data("label"), $(this).data("description"), $(this).data("weight"), $(this).data("amount"), $(this));
		} else {
			selectedItem = false;
			$(".iteminfo-container").hide();
		}
	} else if (e.which == 1) {
		if (selectedItem)
			selectedItem = false;
		$(".iteminfo-container").hide();
	}
}).on("click", "#item-use", (e) => {
	e.preventDefault();
	if (selectedItem)
		$.post('https://' + GetParentResourceName() + '/UseItem', JSON.stringify({
			item: selectedItem.item
		}));
	selectedItem = false;
	$(".iteminfo-container").hide();
	closeInventory()
}).on("click", "#item-drop", async function(event) {
	event.preventDefault();
	if (selectedItem)
		var amt = 1;
	if (selectedItem.amount > 1) {
		$(".iteminfo-container").hide();
		let obj = await InventoryPrompt("CÂT ARUNCI?", selectedItem.amount);
		amt = parseInt(obj) || 0
	} else {
		$(".iteminfo-container").hide();
	}
	$.post('https://' + GetParentResourceName() + '/DropItem', JSON.stringify({
		item: selectedItem.item,
		amount: amt,
		label: selectedItem.label
	}));
	closeInventory()
	selectedItem = false;
}).on("click", "#item-give", async function(event) {
	event.preventDefault();
	if (selectedItem)
		var amt = 1;
	if (selectedItem.amount > 1) {
		$(".iteminfo-container").hide();
		let obj = await InventoryPrompt("CÂT OFERI?", selectedItem.amount);
		amt = parseInt(obj) || 0;
	} else {
		$(".iteminfo-container").hide();
	}
	$.post('https://' + GetParentResourceName() + '/GiveItem', JSON.stringify({
		item: selectedItem.item,
		amount: amt
	}));
	closeInventory()
	selectedItem = false;
}).on("click", '#ofera-bani', async function(event) {
	event.preventDefault();
	closeInventory()
	$.post('https://' + GetParentResourceName() + '/GiveMoney', JSON.stringify({}));
}).on("click", '#strange-armele', async function(event) {
	event.preventDefault();
	$.post('https://' + GetParentResourceName() + '/StrangeArmele', JSON.stringify({}));
}).on("click", '#cere-portbagaj', async function(event) {
	event.preventDefault();
	$.post('https://' + GetParentResourceName() + '/CerePortbagaj', JSON.stringify({}));
}).on("click", '#cere-torpedou', async function(event) {
	event.preventDefault();
	$.post('https://' + GetParentResourceName() + '/CereTorpedou', JSON.stringify({}));
}).on("click", '#perchezitioneaza', async function(event) {
	event.preventDefault();
	$.post('https://' + GetParentResourceName() + '/Perchezitioneaza', JSON.stringify({}));
}).on("click", '#closeChest', async function(event) {
	event.preventDefault();
	closeChest();
});