RequestStreamedTextureDict("CommonMenu")
JayMenu = { }
JayMenu.debug = false
local menus = { }
local keys = { 
    up = 172, 
    down = 173, 
    left = 174, 
    right = 175, 
    select = 176, 
    back = 177,
    mup = 181,
    mdown = 180,
}

local optionCount = 0

local currentKey = nil
local currentDesc = nil

local currentMenu = nil

local menuWidth = 0.23

local titleHeight = 0.09
local titleYOffset = 0.02
local titleScale = 0.9

local buttonHeight = 0.038
local buttonFont = 0
local buttonScale = 0.365
local buttonTextXOffset = 0.005
local buttonTextYOffset = 0.005

local continuity = {}

local function HudColourToTable(r,g,b,a) return { r, g, b, a or 255 } end
local function setMenuProperty(id, property, value)
    if id and menus[id] then
        menus[id][property] = value
    end
end

local function isMenuVisible(id)
    if id and menus[id] then
        return menus[id].visible
    else
        return false
    end
end

local function setMenuVisible(id, visible, holdCurrent)
    if id and menus[id] then
        setMenuProperty(id, 'visible', visible)

        if visible then
            if id ~= currentMenu and isMenuVisible(currentMenu) then
                setMenuVisible(currentMenu, false, true)
            else
                setMenuProperty(id, 'currentOption', 1)
            end

            currentMenu = id
        end
    end
end

local function drawText(text, x, y, font, color, scale, center, shadow, alignRight)
    BeginTextCommandDisplayText("STRING")
        if color then 
            SetTextColour(color[1], color[2], color[3], color[4])
        else
            SetTextColour(255, 255, 255, 255)
        end
        SetTextFont(font)
        SetTextScale(scale, scale)

        if shadow then
            SetTextDropShadow(2, 2, 0, 0, 0)
        end

        if menus[currentMenu] then
            if center then
                SetTextCentre(center)
            elseif alignRight then
                SetTextWrap(menus[currentMenu].x, menus[currentMenu].x + menuWidth - buttonTextXOffset)
                SetTextRightJustify(true)
            end
        end
        AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

local function getLineHeight(text, font, color, scale, center, shadow, alignRight)
	BeginTextCommandLineCount("STRING")
        if color then 
            SetTextColour(color[1], color[2], color[3], color[4])
        else
            SetTextColour(255, 255, 255, 255)
        end
        SetTextFont(font)
        SetTextScale(scale, scale)

        if shadow then
            SetTextDropShadow(2, 2, 0, 0, 0)
        end

		if menus[currentMenu] then
			SetTextWrap(menus[currentMenu].x, menus[currentMenu].x + menuWidth - buttonTextXOffset)
            if center then
                SetTextCentre(center)
            elseif alignRight then
                SetTextRightJustify(true)
            end
		end
		AddTextComponentSubstringPlayerName(text)
	return GetTextScreenLineCount(menus[currentMenu].x, menus[currentMenu].x + menuWidth - buttonTextXOffset)
end

local function drawRect(x, y, width, height, color)
    DrawRect(x, y, width, height, color[1], color[2], color[3], color[4])
end

local function drawSprite(textDict, sprite, x, y, scale, color)
    if HasStreamedTextureDictLoaded(textDict) then
        DrawSprite(textDict, sprite, x, y, 0.0265, 0.05, 0, color[1], color[2], color[3], color[4])
    else
        RequestStreamedTextureDict(textDict, false)
    end
end

local function drawTitle()
    if menus[currentMenu] then
        local x = menus[currentMenu].x + menuWidth / 2
        local y = menus[currentMenu].y + titleHeight / 2

		if menus[currentMenu].titleFont == "!sprite!" then
			local color = menus[currentMenu].titleBackgroundColor
			local textDict, sprite = table.unpack(menus[currentMenu].titleColor)
			--print("txd:"..textDict.." spr:"..sprite.." col:"..color.r..","..color.g..","..color.b..","..color.a)
			RequestStreamedTextureDict(textDict, false)
			HasStreamedTextureDictLoaded(textDict)
			DrawSprite(textDict, sprite, x, y, menuWidth, titleHeight, 0, color[1], color[2], color[3], color[4])
		elseif menus[currentMenu].titleFont == "~sprite~" then
			local color = menus[currentMenu].titleBackgroundColor
			local textDict, sprite = table.unpack(menus[currentMenu].titleColor)
			--print("txd:"..textDict.." spr:"..sprite.." col:"..color.r..","..color.g..","..color.b..","..color.a)
			RequestStreamedTextureDict(textDict, false)
			HasStreamedTextureDictLoaded(textDict)
			DrawSprite(textDict, sprite, x, y, menuWidth, titleHeight, 0, color[1], color[2], color[3], color[4])
			drawText(menus[currentMenu].title, x, y - titleHeight / 2 + titleYOffset, 1, {255, 255, 255, 255}, titleScale, true)
		else
            if HasStreamedTextureDictLoaded("CommonMenu") then
                SetUiLayer(0)
                DrawSprite("CommonMenu", "interaction_bgd", x, y, menuWidth, titleHeight, 0.0, 255, 255, 255, 255, 0)
            end
			--drawRect(x, y, menuWidth, titleHeight, menus[currentMenu].titleBackgroundColor)
			drawText(menus[currentMenu].title, x, y - titleHeight / 2 + titleYOffset, menus[currentMenu].titleFont, menus[currentMenu].titleColor, titleScale, true)
        end

        local x,y,color,textDict,sprite = nil,nil,nil,nil,nil
    end
end

local function drawSubTitle()
    if menus[currentMenu] then
        local x = menus[currentMenu].x + (menuWidth / 2)
        local y = menus[currentMenu].y + (titleHeight + buttonHeight / 2)
        local subtitle = menus[currentMenu].subTitle

        --local subTitleColor = { r = menus[currentMenu].titleBackgroundColor.r, g = menus[currentMenu].titleBackgroundColor.g, b = menus[currentMenu].titleBackgroundColor.b, a = 255 }
        --local subTitleColor = {255, 255, 255, 255}    

        drawRect(x, y, menuWidth, buttonHeight, menus[currentMenu].subTitleBackgroundColor)
        if subtitle:find("|") then
            drawText(subtitle:sub(1,subtitle:find("|")-1), menus[currentMenu].x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, false, buttonScale, false)
            drawText(subtitle:sub(subtitle:find("|")+1), menus[currentMenu].x + menuWidth, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, false, buttonScale, false, false, true)
        else
            drawText(menus[currentMenu].subTitle, menus[currentMenu].x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, false, buttonScale, false)
            drawText(tostring(menus[currentMenu].currentOption)..' / '..tostring(optionCount), menus[currentMenu].x + menuWidth, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, false, buttonScale, false, false, true)
        end

        local x,y,subTitleColor = nil, nil, nil
    end
end

local function drawDescription()
    if menus[currentMenu] then
        local x = menus[currentMenu].x + menuWidth / 2
		local menuHeight = buttonHeight*(((optionCount <= menus[currentMenu].maxOptionCount) and optionCount or menus[currentMenu].maxOptionCount + 1) + 1)
		
		local lines = getLineHeight(currentDesc, buttonFont, menus[currentMenu].menuTextColor, buttonScale, false, true)

		local descriptionHeight = lines*(buttonTextYOffset*5) + buttonTextYOffset*2
		local descriptionY = descriptionHeight/2

		local y = menus[currentMenu].y + titleHeight + menuHeight + descriptionHeight/2 + buttonTextYOffset
		local dividerY = y - descriptionHeight/2 + buttonTextYOffset/2

        if HasStreamedTextureDictLoaded("CommonMenu") then
			SetUiLayer(0)
			
			DrawRect(x, dividerY, menuWidth, buttonTextYOffset, 0, 0, 0, 255)
			DrawSprite("CommonMenu", "Gradient_Bgd", x, y, menuWidth, descriptionHeight, 0.0, 255, 255, 255, 220, 0)

			drawText(currentDesc, menus[currentMenu].x + buttonTextXOffset, y - descriptionY + buttonTextYOffset, buttonFont, menus[currentMenu].menuTextColor, buttonScale, false, true)
        else
            RequestStreamedTextureDict("CommonMenu")
        end

        x,y,menuHeight = nil, nil, nil
    end
end

local function drawMenuBackground()
    if menus[currentMenu] then
        local x = menus[currentMenu].x + menuWidth / 2
        local menuHeight = buttonHeight*( (optionCount <= menus[currentMenu].maxOptionCount) and optionCount or menus[currentMenu].maxOptionCount )
        local y = menus[currentMenu].y + titleHeight + buttonHeight + menuHeight / 2

        if HasStreamedTextureDictLoaded("CommonMenu") then
            SetUiLayer(0)
            DrawSprite("CommonMenu", "Gradient_Bgd", x, y, menuWidth, menuHeight, 0.0, 255, 255, 255, 255, 0)
        else
            RequestStreamedTextureDict("CommonMenu")
        end

        local x,y,menuHeight = nil, nil, nil
    end
end

local function drawArrows()
    local x = menus[currentMenu].x + menuWidth / 2
    local menuHeight = buttonHeight*(menus[currentMenu].maxOptionCount+1)
    local y = menus[currentMenu].y + titleHeight + menuHeight + buttonHeight/2

    if HasStreamedTextureDictLoaded("CommonMenu") then
        local colour = menus[currentMenu].subTitleBackgroundColor
        drawRect(x, y, menuWidth, buttonHeight, {colour[1], colour[2], colour[3], 182})
        DrawSprite("CommonMenu", "shop_arrows_upanddown", x, y, 0.0265, 0.05, 0.0, 255, 255, 255, 255, 0)
    else
        RequestStreamedTextureDict("CommonMenu")
    end

    local x,menuHeight,y,color = nil, nil, nil, nil
end

local function drawButton(text, subText)
    local x = menus[currentMenu].x + menuWidth / 2
    local multiplier = nil

    if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
        multiplier = optionCount
    elseif optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].currentOption then
        multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
    end

    if multiplier then
        local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2
        local backgroundColor = nil
        local textColor = nil
        local subTextColor = nil
        local shadow = false

        if menus[currentMenu].currentOption == optionCount and text ~= "" then
            backgroundColor = menus[currentMenu].menuFocusBackgroundColor
            textColor = menus[currentMenu].menuFocusTextColor
            subTextColor = menus[currentMenu].menuFocusTextColor
        else
            backgroundColor = menus[currentMenu].menuBackgroundColor
            textColor = menus[currentMenu].menuTextColor
            subTextColor = menus[currentMenu].menuSubTextColor
            shadow = true
        end

        if text ~= "!!separator!!" then
            if menus[currentMenu].currentOption == optionCount and HasStreamedTextureDictLoaded("CommonMenu") then
                SetUiLayer(1)
                DrawSprite("CommonMenu", "Gradient_Nav", x, y, menuWidth, buttonHeight, 0.0, 255, 255, 255, 255, 0)
            end
            --drawRect(x, y, menuWidth, buttonHeight, backgroundColor)
            drawText(text, menus[currentMenu].x + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset, buttonFont, textColor, buttonScale, false, shadow)

            if subText then
                drawText(subText, menus[currentMenu].x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, subTextColor, buttonScale, false, shadow, true)
            end
        end
    end

    local x,y,backgroundColor,textColor,subTextColor,shadow,multiplier = nil, nil, nil, nil, nil, nil, nil
end

local function drawDisabledButton(text, subText)
    local x = menus[currentMenu].x + menuWidth / 2
    local multiplier = nil

    if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
        multiplier = optionCount
    elseif optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].currentOption then
        multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
    end

    if multiplier then
        local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2
        local backgroundColor = menus[currentMenu].menuBackgroundColor
        local textColor = HudColourToTable(GetHudColour(5))
        local subTextColor = HudColourToTable(GetHudColour(5))
        local shadow = false

        --[[if menus[currentMenu].currentOption == optionCount and HasStreamedTextureDictLoaded("CommonMenu") then
            SetUiLayer(1)
            DrawSprite("CommonMenu", "Gradient_Nav", x, y, menuWidth, buttonHeight, 0.0, 255, 255, 255, 255, 0)
        end]]
        --drawRect(x, y, menuWidth, buttonHeight, backgroundColor)
        drawText(text, menus[currentMenu].x + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset, buttonFont, textColor, buttonScale, false, shadow)

        if subText then
            drawText(subText, menus[currentMenu].x + buttonTextXOffset, y - buttonHeight / 2 + buttonTextYOffset, buttonFont, subTextColor, buttonScale, false, shadow, true)
        end
    end

    local x,y,backgroundColor,textColor,subTextColor,shadow,multiplier = nil, nil, nil, nil, nil, nil, nil
end

local function drawSpriteButton(text, textDict, sprite, focusSprite)
    local x = menus[currentMenu].x + menuWidth / 2
    local multiplier = nil

    if menus[currentMenu].currentOption <= menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].maxOptionCount then
        multiplier = optionCount
    elseif optionCount > menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount and optionCount <= menus[currentMenu].currentOption then
        multiplier = optionCount - (menus[currentMenu].currentOption - menus[currentMenu].maxOptionCount)
    end

    if multiplier then
        local y = menus[currentMenu].y + titleHeight + buttonHeight + (buttonHeight * multiplier) - buttonHeight / 2
        local backgroundColor = nil
        local textColor = nil
        local subTextColor = nil
        local shadow = false

        if menus[currentMenu].currentOption == optionCount then
            backgroundColor = menus[currentMenu].menuFocusBackgroundColor
            textColor = menus[currentMenu].menuFocusTextColor
            subTextColor = menus[currentMenu].menuFocusTextColor
        else
            backgroundColor = menus[currentMenu].menuBackgroundColor
            textColor = menus[currentMenu].menuTextColor
            subTextColor = menus[currentMenu].menuSubTextColor
            shadow = true
        end

        if menus[currentMenu].currentOption == optionCount and HasStreamedTextureDictLoaded("CommonMenu") then
            SetUiLayer(1)
            DrawSprite("CommonMenu", "Gradient_Nav", x, y, menuWidth, buttonHeight, 0.0, 255, 255, 255, 255, 0)
        end
        
        drawText(text, menus[currentMenu].x + buttonTextXOffset, y - (buttonHeight / 2) + buttonTextYOffset, buttonFont, textColor, buttonScale, false, shadow)

        if textDict and sprite then
			if focusSprite then
                if menus[currentMenu].currentOption == optionCount then
                    SetUiLayer(2)
					drawSprite(textDict, focusSprite, menus[currentMenu].x + menuWidth - buttonTextXOffset*2 , y - buttonHeight / 2 + (buttonTextYOffset*3.75), buttonScale, menus[currentMenu].menuSubTextColor)
                else
                    SetUiLayer(2)
					drawSprite(textDict, sprite, menus[currentMenu].x + menuWidth - buttonTextXOffset*2 , y - buttonHeight / 2 + (buttonTextYOffset*3.75), buttonScale, subTextColor)
				end
            else
                SetUiLayer(2)
				drawSprite(textDict, sprite, menus[currentMenu].x + menuWidth - buttonTextXOffset*2 , y - buttonHeight / 2 + (buttonTextYOffset*3.75), buttonScale, subTextColor)
			end
        end
    end

    local x,y,backgroundColor,textColor,subTextColor,shadow,multiplier = nil, nil, nil, nil, nil, nil, nil
end

local function stopConflictingInputs()
    -- isolates menu navigation buttons and stops jumping, weapon selection and opening of the pause menu

    for _,key in pairs(keys) do
        SetInputExclusive(0, key)
    end
    DisableControlAction(0, 22, true) 
    DisableControlAction(0, 37, true)
    DisableControlAction(0, 38, true)
    DisableControlAction(0, 200, true)
end

-- API
function JayMenu.CreateMenu(id, title, closeCallback)
    -- Default settings
    menus[id] = { }
    menus[id].title = title
    menus[id].subTitle = 'INTERACTION MENU'

    menus[id].visible = false

    menus[id].previousMenu = nil

    menus[id].aboutToBeClosed = false

    -- Top left corner
    menus[id].x = 0.0145
    menus[id].y = 0.075

    menus[id].currentOption = 1
    menus[id].maxOptionCount = 12

    menus[id].titleFont = 1
    menus[id].titleColor = {255, 255, 255, 255}
    menus[id].titleBackgroundColor = {255, 255, 255, 255}

    menus[id].menuTextColor = {255, 255, 255, 255}
    menus[id].menuSubTextColor = {255, 255, 255, 255}
    menus[id].menuFocusTextColor = {0, 0, 0, 255}
    menus[id].menuFocusBackgroundColor = {245, 245, 245, 255}
    menus[id].menuBackgroundColor = {0, 0, 0, 160}

    menus[id].subTitleBackgroundColor = {menus[id].menuBackgroundColor[1], menus[id].menuBackgroundColor[2], menus[id].menuBackgroundColor[3], 255 }

    menus[id].buttonPressedSound = { name = "SELECT", set = "HUD_FRONTEND_DEFAULT_SOUNDSET" } --https://pastebin.com/0neZdsZ5

    menus[id].closeCallback = closeCallback or function() return true end
end


function JayMenu.CreateSubMenu(id, parent, subTitle, closeCallback)
    if menus[parent] then
        JayMenu.CreateMenu(id, menus[parent].title)

        if subTitle then
            setMenuProperty(id, 'subTitle', string.upper(subTitle))
        else
            setMenuProperty(id, 'subTitle', string.upper(menus[parent].subTitle))
        end

        setMenuProperty(id, 'previousMenu', parent)

        setMenuProperty(id, 'x', menus[parent].x)
        setMenuProperty(id, 'y', menus[parent].y)
        setMenuProperty(id, 'maxOptionCount', menus[parent].maxOptionCount)
        setMenuProperty(id, 'titleFont', menus[parent].titleFont)
        setMenuProperty(id, 'titleColor', menus[parent].titleColor)
        setMenuProperty(id, 'titleBackgroundColor', menus[parent].titleBackgroundColor)
        setMenuProperty(id, 'menuTextColor', menus[parent].menuTextColor)
        setMenuProperty(id, 'menuSubTextColor', menus[parent].menuSubTextColor)
        setMenuProperty(id, 'menuFocusTextColor', menus[parent].menuFocusTextColor)
        setMenuProperty(id, 'menuFocusBackgroundColor', menus[parent].menuFocusBackgroundColor)
        setMenuProperty(id, 'menuBackgroundColor', menus[parent].menuBackgroundColor)
        setMenuProperty(id, 'subTitleBackgroundColor', menus[parent].subTitleBackgroundColor)
        setMenuProperty(id, 'closeCallback', closeCallback or function() return true end)
        -- :(
    end
end


function JayMenu.CurrentMenu()
    return currentMenu
end

function JayMenu.MenuTable()
    return menus
end


function JayMenu.OpenMenu(id)
    if id and menus[id] then
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
        setMenuVisible(id, true)
    end
end


function JayMenu.IsMenuOpened(id)
    return isMenuVisible(id)
end


function JayMenu.IsAnyMenuOpened()
    for id, _ in pairs(menus) do
        if isMenuVisible(id) then return true end
    end

    return false
end

function JayMenu.IsAnyMenuWithTitleOpened(subtitle)
    for id, v in pairs(menus) do
		if isMenuVisible(id) then
			if v.title == subtitle then
				return true
			end
		end
    end

    return false
end

function JayMenu.IsMenuAboutToBeClosed()
    if menus[currentMenu] then
        return menus[currentMenu].aboutToBeClosed
    else
        return false
    end
end

function JayMenu.IsThisMenuAboutToBeClosed(id)
    if menus[id] then
        return menus[id].aboutToBeClosed
    else
        return false
    end
end


function JayMenu.CloseMenu()
    if menus[currentMenu] then
        if menus[currentMenu].aboutToBeClosed then
            menus[currentMenu].aboutToBeClosed = false
            setMenuVisible(currentMenu, false)
            PlaySoundFrontend(-1, "QUIT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            optionCount = 0
            currentMenu = nil
			currentKey = nil
			currentDesc = nil

            -- keep continuity
            if continuity.lastPedWeapon then
                SetCurrentPedWeapon(PlayerPedId(), continuity.lastPedWeapon, true)
            end
            
            continuity = {}

            Citizen.CreateThread(function()
                while IsDisabledControlPressed(0, 200) or IsDisabledControlJustReleased(0, 200) do
                    Citizen.Wait(0)
                    DisableControlAction(0, 200, true)
                end
            end)
        else
            if menus[currentMenu].closeCallback() then
                menus[currentMenu].aboutToBeClosed = true
            end
        end
    end
end

function JayMenu.Button(text, subText)
    local buttonText = text
    if subText then
        buttonText = '{ '..tostring(buttonText)..', '..tostring(subText)..' }'
    end

    if menus[currentMenu] then
        optionCount = optionCount + 1

        local isCurrent = menus[currentMenu].currentOption == optionCount

        drawButton(text, subText)

        if isCurrent then
			if text == "!!separator!!" then
				if IsDisabledControlPressed(0, keys.up) then
					menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
				elseif IsDisabledControlPressed(0, keys.down) then
					menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
				end
			elseif currentKey == keys.select then
				if text ~= "" then PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true) end
				return true, isCurrent
			elseif currentKey == keys.left or currentKey == keys.right then
				if text ~= "" then PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true) end
			end
        end

        return false, isCurrent
    else
        return false
    end

    local buttonText,isCurrent = nil, nil
end

function JayMenu.DisabledButton(text, subText)
    local buttonText = text
    if subText then
        buttonText = '{ '..tostring(buttonText)..', '..tostring(subText)..' }'
    end

    if menus[currentMenu] then
        optionCount = optionCount + 1

        local isCurrent = menus[currentMenu].currentOption == optionCount

        drawDisabledButton(text ~= "!!separator!!" and text or "", subText)

        if isCurrent then
            if IsDisabledControlPressed(0, 172) then
                menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
            elseif IsDisabledControlPressed(0, 173) then
                menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
            end
        end

        return false, isCurrent
    else
        return false
    end

    local buttonText,isCurrent = nil, nil
end

function JayMenu.SpriteButton(text, textDict, sprite, focusSprite)
    local buttonText = text

    if menus[currentMenu] then
        optionCount = optionCount + 1

        local isCurrent = menus[currentMenu].currentOption == optionCount

        drawSpriteButton(text, textDict, sprite, focusSprite)

        if isCurrent then
            if currentKey == keys.select then
                PlaySoundFrontend(-1, menus[currentMenu].buttonPressedSound.name, menus[currentMenu].buttonPressedSound.set, true)
                return true, isCurrent
            elseif currentKey == keys.left or currentKey == keys.right then
                PlaySoundFrontend(-1, "NAV_LEFT_RIGHT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
            end
        end

        return false, isCurrent
    else
        return false, isCurrent
    end

    local buttonText,isCurrent = nil, nil
end

function JayMenu.SpriteMenuButton(text, textDict, sprite, focusSprite, id)
    if menus[id] then
        local clicked, hovered = JayMenu.SpriteButton(text, textDict, sprite, focusSprite)
        if clicked then
            setMenuVisible(currentMenu, false)
            setMenuVisible(id, true, true)
        end
        return clicked, hovered
    end

    local clicked,hovered = nil, nil
end

function JayMenu.ComboBox(text, items, currentIndex, selectedIndex, callback, displaycb)
    local itemsCount = #items
    local isCurrent = menus[currentMenu].currentOption == (optionCount + 1)
	local getDisplayText = displaycb or (function(t) return tostring(t or "") end)
	local selectedItem = getDisplayText(items[currentIndex])

    if itemsCount > 1 and isCurrent then
        selectedItem = '← '..selectedItem..' →'
    end

    if JayMenu.Button(text, selectedItem) then
        selectedIndex = currentIndex
        callback(currentIndex, selectedIndex)
        return true,isCurrent
    elseif isCurrent then
        if currentKey == keys.left then
            if currentIndex > 1 then currentIndex = currentIndex - 1 else currentIndex = itemsCount end
        elseif currentKey == keys.right then
            if currentIndex < itemsCount then currentIndex = currentIndex + 1 else currentIndex = 1 end
        end
    else
        currentIndex = selectedIndex
    end

    callback(currentIndex, selectedIndex)
    -- local itemsCount,isCurrent,getDisplayText,selectedItem = nil
    return false, isCurrent
end

function JayMenu.MenuButton(text, id, secondtext)
    if menus[id] then
		local clicked, hovered = JayMenu.Button(text, (secondtext and secondtext or "→")) 
		if clicked then
            setMenuVisible(currentMenu, false)
            setMenuVisible(id, true, true)

            return true, true
		end
		
		return false, hovered
    end

    return false, false
end

function JayMenu.SwitchMenu(id)
	setMenuVisible(currentMenu, false)
    setMenuVisible(id, true, true)
end

function JayMenu.SetDescription(text)
	currentDesc = tostring(text)
end

function JayMenu.CheckBox(text, bool, callback)
    local sprite = bool and "shop_box_tick" or "shop_box_blank"
    local focusSprite = bool and "shop_box_tickb" or "shop_box_blankb"

    if JayMenu.SpriteButton(text, "commonmenu", sprite, focusSprite) then
        bool = not bool
        callback(bool)

        return true
    end

    local sprite,focusSprite = nil, nil

    return false
end

function JayMenu.Display()
    if isMenuVisible(currentMenu) and not IsPauseMenuActive() then

        stopConflictingInputs()

        if menus[currentMenu].aboutToBeClosed then
            JayMenu.CloseMenu()
        else
            ClearAllHelpMessages()

            drawTitle()
			drawSubTitle()
			if currentDesc then
				drawDescription()
			end
            drawMenuBackground()
            if optionCount > menus[currentMenu].maxOptionCount then
                drawArrows()
            end

            currentKey = nil
			currentDesc = nil

            if IsDisabledControlJustPressed(0, keys.down) or IsDisabledControlJustPressed(0, keys.mdown) then
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

                if menus[currentMenu].currentOption < optionCount then
                    menus[currentMenu].currentOption = menus[currentMenu].currentOption + 1
                else
                    menus[currentMenu].currentOption = 1
                end
            elseif IsDisabledControlJustPressed(0, keys.up) or IsDisabledControlJustPressed(0, keys.mup) then
                PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)

                if menus[currentMenu].currentOption > 1 then
                    menus[currentMenu].currentOption = menus[currentMenu].currentOption - 1
                else
                    menus[currentMenu].currentOption = optionCount
                end
            elseif IsDisabledControlJustPressed(0, keys.left) then
                currentKey = keys.left
            elseif IsDisabledControlJustPressed(0, keys.right) then
                currentKey = keys.right
            elseif IsDisabledControlJustPressed(0, keys.select) then
                currentKey = keys.select
            elseif IsDisabledControlJustPressed(0, keys.back) then
                if menus[menus[currentMenu].previousMenu] then
                    PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
                    menus[currentMenu].closeCallback()
                    setMenuVisible(menus[currentMenu].previousMenu, true)
                else
                    JayMenu.CloseMenu()
                end
            end

            optionCount = 0
        end
    end
end


function JayMenu.SetMenuWidth(id, width)
    setMenuProperty(id, 'width', width)
end


function JayMenu.SetMenuX(id, x)
    setMenuProperty(id, 'x', x)
end


function JayMenu.SetMenuY(id, y)
    setMenuProperty(id, 'y', y)
end


function JayMenu.SetMenuMaxOptionCountOnScreen(id, count)
    setMenuProperty(id, 'maxOptionCount', count)
end


function JayMenu.SetTitleColor(id, r, g, b, a)
    setMenuProperty(id, 'titleColor', { r, g, b, a or  menus[id].titleColor[4] })
end


function JayMenu.SetTitleBackgroundColor(id, r, g, b, a)
    setMenuProperty(id, 'titleBackgroundColor', { r, g, b, a or menus[id].titleBackgroundColor[4] })
end


function JayMenu.UseSpriteAsBackground(id, textDict, sprite, r, g, b, a, stillDrawText)
	if stillDrawText then setMenuProperty(id, 'titleFont', "~sprite~") else setMenuProperty(id, 'titleFont', "!sprite!") end
    setMenuProperty(id, 'titleColor', {textDict, sprite})
	setMenuProperty(id, 'titleBackgroundColor', { r, g, b, a or menus[id].titleBackgroundColor[4] })
end


function JayMenu.SetSubTitle(id, text)
    setMenuProperty(id, 'subTitle', string.upper(text))
end


function JayMenu.SetMenuBackgroundColor(id, r, g, b, a)
    setMenuProperty(id, 'menuBackgroundColor', { r, g, b, a or menus[id].menuBackgroundColor[4] })
end


function JayMenu.SetMenuTextColor(id, r, g, b, a)
    setMenuProperty(id, 'menuTextColor', { r, g, b, a or menus[id].menuTextColor[4] })
end

function JayMenu.SetMenuSubTextColor(id, r, g, b, a)
    setMenuProperty(id, 'menuSubTextColor', { r, g, b, a or menus[id].menuSubTextColor[4] })
end

function JayMenu.SetMenuFocusColor(id, r, g, b, a)
    setMenuProperty(id, 'menuFocusColor', { r, g, b, a or menus[id].menuFocusColor[4] })
end


function JayMenu.SetMenuButtonPressedSound(id, name, set)
    setMenuProperty(id, 'buttonPressedSound', { ['name'] = name, ['set'] = set })
end

local currentTattoos = {}
local cam = nil
local back = 1
local opacity = 1
local scaleType = nil
local scaleString = ""

local tattoosConfig = {}

tattoosConfig.AllTattooList = json.decode(LoadResourceFile("vrp", 'tattoosList.json'))
tattoosConfig.TattooCats = {
	{"ZONE_HEAD", "Cap/Gat", {vec(0.0, 0.7, 0.7), vec(0.7, 0.0, 0.7), vec(0.0, -0.7, 0.7), vec(-0.7, 0.0, 0.7)}, vec(0.0, 0.0, 0.5)},
	{"ZONE_LEFT_LEG", "Piciorul stang", {vec(-0.2, 0.7, -0.7), vec(-0.7, 0.0, -0.7), vec(-0.2, -0.7, -0.7)}, vec(-0.2, 0.0, -0.6)},
	{"ZONE_LEFT_ARM", "Mana stanga", {vec(-0.4, 0.5, 0.2), vec(-0.7, 0.0, 0.2), vec(-0.4, -0.5, 0.2)}, vec(-0.2, 0.0, 0.2)},
	{"ZONE_RIGHT_LEG", "Piciorul drept", {vec(0.2, 0.7, -0.7), vec(0.7, 0.0, -0.7), vec(0.2, -0.7, -0.7)}, vec(0.2, 0.0, -0.6)},
	{"ZONE_TORSO", "Piept/Spate", {vec(0.0, 0.7, 0.2), vec(0.0, -0.7, 0.2)}, vec(0.0, 0.0, 0.2)},
	{"ZONE_RIGHT_ARM", "Mana dreapta", {vec(0.4, 0.5, 0.2), vec(0.7, 0.0, 0.2), vec(0.4, -0.5, 0.2)}, vec(0.2, 0.0, 0.2)},
}

tattoosConfig.Shops = {
	vec(1323.3127441406,-1652.2852783204,52.275325775146),
	vec(-1153.4708251954,-1425.9536132812,4.9544591903686),
	vec(322.1, 180.4, 103.5),
	vec(-3170.0, 1075.0, 20.8),
	vec(1864.6, 3747.7, 33.0),
	vec(-293.7, 6200.0, 31.4)
}

local function IsMenuOpen()
	return (JayMenu.IsMenuOpened('tattoo') or string.find(tostring(JayMenu.CurrentMenu() or ""), "ZONE_"))	
end

local function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

local function Button(ControlButton)
    PushScaleformMovieMethodParameterButtonName(ControlButton)
end

local function setupScaleform(scaleform, message, button)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(2, button, true))
    ButtonMessage(message)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

local function setupScaleform2(scaleform, message, button, message2, buttons, message3, button2)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()
	
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(2, buttons[1], true))
    Button(GetControlInstructionalButton(2, buttons[2], true))
    ButtonMessage(message2)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(2, button, true))
    ButtonMessage(message)
    PopScaleformMovieFunctionVoid()
	
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(2, button2, true))
    ButtonMessage(message3)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

Citizen.CreateThread(function()
	for k, v in pairs(tattoosConfig.Shops) do
		tvRP.createBlip(("_vRP_tattooS_blip:%d"):format(k), v.x, v.y, v.z, 75, 40, "Magazin Tatuaje", 0.550)
	end
end)

RegisterNetEvent('vRPclothes:setTattoos', function(tattooList)
	if tattooList then
		ClearPedDecorations(tempPed)
		for k, v in pairs(tattooList) do
			if v.Count ~= nil then
				for i = 1, v.Count do
					SetPedDecoration(tempPed, v.collection, v.nameHash)
				end
			else
				SetPedDecoration(tempPed, v.collection, v.nameHash)
			end
		end

		currentTattoos = tattooList
	end
end)

CreateThread(function()
	while true do
		Wait(300000)
		if not IsMenuOpen() then
			ClearPedDecorations(tempPed)
			for k, v in pairs(currentTattoos) do
				if v.Count ~= nil then
					for i = 1, v.Count do
						SetPedDecoration(tempPed, v.collection, v.nameHash)
					end
				else
					SetPedDecoration(tempPed, v.collection, v.nameHash)
				end
			end
		end
	end
end)

local function DrawTattoo(collection, name)
	ClearPedDecorations(tempPed)
	for k, v in pairs(currentTattoos) do
		if v.Count ~= nil then
			for i = 1, v.Count do
				SetPedDecoration(tempPed, v.collection, v.nameHash)
			end
		else
			SetPedDecoration(tempPed, v.collection, v.nameHash)
		end
	end
	for i = 1, opacity do
		SetPedDecoration(tempPed, collection, name)
	end
end

local function ResetSkin()
	TriggerServerEvent("vRPclothes:reloadClothes")
	ClearPedDecorations(tempPed)
	for k, v in pairs(currentTattoos) do
		if v.Count ~= nil then
			for i = 1, v.Count do
				SetPedDecoration(tempPed, v.collection, v.nameHash)
			end
		else
			SetPedDecoration(tempPed, v.collection, v.nameHash)
		end
	end
end

local function ReqTexts(text, slot)
	RequestAdditionalText(text, slot)
	while not HasAdditionalTextLoaded(slot) do
		Citizen.Wait(0)
	end
end

local function OpenTattooShop()
	JayMenu.OpenMenu("tattoo")
	FreezeEntityPosition(tempPed, true)
	ReqTexts("TAT_MNU", 9)
end

local function CloseTattooShop()
	ClearAdditionalText(9, 1)
	FreezeEntityPosition(tempPed, false)
	EnableAllControlActions(0)
	back = 1
	opacity = 1
	ResetSkin()
	return true
end

local function ButtonPress()
	PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
end

local function BuyTattoo(collection, name, label, price)
	vRPserver.purchaseTattoo({currentTattoos, price, {collection = collection, nameHash = name, Count = opacity}, GetLabelText(label)}, function(success)
		if success then
			table.insert(currentTattoos, {collection = collection, nameHash = name, Count = opacity})
		end
	end)
end

local function RemoveTattoo(name, label)
	for k, v in pairs(currentTattoos) do
		if v.nameHash == name then
			table.remove(currentTattoos, k)
		end
	end

	TriggerServerEvent("vRPclothes:removeTattoo", currentTattoos)
end

local function CreateScale(sType)
	if scaleString ~= sType and sType == "Control" then
		scaleType = setupScaleform2("instructional_buttons", "Schimba pozitia camerei", 21, "Schimba opacitatea", {90, 89}, "Cumpara/Scoate tatuajul", 191)
		scaleString = sType
	end
end

Citizen.CreateThread(function()
	JayMenu.CreateMenu("tattoo", "Magazin Tatuaje", function()
        return CloseTattooShop()
    end)

    JayMenu.SetSubTitle('tattoo', "Categorii disponibile")
	
	for k, v in ipairs(tattoosConfig.TattooCats) do
		JayMenu.CreateSubMenu(v[1], "tattoo", v[2])
		JayMenu.SetSubTitle(v[1], v[2])
	end
	
	for _, sLocation in ipairs(tattoosConfig.Shops) do
		tvRP.setArea("_vRP_tattoos:".._, sLocation.x, sLocation.y, sLocation.z, 2, {key = "E", text = "Salon tatuaje"}, function()
			if not IsMenuOpen() then

				if (GVEHICLE == 0) then
					OpenTattooShop()
				end

			end
		end)
    end
    
    while true do 
        Citizen.Wait(0)
		local CanSleep = true

		if IsMenuOpen() then
			DisableAllControlActions(0)
			CanSleep = false
		end
		
        if JayMenu.IsMenuOpened('tattoo') then
			CanSleep = false
            for k, v in ipairs(tattoosConfig.TattooCats) do
				JayMenu.MenuButton(v[2], v[1])
			end
			ClearPedDecorations(tempPed)
			for k,v in pairs(currentTattoos) do
				if v.Count ~= nil then
					for i = 1, v.Count do
						SetPedDecoration(tempPed, v.collection, v.nameHash)
					end
				else
					SetPedDecoration(tempPed, v.collection, v.nameHash)
				end
			end
			if DoesCamExist(cam) then
				DetachCam(cam)
				SetCamActive(cam, false)
				RenderScriptCams(false, false, 0, 1, 0)
				DestroyCam(cam, false)
			end
			JayMenu.Display()
        end
		for k, v in ipairs(tattoosConfig.TattooCats) do
			if JayMenu.IsMenuOpened(v[1]) then
				CanSleep = false
				if not DoesCamExist(cam) then
					cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
					SetCamActive(cam, true)
					RenderScriptCams(true, false, 0, true, true)
					StopCamShaking(cam, true)
				end
				CreateScale("Control")
				DrawScaleformMovieFullscreen(scaleType, 255, 255, 255, 255, 0)
				if IsDisabledControlJustPressed(0, 21) then
					ButtonPress()
					if back == #v[3] then
						back = 1
					else
						back = back + 1
					end
				end
				if IsDisabledControlJustPressed(0, 90) then
					ButtonPress()
					if opacity == 10 then
						opacity = 10
					else
						opacity = opacity + 1
					end
				end
				if IsDisabledControlJustPressed(0, 89) then
					ButtonPress()
					if opacity == 1 then
						opacity = 1
					else
						opacity = opacity - 1
					end
				end
				if GetCamCoord(cam) ~= GetOffsetFromEntityInWorldCoords(tempPed, v[3][back]) then
					SetCamCoord(cam, GetOffsetFromEntityInWorldCoords(tempPed, v[3][back]))
					PointCamAtCoord(cam, GetOffsetFromEntityInWorldCoords(tempPed, v[4]))
				end
				for _, tattoo in pairs(tattoosConfig.AllTattooList) do
					if tattoo.Zone == v[1] then
						if GetEntityModel(tempPed) == 'mp_m_freemode_01' then
							if tattoo.HashNameMale ~= '' then
								local found = false
								for k, v in pairs(currentTattoos) do
									if v.nameHash == tattoo.HashNameMale then
										found = true
										break
									end
								end
								if found then
									local clicked, hovered = JayMenu.SpriteButton(GetLabelText(tattoo.Name), "commonmenu", "shop_tattoos_icon_a", "shop_tattoos_icon_b")
									if clicked then
										RemoveTattoo(tattoo.HashNameMale, tattoo.Name)
									end
								else
									local price = math.ceil(tattoo.Price / 20) == 0 and 100 or math.ceil(tattoo.Price / 20)
									local clicked, hovered = JayMenu.Button(GetLabelText(tattoo.Name), "~HUD_COLOUR_GREENDARK~$" .. price)
									if clicked then
										BuyTattoo(tattoo.Collection, tattoo.HashNameMale, tattoo.Name, price)
									elseif hovered then
										DrawTattoo(tattoo.Collection, tattoo.HashNameMale)
									end
								end
							end
						else
							if tattoo.HashNameFemale ~= '' then
								local found = false
								for k, v in pairs(currentTattoos) do
									if v.nameHash == tattoo.HashNameFemale then
										found = true
										break
									end
								end
								if found then
									local clicked, hovered = JayMenu.SpriteButton(GetLabelText(tattoo.Name), "commonmenu", "shop_tattoos_icon_a", "shop_tattoos_icon_b")
									if clicked then
										RemoveTattoo(tattoo.HashNameFemale, tattoo.Name)
									end
								else
									local price = math.ceil(tattoo.Price / 20) == 0 and 100 or math.ceil(tattoo.Price / 20)
									local clicked, hovered = JayMenu.Button(GetLabelText(tattoo.Name), "~HUD_COLOUR_GREENDARK~$" .. price)
									if clicked then
										BuyTattoo(tattoo.Collection, tattoo.HashNameFemale, tattoo.Name, price)
									elseif hovered then
										DrawTattoo(tattoo.Collection, tattoo.HashNameFemale)
									end
								end
							end
						end
					end
				end
				JayMenu.Display()
			end
		end
		if CanSleep then
			Citizen.Wait(3000)
		end
    end
end)