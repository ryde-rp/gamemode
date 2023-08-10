local swClothingHandler = {
    ["top"] = function()
        ToggleClothing("Shirt", true)
    end,
    ["vest"] = function()
        ToggleClothing("Vest")
    end,
    ["pants"] = function()
        ToggleClothing("Pants", true)
    end,
    ["shoes"] = function()
        ToggleClothing("Shoes")
    end,
    ["hat"] = function()
        ToggleProps("Hat")
    end,
    ["glasses"] = function()
        ToggleProps("Glasses")
    end,
    ["watch"] = function()
        ToggleProps("Watch")
    end,
    ["mask"] = function()
        ToggleClothing("Mask")
    end,
    ["reset"] = function()
        ResetClothing(true)
    end,
}

-- Clothing handler;
local LastEquipped = {};
local function IsMpPed(ped)
    local Male = GetHashKey("mp_m_freemode_01") local Female = GetHashKey("mp_f_freemode_01")
    local CurrentModel = GetEntityModel(ped)
    if CurrentModel == Male then return "Male" elseif CurrentModel == Female then return "Female" else return false end
end

local function PlayToggleEmote(e, cb)
    local Ped = PlayerPedId()
    while not HasAnimDictLoaded(e.Dict) do RequestAnimDict(e.Dict) Wait(100) end
    if IsPedInAnyVehicle(Ped) then e.Move = 51 end
    TaskPlayAnim(Ped, e.Dict, e.Anim, 3.0, 3.0, e.Dur, e.Move, 0, false, false, false)
    local Pause = e.Dur-500 if Pause < 500 then Pause = 500 end
    Wait(Pause) -- Lets wait for the emote to play for a bit then do the callback.
    cb()
end

RegisterCommand("jacheta", swClothingHandler["top"])
RegisterCommand("vesta", swClothingHandler["vest"])
RegisterCommand("pantaloni", swClothingHandler["pants"])
RegisterCommand("papuci", swClothingHandler["shoes"])
RegisterCommand("palarie", swClothingHandler["hat"])
RegisterCommand("ochelari", swClothingHandler["glasses"])
RegisterCommand("masca", swClothingHandler["mask"])
RegisterCommand("ceas", swClothingHandler["watch"])
RegisterCommand("haine", swClothingHandler["reset"])

local function Notify(msg)
    TriggerEvent("vRPnotify", msg)
end

function ToggleProps(which)
    if Cooldown then return end
    local Prop = Props[which]
    local Ped = PlayerPedId()
    local Gender = IsMpPed(Ped)
    local Cur = { -- Lets get out currently equipped prop.
        Id = Prop.Prop,
        Ped = Ped,
        Prop = GetPedPropIndex(Ped, Prop.Prop), 
        Texture = GetPedPropTextureIndex(Ped, Prop.Prop),
    }
    if not Prop.Variants then
        if Cur.Prop ~= -1 then -- If we currently are wearing this prop, remove it and save the one we were wearing into the LastEquipped table.
            PlayToggleEmote(Prop.Emote.Off, function() LastEquipped[which] = Cur ClearPedProp(Ped, Prop.Prop) end) return true
        else
            local Last = LastEquipped[which] -- Detect that we have already taken our prop off, lets put it back on.
            if Last then
                PlayToggleEmote(Prop.Emote.On, function() SetPedPropIndex(Ped, Prop.Prop, Last.Prop, Last.Texture, true) end) LastEquipped[which] = false return true
            end
        end
        Notify("Nimic de scos.", "error") return false
    else
        local Gender = IsMpPed(Ped)
        if not Gender then Notify("Nu poti face asta cu acest ped") return false end -- We dont really allow for variants on ped models, Its possible, but im pretty sure 95% of ped models dont really have variants.
        local Variations = Prop.Variants[Gender]
        for k,v in pairs(Variations) do
            if Cur.Prop == k then
                PlayToggleEmote(Prop.Emote.On, function() SetPedPropIndex(Ped, Prop.Prop, v, Cur.Texture, true) end) return true
            end
        end
        Notify("Nu sunt variante disponibile.", "error") return false
    end
end

function ToggleClothing(which, extra)
    if Cooldown then return end
    local Toggle = Drawables[which] if extra then Toggle = Extras[which] end
    local Ped = PlayerPedId()
    local Cur = { -- Lets check what we are currently wearing.
        Drawable = GetPedDrawableVariation(Ped, Toggle.Drawable), 
        Id = Toggle.Drawable,
        Ped = Ped,
        Texture = GetPedTextureVariation(Ped, Toggle.Drawable),
    }
    local Gender = IsMpPed(Ped)
    if which ~= "Mask" then
        if not Gender then Notify("Caracter invalid", "error") return false end -- We cancel the command here if the person is not using a multiplayer model.
    end
    local Table = Toggle.Table[Gender]
    if not Toggle.Table.Standalone then -- "Standalone" is for things that dont require a variant, like the shoes just need to be switched to a specific drawable. Looking back at this i should have planned ahead, but it all works so, meh!
        for k,v in pairs(Table) do
            if not Toggle.Remember then
                if k == Cur.Drawable then
                    PlayToggleEmote(Toggle.Emote, function() SetPedComponentVariation(Ped, Toggle.Drawable, v, Cur.Texture, 0) end) return true
                end
            else
                if not LastEquipped[which] then
                    if k == Cur.Drawable then
                        PlayToggleEmote(Toggle.Emote, function() LastEquipped[which] = Cur SetPedComponentVariation(Ped, Toggle.Drawable, v, Cur.Texture, 0) end) return true
                    end
                else
                    local Last = LastEquipped[which]
                    PlayToggleEmote(Toggle.Emote, function() SetPedComponentVariation(Ped, Toggle.Drawable, Last.Drawable, Last.Texture, 0) LastEquipped[which] = false end) return true
                end
            end
        end
        Notify("Nu sunt alte variante disponibile.", "warning") return
    else
        if not LastEquipped[which] then
            if Cur.Drawable ~= Table then 
                PlayToggleEmote(Toggle.Emote, function()
                    LastEquipped[which] = Cur
                    SetPedComponentVariation(Ped, Toggle.Drawable, Table, 0, 0)
                    if Toggle.Table.Extra then
                        local Extras = Toggle.Table.Extra
                        for k,v in pairs(Extras) do
                            local ExtraCur = {Drawable = GetPedDrawableVariation(Ped, v.Drawable),  Texture = GetPedTextureVariation(Ped, v.Drawable), Id = v.Drawable}
                            SetPedComponentVariation(Ped, v.Drawable, v.Id, v.Tex, 0)
                            LastEquipped[v.Name] = ExtraCur
                        end
                    end
                end)
                return true
            end
        else
            local Last = LastEquipped[which]
            PlayToggleEmote(Toggle.Emote, function()
                SetPedComponentVariation(Ped, Toggle.Drawable, Last.Drawable, Last.Texture, 0)
                LastEquipped[which] = false
                if Toggle.Table.Extra then
                    local Extras = Toggle.Table.Extra
                    for k,v in pairs(Extras) do
                        if LastEquipped[v.Name] then
                            local Last = LastEquipped[v.Name]
                            SetPedComponentVariation(Ped, Last.Id, Last.Drawable, Last.Texture, 0)
                            LastEquipped[v.Name] = false
                        end
                    end
                end
            end)
            return true
        end
    end
    return false
end

function ToggleProps(which)
    if Cooldown then return end
    local Prop = Props[which]
    local Ped = PlayerPedId()
    local Gender = IsMpPed(Ped)
    local Cur = { -- Lets get out currently equipped prop.
        Id = Prop.Prop,
        Ped = Ped,
        Prop = GetPedPropIndex(Ped, Prop.Prop), 
        Texture = GetPedPropTextureIndex(Ped, Prop.Prop),
    }
    if not Prop.Variants then
        if Cur.Prop ~= -1 then -- If we currently are wearing this prop, remove it and save the one we were wearing into the LastEquipped table.
            PlayToggleEmote(Prop.Emote.Off, function() LastEquipped[which] = Cur ClearPedProp(Ped, Prop.Prop) end) return true
        else
            local Last = LastEquipped[which] -- Detect that we have already taken our prop off, lets put it back on.
            if Last then
                PlayToggleEmote(Prop.Emote.On, function() SetPedPropIndex(Ped, Prop.Prop, Last.Prop, Last.Texture, true) end) LastEquipped[which] = false return true
            end
        end
        Notify("Nimic de scos.", "error") return false
    else
        local Gender = IsMpPed(Ped)
        if not Gender then Notify("Nu poti face asta cu acest ped") return false end -- We dont really allow for variants on ped models, Its possible, but im pretty sure 95% of ped models dont really have variants.
        local Variations = Prop.Variants[Gender]
        for k,v in pairs(Variations) do
            if Cur.Prop == k then
                PlayToggleEmote(Prop.Emote.On, function() SetPedPropIndex(Ped, Prop.Prop, v, Cur.Texture, true) end) return true
            end
        end
        Notify("Nu sunt variante disponibile.", "error") return false
    end
end

function ResetClothing(anim)
    local Ped = PlayerPedId()
    local e = Drawables.Top.Emote
    if anim then TaskPlayAnim(Ped, e.Dict, e.Anim, 3.0, 3.0, 3000, e.Move, 0, false, false, false) end
    for k,v in pairs(LastEquipped) do
        if v then
            if v.Drawable then SetPedComponentVariation(Ped, v.Id, v.Drawable, v.Texture, 0)
            elseif v.Prop then ClearPedProp(Ped, v.Id) SetPedPropIndex(Ped, v.Id, v.Prop, v.Texture, true) end
        end
    end
    LastEquipped = {}
end

RegisterNUICallback('ChangeVariation',function(data)
    ExecuteCommand(data.component)
end)