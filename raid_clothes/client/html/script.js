$('#clothesmenu').fadeOut(0);
$('#barbermenu').fadeOut(0);

var open = false;
var currentMenu = null;
var hairColors = null;
var makeupColors = null;
let headBlend = {};
let whitelisted = { male: [], female: [] };

whitelisted["male"] = {
    jackets:[124,299,291,314,344,359,387,388,389,390,391,396,397,398,399,400,402,404,446,485],
    undershirts:[121],
    legs:[149,150,151,158,165,166,172,176,187,188,189,190,191,192,193,194,195,196,208],
    shoes:[76,77,82,112,120,123,133,148,149,150,151,152,153,154,155,156,165],
    // decals:[1,2,3,4,5,6,7,8,9,10,11,12,14,15,44,45,61,62,63,64,66,67,70,71,72,73,74,75,79,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,111,112,113,114,115,116,126,128,129],
    hats:[82,83,84,91,92,93,94,95,96,97,98,100,101,102,103,107,117,138,139,140,141,153,157,158,159,160,161,171,175,176,177,178,179,189,193,194,207,208],
    // bags:[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,42,43,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,83,84,87,88,89,90,91,92,93,94,95,96,97,98,99,100],
    masks:[1,2,3,4,5,6,7,40,41,42,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,60,61,62,63,64,65,66,71,72,73,74,75,76,77,79,80,81,91,92,93,94,95,96,97,98,99,100,101,102,103,104,106,107],
    torsos:[97,98,110,111,164,165,166,167,168,169,195],
    // glasses:[27],
    // neck:[149,150],
    skins:[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255,256,257,258,259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,280,281,282,283,284,285,286,287,288,289,290,291,292,293,294,295,296,297,298,299,300,301,302,303,304,305,306,307,308,309,310,311,312,313,314,315,316,317,318,319,320,321,322,323,324,325,326,327,328,329,330,331,332,333,334,335,336,337,338,339,340,341,342,343,344,345,346,347,348,349,350,351,352,353,354,355,356,357,358,359,360,361,362,363,364,365,366,367,368,369,370,371,372,373,374,375,376,377,378,379],
}

// whitelisted["female"] = {
//     skins: [2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122,123,124,125,126,127,128,129,130,131,132,133,134,135,136,137,138,139,140],
// }

const throttle = (func, limit) => {
    let inThrottle
    return (...args) => {
        if (!inThrottle) {
            func(...args)
            inThrottle = setTimeout(() => inThrottle = false, limit)
        }
    }
}

$(function () {
    $('.modal').modal();

    window.addEventListener('message', function (event) {
        if (event.data.type == "enableclothesmenu") {
            open = event.data.enable;
            if (open) {
                currentMenu = $('#'+event.data.menu);
                document.body.style.display = "block";
                setTimeout(function () {
                    currentMenu.fadeIn(500);
                }, 1);
            } else {
                currentMenu.fadeOut(500);
                setTimeout(function () {
                    document.body.style.display = "none";
                }, 500);
            }
        }

        if (event.data.type == "colors") {
            hairColors = createPalette(event.data.hairColors);
            makeupColors = createPalette(event.data.makeupColors);
            AddPalettes();
            SetHairColor(event.data.hairColor);
        }

        if (event.data.type == "menutotals") {
            let drawTotal = event.data.drawTotal;
            let propDrawTotal = event.data.propDrawTotal;
            let textureTotal = event.data.textureTotal;
            let headoverlayTotal = event.data.headoverlayTotal;
            let skinTotal = event.data.skinTotal;
            UpdateTotals(drawTotal, propDrawTotal, textureTotal, headoverlayTotal, skinTotal);
        }
        if (event.data.type == "clothesmenudata") {
            let drawables = event.data.drawables;
            let props = event.data.props;
            let drawtextures = event.data.drawtextures;
            let proptextures = event.data.proptextures;
            let skin = event.data.skin;
            UpdateInputs(drawables, props, drawtextures, proptextures, skin);
        }

        if (event.data.type == "barbermenu") {
            headBlend = event.data.headBlend;
            SetupHeadBlend();
            SetupHeadOverlay(event.data.headOverlay);
            SetupHeadStructure(event.data.headStructure);
        }

        if (event.data.type == "escaping") {
            if (!($('#closemenu').hasClass('open'))) {
                $('#closemenu').modal('open');
            }
        }
    });

    document.onkeyup = function (data) {
        if (open) {
            // data.getModifierState("Shift") &&
            if (data.which == 27) {
                if ($('#closemenu').hasClass('open')) {
                    $('#closemenu').modal('close');
                }
                else {
                    $('#closemenu').modal('open');
                }
            }
        }
    };

    $('#save').on('click', function() {
        CloseMenu(true);
    });
    $('#discard').on('click', function() {
        CloseMenu(false);
    });

    function CloseMenu(save) {
        setTimeout(function() {
            if ($('#closemenu').hasClass('open')) {
                $('#closemenu').modal('close');
            }
        }, 1000);
        $.post('http://raid_clothes/escape', JSON.stringify({save:save}));
    }

    $(document).on('contextmenu', function() {
        $.post('http://raid_clothes/togglecursor', JSON.stringify({}));
    })

    $('.button-menu').on('click', function () {
        $('.button-menu').removeClass('active')
        $('.button-menu').each(function() {
            $("#" + $(this).attr('data-target')).fadeOut(100);
        })

        let t = $("#" + $(this).attr('data-target'))
        $(this).addClass('active');
        t.fadeIn(100);
    })

    function UpdateTotals(drawTotal, propDrawTotal, textureTotal, headoverlayTotal, skinTotal) {
        for (var i = 0; i < Object.keys(drawTotal).length; i++) {
            if (drawTotal[i][0] == "hair") {
                $('.hair').each(function() {
                    $(this).find('.total-number').eq(0).text(drawTotal[i][1]);
                })
            }
            $("#" + drawTotal[i][0]).find('.total-number').eq(0).text(drawTotal[i][1]);
        }

        for (var i = 0; i < Object.keys(propDrawTotal).length; i++) {
            $("#" + propDrawTotal[i][0]).find('.total-number').eq(0).text(propDrawTotal[i][1]);
        }

        for (const key of Object.keys(textureTotal)) {
            $("#" + key).find('.total-number').eq(1).text(textureTotal[key]);
        }

        for (const key of Object.keys(headoverlayTotal)) {
            $("#" + key).find('.total-number').eq(0).text(headoverlayTotal[key]);
        }

        let skinConts = $('#skins').find('.total-number');
        skinConts.eq(0).text(skinTotal[0]+1);
        skinConts.eq(1).text(skinTotal[1]+1);
    }

    function UpdateInputs(drawables, props, drawtextures, proptextures, skin) {
        for (var i = 0; i < Object.keys(drawables).length; i++) {
            if (drawables[i][0] == "hair") {
                $('.hair').each(function() {
                    $(this).find('.input-number').eq(0).val(drawables[i][1]);
                })
            }
            $("#" + drawables[i][0]).find('.input-number').eq(0).val(drawables[i][1]);
        }

        for (var i = 0; i < Object.keys(props).length; i++) {
            $("#" + props[i][0]).find('.input-number').eq(0).val(props[i][1]);
        }

        for (var i = 0; i < Object.keys(drawtextures).length; i++) {
            $("#" + drawtextures[i][0]).find('.input-number').eq(1).val(drawtextures[i][1]);
        }
        for (var i = 0; i < Object.keys(proptextures).length; i++) {
            $("#" + proptextures[i][0]).find('.input-number').eq(1).val(proptextures[i][1]);
        }

        if (skin['name'] == "skin_male") {
            $('#skin_male').val(skin['value'])
            if($('#skin_female').val() != 0){$('#skin_female').val(0)}
        }
        else {
            $('#skin_female').val(skin['value'])
            if($('#skin_male').val() != 0){$('#skin_male').val(0)}
        }
    }

    $('.button-left').on('click', function () {
        var input = $(this).parent().find('.input-number')
        input.val(parseInt(input.val()) - 1)
        inputChange(input,false)
    })
    $('.button-right').on('click', function () {
        var input = $(this).parent().find('.input-number')
        input.val(parseInt(input.val()) + 1)
        inputChange(input,true)
    })

    $('.input-number').on('input', function () {
        inputChange($(this),true)
    })

    $('.input-number').on('mousewheel', function () {})

    $('#skin_string').find('input').keypress(function (e) {
        if (e.which == 13) {
            $.post('http://raid_clothes/customskin', JSON.stringify($(this).val()));
        }
    })

    function inputChange(ele,inputType) {
        var inputs = $(ele).parent().parent().find('.input-number');
        var total = 0;

        if (currentMenu.is($('#clothesmenu')) || $(ele).parents('.panel').hasClass('hair')) {
            if (ele.is(inputs.eq(0))) {
                total = inputs.eq(0).parent().find('.total-number').text();
                inputs.eq(1).val(0);
            } else {
                total = inputs.eq(1).parent().find('.total-number').text();
            }

            if (parseInt($(ele).val()) > parseInt(total)-1) {
                $(ele).val(-1)
            } else if (parseInt($(ele).val()) < -1) {
                $(ele).val(parseInt(total)-1)
            }
            if (ele.is(inputs.eq(1)) && $(ele).val() == -1) {
                $(ele).val(0)
            }

            if(($('#skin_female').val() == 1 || $('#skin_male').val() == 1)) {
                let clothingName = $(ele).parents('.panel').attr('id');
                let clothingID = parseInt($(ele).val());
                let isNotValid = true
                let gender = "male";
                if($('#skin_female').val() >= 1 && $('#skin_male').val() == 0)
                    gender = "female";

                if(ele.is(inputs.eq(0)) && whitelisted[gender][clothingName]){
                    while (isNotValid) {
                        if(whitelisted[gender][clothingName].indexOf(clothingID) > -1 ){
                            isNotValid = true
                            if(inputType){clothingID++;}else{clothingID--;}

                        }
                        else
                        {
                            isNotValid = false;
                        }
                    }
                }
                $(ele).val(clothingID)
            }

            if ($(ele).parents('.panel').attr('id') == "skins") {
                if ($(ele).val() <= 1){
                    $.post('http://raid_clothes/setped', JSON.stringify({
                        "name": $(ele).attr('id'),
                        "value": $(ele).val()
                    }))
                }
            }
            else {
                let nameId = "";
                if (currentMenu.is($('#barbermenu')))
                    nameId = "hair"
                else
                    nameId = $(ele).parent().parent().parent().attr('id').split('#')[0]
                $.post('http://raid_clothes/updateclothes', JSON.stringify({
                    "name": nameId,
                    "value": inputs.eq(0).val(),
                    "texture": inputs.eq(1).val()
                })).done(function (data) {
                    inputs.eq(1).parent().find('.total-number').text(data);
                });
            }
        }
        else if (currentMenu.is($('#barbermenu'))) {
            if (ele.is(inputs.eq(0))) {
                total = inputs.eq(0).parent().find('.total-number').text();
            } else {
                total = inputs.eq(1).parent().find('.total-number').text();
            }

            var value = parseInt($(ele).val(), 10);
            total = parseInt(total, 10) - 1;

            if (value > 255) {
                value = 0;
            }
            else if (value === 254) {
                value = total;
            }
            else if (value < 0 || value > total) {
                value = 255;
            }

            $(ele).val(value);

            var activeID = $('#barbermenu').find('.active').attr('id');
            switch (activeID) {
                case "button-inheritance":
                    SaveHeadBlend();
                    break;
                case "button-appear":
                case "button-hair":
                case "button-features":
                    SaveHeadOverlay(ele);
                    break;
            }
        }
    }

    $('.slider-range').on('input', function() {
        if (currentMenu.is($('#barbermenu'))) {
            var activeID = $('#barbermenu').find('.active').attr('id');
            switch (activeID) {
                case "button-inheritance":
                    SaveHeadBlend();
                    break;
                case "button-faceshape":
                    SaveFaceShape($(this));
                    break;
                case "button-appear":
                case "button-hair":
                case "button-features":
                    SaveHeadOverlay($(this));
                    break;
            }
        }
    })

    // camera buttons
    function toggleCam(ele) {
        $('tog_head').removeClass('active');
        $('tog_torso').removeClass('active');
        $('tog_leg').removeClass('active');
        ele.addClass('active');
    }

    $('.tog_head').on('click', function() {
        toggleCam($(this));
        $.post('http://raid_clothes/switchcam', JSON.stringify({name: 'head'}))
    })
    $('.tog_torso').on('click', function() {
        toggleCam($(this));
        $.post('http://raid_clothes/switchcam', JSON.stringify({name: 'torso'}))
    })
    $('.tog_leg').on('click', function() {
        toggleCam($(this));
        $.post('http://raid_clothes/switchcam', JSON.stringify({name: 'leg'}))
    })
    $('.tog_cam').on('click', function() {
        toggleCam($(this));
        $.post('http://raid_clothes/switchcam', JSON.stringify({name: 'cam'}))
    })


    $('.tog_hat').on('click', function() {
        $.post('http://raid_clothes/toggleclothes', JSON.stringify({name: "hats"}))
    })
    $('.tog_glasses').on('click', function() {
        $.post('http://raid_clothes/toggleclothes', JSON.stringify({name: "glasses"}))
    })
    $('.tog_tops').on('click', function() {
        // dont look at this :)
        $.post('http://raid_clothes/toggleclothes', JSON.stringify({name: "jackets"}))
        $.post('http://raid_clothes/toggleclothes', JSON.stringify({name: "undershirts"}))
        $.post('http://raid_clothes/toggleclothes', JSON.stringify({name: "torsos"}))
        $.post('http://raid_clothes/toggleclothes', JSON.stringify({name: "vest"}))
        $.post('http://raid_clothes/toggleclothes', JSON.stringify({name: "bags"}))
        $.post('http://raid_clothes/toggleclothes', JSON.stringify({name: "neck"}))
        $.post('http://raid_clothes/toggleclothes', JSON.stringify({name: "decals"}))
    })
    $('.tog_legs').on('click', function() {
        $.post('http://raid_clothes/toggleclothes', JSON.stringify({name: "legs"}))
    })
    $('.tog_mask').on('click', function() {
        $.post('http://raid_clothes/toggleclothes', JSON.stringify({name: "masks"}))
    })

    $('#reset').on('click', function() {
        $.post('http://raid_clothes/resetped', JSON.stringify({}))
    })


    window.addEventListener("keydown", throttle(function (ev) {
        var input = $(ev.target);
        var num = input.hasClass('input-number');
        var _key = false;
        if (ev.which == 39 || ev.which == 68) {
            if (num === false) {
                _key = "left"
            }
            else if (num) {
                input.val(parseInt(input.val()) + 1)
                inputChange(input,true)
            }
        }
        if (ev.which == 37 || ev.which == 65) {
            if (num === false) {
                _key = "right"
            }
            else if (num) {
                input.val(parseInt(input.val()) - 1)
                inputChange(input,false)
            }
        }

        if (_key) {
            $.post('http://raid_clothes/rotate', JSON.stringify({key: _key}))
        }
    }, 50))




    /////////////////////////////////////////////////////////////////////////////////////////
    // Barber

    function SetHairColor(data) {
        $('.hair').each(function() {
            var palettes = $(this).find('.color_palette_container').eq(0).find('.color_palette')
            $(palettes[data[0]]).addClass('active')
            palettes = $(this).find('.color_palette_container').eq(1).find('.color_palette')
            $(palettes[data[1]]).addClass('active')
        })
    }

    function SetupHeadBlend() {
        if (headBlend == null) return;
        var sf = $('#shapeFirstP');
        var ss = $('#shapeSecondP');
        var st = $('#shapeThirdP');

        sf.find('.input-number').eq(0).val(headBlend['shapeFirst'])
        sf.find('.input-number').eq(1).val(headBlend['skinFirst'])
        ss.find('.input-number').eq(0).val(headBlend['shapeSecond'])
        ss.find('.input-number').eq(1).val(headBlend['skinSecond'])
        st.find('.input-number').eq(0).val(headBlend['shapeThird'])
        st.find('.input-number').eq(1).val(headBlend['skinThird'])

        $('#fmix').find('input').val(parseFloat(headBlend['shapeMix']) * 100)
        $('#smix').find('input').val(parseFloat(headBlend['skinMix']) * 100)
        $('#tmix').find('input').val(parseFloat(headBlend['thirdMix']) * 100)
    }

    function SaveHeadBlend() {
        headBlend = {}
        headBlend["shapeFirst"] = $("#shapeFirst").val()
        headBlend["shapeSecond"] = $("#shapeSecond").val()
        headBlend["shapeThird"] = $("#shapeThird").val()
        headBlend["skinFirst"] = $("#skinFirst").val()
        headBlend["skinSecond"] = $("#skinSecond").val()
        headBlend["skinThird"] = $("#skinThird").val()
        headBlend["shapeMix"] = $("#shapeMix").val()
        headBlend["skinMix"] = $("#skinMix").val()
        headBlend["thirdMix"] = $("#thirdMix").val()
        $.post('http://raid_clothes/saveheadblend', JSON.stringify(headBlend))
    }

    function SaveFaceShape(ele) {
        $.post('http://raid_clothes/savefacefeatures', JSON.stringify({name: ele.attr('data-value'), scale: ele.val()}))
    }

    function SetupHeadStructure(data) {
        let sliders = $('#faceshape').find('.slider-range')
        for (const key of Object.keys(data)) {
            sliders.each(function() {
                if ($(this).attr('data-value') == key) {
                    $(this).val(parseFloat(data[key]) * 100)
                }
            })
        }
    }

    function SetupHeadOverlay(data) {
        for (var i = 0; i < data.length; i++) {
            var ele = $("#"+data[i]['name'])
            var inputs = ele.find("input")
            inputs.eq(0).val(parseInt(data[i]['overlayValue']))
            inputs.eq(1).val(parseInt(data[i]['overlayOpacity'] * 100))
            var palettes = ele.find('.color_palette_container').eq(0).find('.color_palette')
            $(palettes[data[i]['firstColour']]).addClass('active')
            palettes = ele.find('.color_palette_container').eq(1).find('.color_palette')
            $(palettes[data[i]['secondColour']]).addClass('active')
        }
    }

    function SaveHeadOverlay(ele) {
        var id = ele.parents('.panel').attr('id')
        var inputs = ele.parents('.panel-bottom').find('input')
        let opacity = inputs.eq(1).val() ? inputs.eq(1).val() : 0
        $.post('http://raid_clothes/saveheadoverlay', JSON.stringify({
            name: id,
            value: inputs.eq(0).val(),
            opacity: opacity
        }))
    }

    function AddPalettes() {
        $('.collapsible').collapsible();
        $('.color_palette_container').each(function () {
            $(this).empty()
            if ($(this).hasClass('haircol')) {
                $(this).append($(hairColors))
            }
            if ($(this).hasClass('makeupcol')) {
                $(this).append($(makeupColors))
            }
        });
        $('.color_palette').on('click', function() {
            var palettes = $(this).parents('.panel').find('.color_palette_container')

            $(this).parent().find('.color_palette').removeClass('active')
            $(this).addClass('active')

            if ($(this).parents('.panel').hasClass('hair')) {
                $.post('http://raid_clothes/savehaircolor', JSON.stringify({
                    firstColour: palettes.eq(0).find('.active').attr('value'),
                    secondColour: palettes.eq(1).find('.active').attr('value')
                }));
            }
            else {
                $.post('http://raid_clothes/saveheadoverlaycolor', JSON.stringify({
                    firstColour: palettes.eq(0).find('.active').attr('value'),
                    secondColour: palettes.eq(1).find('.active').attr('value'),
                    name: $(this).parents('.panel').attr('id')
                }));
            }
        })
    }

    function createPalette(array) {
        var ele_string = ""
        for (var i = 0; i < Object.keys(array).length; i++) {
            var color = array[i][0]+","+array[i][1]+","+array[i][2]
            ele_string += '<div class="color_palette" style="background-color: rgb('+color+')" value="'+i+'"></div>'
        }
        return ele_string
    }
});
