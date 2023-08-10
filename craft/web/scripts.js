function addStr(str, index, stringToAdd) {
    return str.substring(0, index) + stringToAdd + str.substring(index, str.length);
}

var isTimerOn = false;
var lastTime;
var tableID;

window.addEventListener('message', function(event) {
    item = event.data;
    switch (event.data.action) {
        case 'openCraft':
            var craft = event.data.craft;
            
            tableID = event.data.wb
            var num = craft.length;
            var row = '<div class="row">';
            var added = 0

            for (let itemId of Object.keys(craft)) {
                added++
                row += `
			         	<div class="col-md-3">
			         		<div class="card item-card" id="${itemId}wb_${event.data.wb}">
			         			<div class="card-body item-card-body d-flex justify-content-center align-items-center" style="background: linear-gradient(90deg, #ffffff30, #d4d4d47a,  #ffffff20); border: 2px solid #ffffff40;" id="selected${itemId}wb_${event.data.wb}">
			         				<span class="item-title text-center">${craft[itemId].itemName}</span>
			         				<img src="https://cdn.fairplay-rp.ro/items/${itemId}.webp" class="image">
			         			</div>
			         		</div>
			         	</div>
			         `;
                var myEle = document.getElementById(itemId + "wb_" + event.data.wb);
                if (!myEle) {
                    $(document).on('click', "#" + itemId + "wb_" + event.data.wb, function() {
                        allID = this.id;
                        id = allID.substring(0, allID.indexOf('wb_'));
                        $('.item-card-body').css('background', 'linear-gradient(90deg, #ffffff30, #d4d4d47a,  #ffffff20)');
                        $('#selected' + this.id).css('background', '#407ddb90');
                        var sound = new Audio('click.mp3');
                        sound.volume = 0.3;
                        sound.play();
                        $.post('https://fairplay-craft/sideCraft', JSON.stringify({
                            item: id,
                            crafts: craft,
                            table: tableID,
                        }));

                    });
                }

                if ((added) % 4 === 0) {
                    row = addStr(row, row.length, `</div><div class="row mt-4">`);
                    lastRowNum = row.length + 6;
                }
            }
            row += `</div>`;

            $('#craft-table').html(row);
            $('.title-name').html(event.data.name);

            $('.title').fadeIn();
            $('.itemslist').fadeIn();
            $('.crafting-body').fadeIn();
            break
        case 'openSideCraft':
            var canCraft = true
            var num = event.data.recipe.length;
            var recipe = ``;

            var img = `
            
			<img src="https://cdn.fairplay-rp.ro/items/${event.data.itemId}.webp" class="image_itemselected">
			<span style="color: #fff; font-weight: 600; font-size: 20px;" class="ms-2">${event.data.itemName} x${event.data.itemAmount}</span>
		`;

            $('#side-image').html(img);
            $('#craft-time').html(event.data.time);

            for (var i = 0; i < num; i++) {
                var idName = event.data.recipe[i][1];
                var itemName = event.data.recipe[i][0]
                recipe += `
				<div class="d-flex align-items-center mx-1">
					<img src="https://cdn.fairplay-rp.ro/items/${idName}.webp" class="image_components">
					<span style="color: #fff; font-weight: 600; font-size: 20px;" class="ms-2">${itemName} x${event.data.recipe[i][2]}</span>
				</div>
			`;
            }

            if (canCraft) {
                $('#craft-button-div').html(`
				<button type="button" id="craft-button" data-item="${event.data.itemId}" data-recipe="${event.data.recipe}" data-amount="${event.data.itemAmount}" onclick="craft(this)" class="btn btn-blue flex-grow-1 mt-2" style="border-radius: 10px; flex-basis: 100%; width: 100%; font-weight: 600;"><i class="fas fa-pencil-ruler"></i> CRAFT [${event.data.itemName}]</button>
			`);
                $('#craft-button').fadeIn();
            } else {
                $('#craft-button').fadeOut();
            }
            $('.components-responsive').html(recipe);

            $('.itemrequirements').fadeIn();
            break
    }
});

function close() {
    $('.crafting-body').fadeOut();
    $('.title').fadeOut();
    $('.itemslist').fadeOut();
    $('.itemrequirements').fadeOut();
    $.post('https://fairplay-craft/close', JSON.stringify({}));
}

$(document).ready(function() {
    document.onkeyup = function(data) {
        if (data.which == 27) {
            $('.crafting-body').fadeOut();
            $('.title').fadeOut();
            $('.itemslist').fadeOut();
            $('.itemrequirements').fadeOut();
            $.post('https://fairplay-craft/close', JSON.stringify({}));
        }
    };
});

function craft(t) {
    var itemId = t.dataset.item;
    close()
    $.post('https://fairplay-craft/craft', JSON.stringify({
        itemID: itemId,
        table: tableID,
    }));
}