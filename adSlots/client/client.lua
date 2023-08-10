---@diagnostic disable: undefined-global, lowercase-global
do return (function ()

    local setmetatable,pairs,GetGameTimer = setmetatable,pairs,GetGameTimer

    local inGame,inside = false,false
    local Citizen, PlayerPedId, GetEntityCoords, DrawMarker = _G['Citizen'], PlayerPedId, GetEntityCoords, DrawMarker
    local remoteSlots <const> , remoteServerSlots <const> = {}, Tunnel.getInterface('rydeSlots','rydeSlots')

    local pot = SlotsConfig.minMaxPot.min

    local T_REF = nil

    local CARD_SPRITE = 'card'

    local colorTable = { 255,0,0,130 }

    local inGamble = false

    local red = false

    local gambles = 0
    local BOTTOM_TEXT,BOTTOM_TEXT_LOCKED = '',false

    local texCache = {}; for name in pairs(TEXTURES) do if name ~= 'black' and name ~= 'red' then  table.insert(texCache,name) end end;

    local function exit()
        inside = false 
        inGame = false
        Utils.Buttons['exitButton']:setActive(true) 
        Utils.Buttons['raisePot']:setActive(true)
        Utils.Buttons['decreasePot']:setActive(true)
        AnimpostfxStop('FocusOut')   
        FreezeEntityPosition(PlayerPedId(),inside)
        inGamble = false 
        Utils.Buttons['gamble']:setActive(false)
    end

    local function shuffleSlots(slotsMatrix, ... )
            local t = {...}
            if t[1] then 
                for i = 1, #t do 
                    slotsMatrix[t[i]].instance:spriteToggle(true)
                    Citizen.Wait(150)
                end
                else
                    for _,v in pairs(slotsMatrix) do 
                        local v = v.instance or {}
                        v.sprite = Utils.getRandomValueFromTable(texCache)
                    end
            end
        end


        local function cashOut(rollId,sum,money,ignore)
            if not ignore and gambles == 0 then return end
            if money ~= nil then 
                remoteServerSlots.cashOut{rollId,sum}
            end
            inGamble = false 
            Utils.Buttons.hide(false)
            Utils.Buttons['blackButton']:setActive(false)
            Utils.Buttons['redButton']:setActive(false)
            Utils.Buttons['cashOutButton']:setActive(false)
            Utils.Buttons['gamble']:setActive(false)
            BOTTOM_TEXT_LOCKED = false
            gambles = 0
    
            pot = SlotsConfig.minMaxPot.min
        
            for _, slot in pairs(slots) do slot.instance:setActive(true) end
        end
    
    local function pickColor(color,sum)
        math.randomseed(GetGameTimer())
        local result = math.random(2)
        if result == 1 then 
            CARD_SPRITE = color .. 'Card'
            BOTTOM_TEXT_LOCKED = true 
            BOTTOM_TEXT = '~w~ai castigat: ~g~' .. FormatMoney(sum)
            pot = sum * 2
            Citizen.SetTimeout(1000, function() BOTTOM_TEXT = 'Miza: ~g~' .. pot ..'~n~~w~Miza Gamble: ~g~' .. FormatMoney(pot * 2) end)
        else
            cashOut(nil,nil,nil,true)
            remoteServerSlots.removeMoney{pot}
        end


        return result == 1

    end

 
    function gambleWinnings(slotsMatrix,sum,rollId)
 
 
        inGamble = true
        local possibleWinSum = (sum * gambles) * 2
        BOTTOM_TEXT_LOCKED = true 
        BOTTOM_TEXT = 'Miza: ~g~' ..sum * gambles ..'~n~~w~Miza Gamble: ~g~' .. FormatMoney(possibleWinSum)
     
     
        Utils.Buttons.hide(true)

        for _, slot in pairs(slotsMatrix) do slot.instance:setActive(false) end
        SetCursorSprite(1)

        Utils.Buttons['blackButton']:setActive(true):setCallback(function()
            if gambles >= 5 then return Utils.drawSubtitleText('~r~Poti juca la carti de maxim 5 ori',3000,1) end;
            local number = sum * gambles; if number == 0 then number = sum end
            if pickColor("black",number) then 
                    gambles = gambles + 1
                    pot = sum * gambles
            end
        
        end)
        Utils.Buttons['redButton']:setActive(true):setCallback(function()
            if gambles >= 5 then return Utils.drawSubtitleText('~r~Poti juca la carti de maxim 5 ori',3000,1) end;
            local number = sum * gambles; if number == 0 then number = sum end
            if pickColor("red",number) then 
                    gambles = gambles + 1
                    pot = sum * gambles
            end
             
        end)
        Utils.Buttons['cashOutButton']:setActive(true):setCallback(function() cashOut(rollId,pot,true) end)

    end


    local function startRolling(slotsMatrix)
        if inGame then return end
        if pot > SlotsConfig.minMaxPot.max or pot < SlotsConfig.minMaxPot.min then return Utils.drawSubtitleText(SlotsConfig.minMaxPot.text,3000,1) end 
        red = false
        remoteServerSlots.setPot{pot}

        for k,v in pairs(slotsMatrix) do v.instance:spriteToggle(false) end

        Utils.Buttons['gamble']:setCallback(function()  end)
        Utils.Buttons['gamble']:setActive(false)
   
        Utils.Buttons['exitButton']:setActive(false)
        Utils.Buttons['raisePot']:setActive(false)
        Utils.Buttons['decreasePot']:setActive(false)
        inGame = true 
                    
        local p = promise.new()
        remoteServerSlots.startRolling({}, function (id) p:resolve(id) end)
        local rollId = Citizen.Await(p)  

        local GRID_SPRITES = { {1,5,10}, { 2,6,11 }, {3,7,12}, {4,8,13}, {15,9,14}  }

        Citizen.CreateThread(function()
            for i = 1, #GRID_SPRITES do
                shuffleSlots(slotsMatrix,GRID_SPRITES[i][1],GRID_SPRITES[i][2],GRID_SPRITES[i][3])
                Citizen.Wait(120)
            end

            BOTTOM_TEXT_LOCKED = true 
            remoteServerSlots.finishRoll({rollId,slotsMatrix,pot}, function(win,sum)
                
                        
                inGame = false
                if win then 
                    red = true 
                    BOTTOM_TEXT_LOCKED = true
                    sum = tonumber(sum)
                    Utils.Buttons['gamble']:setCallback(function() gambleWinnings(slotsMatrix,sum, rollId) end)
                    Utils.Buttons['gamble']:setActive(true)
                    BOTTOM_TEXT = '~w~ai castigat:~g~ ' .. FormatMoney(sum) .. '$'
                    Citizen.CreateThread(function() while not inGame and inside do Citizen.Wait(50) end BOTTOM_TEXT_LOCKED = false; red= false end)
                else
                    Utils.Buttons['exitButton']:setActive(true)
                    Utils.Buttons['raisePot']:setActive(true)
                    Utils.Buttons['decreasePot']:setActive(true)
                end
                
             
            end)
    
        end)

        for i = 1, 30 do shuffleSlots(slotsMatrix) end
    end

    remoteSlots.setBottomText = function(text)
        BOTTOM_TEXT_LOCKED = true 
        BOTTOM_TEXT = text
        Citizen.CreateThread(function () while not inGame and inside do Citizen.Wait(50) end BOTTOM_TEXT_LOCKED = false end)
    end

    remoteSlots.highlightWinningMatrix = function(slotsMatrix,patternMatrix)
        Utils.Buttons['exitButton']:setActive(true)
        red = true
        local colored = {}
        local length = #slotsMatrix
        colorTable = { 255,0,0,130 }

        for i = 1, length do
            for _, slot in pairs(patternMatrix[1]) do
                if slot.idx == i then 
                    T_REF[i].instance.color = colorTable
                    colored[#colored+1] = i
                end
            end
        end
       
    Citizen.CreateThread(function() while not inGame and inside and red do Citizen.Wait(50) end  colorTable = { 0,0,0,130 } for i = 1, #colored do T_REF[colored[i]].instance.color = colorTable end  end)
    end; Tunnel.bindInterface('rydeSlots',remoteSlots)


    function getSlotsMatrix()
        math.randomseed(GetGameTimer())

        local stop <const> = SlotsConfig.rows * SlotsConfig.columns
        TEXTURE_LIST = {}

        for i = 1, SlotsConfig.columns * SlotsConfig.rows do 
            TEXTURE_LIST[#TEXTURE_LIST+1] = Utils.getRandomValueFromTable(texCache)
        end

        setmetatable(TEXTURES, { __mode = 'v'} )
 
        local dimensions = { height = .11, width = .07 }
 
        local slots = { }
        T_REF = slots
     
        for i = 1, stop, 1 do 
            slots[i] = {instance = Utils.Container.new(.0,.35,dimensions.width,dimensions.height,TEXTURE_LIST[i], { 0,0,0,130 }, true), data = { guard = '0x559b828c4d80' } }
        end
        local yOffset = .35
        local xOffset = .1
        for i = 1, stop do 
            slots[i].instance:setIndex(i)
            if i % SlotsConfig.rows == 0 then 
                xOffset = .16 + .10
            end
            xOffset = xOffset + .075
            slots[i].instance.x = xOffset
        
        end
        for i = 1, stop do 
            if i % SlotsConfig.rows == 0 then 
                yOffset = yOffset + .12
                slots[i].instance.y = yOffset
                for j = i + 1, stop do 
                    if j % SlotsConfig.rows == 0 then break end
                    slots[j].instance.y = yOffset
                end 
            end
        end
        

        
        slots[15].instance.y = .35 slots[1].instance.x = .235 + .10 slots[2].instance.x = .31 + .10 slots[3].instance.x = .385 + .10 slots[4].instance.x = .46 + .10; slots[15].instance.x = .535 + .10
        return setmetatable(slots, { __call = function() 
            for _,v in pairs(slots) do 
                v.instance()
            end
        end}), function() CreateThread(function() startRolling(slots) end) end
    
    end

    local function handleInside()
        inside = true
        FreezeEntityPosition(PlayerPedId(),inside)
        AnimpostfxPlay('FocusOut', 1000, true)
        local UIConfig = SlotsConfig.UIConfig

        Utils.Buttons['exitButton']:setCallback(exit)
        Utils.Buttons['raisePot']:setCallback(function()
            local new = pot + SlotsConfig.raiseNumber
            if new > SlotsConfig.minMaxPot.max then return Utils.drawSubtitleText(SlotsConfig.minMaxPot.text,3000,1) end  
            pot = SlotsConfig.raiseNumber + pot
        end)

        Utils.Buttons['decreasePot']:setCallback(function()
            local new = pot - SlotsConfig.decreaseNumber
            if new < SlotsConfig.minMaxPot.min then return Utils.drawSubtitleText(SlotsConfig.minMaxPot.text,3000,1) end  
            pot = pot - SlotsConfig.decreaseNumber
        end)

        slots,roll = getSlotsMatrix()
        T_REF = slots

        Utils.Buttons['playButton']:setCallback(roll)


        Citizen.CreateThread(function()
            while inside do
                if not BOTTOM_TEXT_LOCKED then 
                    BOTTOM_TEXT = SlotsConfig.UIConfig.potText:format('~g~' .. FormatMoney(pot))
                end

                if not inGamble then 
                    Utils.Buttons()
                end
                
                Utils.drawTxt(.48,.8,.8,BOTTOM_TEXT, 255, 255 ,255 ,255, 7)
                SetMouseCursorActiveThisFrame()
                DisableControlAction(1,177,true) DisableControlAction(0,24,true) DisableControlAction(0, 1, true) DisableControlAction(0, 2, true) DisableControlAction(0, 142, true) DisableControlAction(0, 106, true)
                if ( inGame == false and not inGamble and IsDisabledControlJustPressed(1,177)) then exit() break end

                Utils.drawTxt(.48, .23, .8, SlotsConfig.serverName, 73, 152, 227,255,1)

                if (inGame == false and not inGamble and IsControlJustPressed(1,55)) then roll() end


                DrawRect(.5, .48, .5, .5, UIConfig.backgroundColor[1],UIConfig.backgroundColor[2],UIConfig.backgroundColor[3],UIConfig.backgroundColor[4])
             
                slots()

                if inGamble then 
                    Utils.Buttons()
                    DrawSprite(CARD_SPRITE,CARD_SPRITE,.487,.45,.12,.2,.0, 255,255,255,255)
                end

                Citizen.Wait(0)
            end
            slots = nil
        end)
    end


    Citizen.CreateThread(function()
        while true do 
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            for _, pos in pairs(SlotsConfig.xyz) do 
                local dist = ( #(coords - pos) )
                if (dist <= 5.0 and not inside) then
                    ticks = 1
                    DrawMarker(29, pos[1],pos[2],pos[3] - .5, .0,.0,.0, .0 , .0, .0, 1.1, 1.1, 1.1, 0, 255, 0, 255,  1 , 0 ,0 ,1 )
                    dist =  ( #(coords -pos) )
                    if dist <= 1.5 then
                        ticks = 1
                        SetTextComponentFormat"STRING"; AddTextComponentString(SlotsConfig.enterText); DisplayHelpTextFromStringLabel(0, 0, 1, -1)
                        if IsControlJustPressed(SlotsConfig.enterKey[1], SlotsConfig.enterKey[2]) then handleInside() end
                    end
                end
            end
            Citizen.Wait(ticks)
            ticks = 1000
        end
    end)
    
end)() end
