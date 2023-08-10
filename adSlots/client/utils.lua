---@diagnostic disable: undefined-global
Utils = {}

InsideButton = false

local DrawSprite, DrawRect = DrawSprite, DrawRect

local random = math.random
local GetGameTimer = GetGameTimer
local decorate = function(f)
    return function()
        math.randomseed(GetGameTimer())
        return f()
    end
end
random = decorate(random)

function Utils.drawSubtitleText(m, t, font)
    ClearPrints()
    SetTextEntry_2"STRING"
    SetTextFont(font)
    AddTextComponentString(m)
    DrawSubtitleTimed(t, 1)
end


function Utils.shuffle(t)
    local rtn = {}
    for i = 1, #t do
      local r = math.random(i)
      if r ~= i then
        rtn[i] = rtn[r]
      end
      rtn[r] = t[i]
    end
    return rtn
  end
  

function Utils.random(a, b)
    if not a then a, b = 0, 1 end
    if not b then b = 0 end
    return math.floor(a + random() * (b - a))
end


function Utils.Rainbow(freq)
    local result <const> = {}
    local curtime <const> = GetGameTimer() / 1000
    result.r = math.floor( math.sin( curtime * freq + 0 ) * 127 + 128 )
    result.g = math.floor( math.sin( curtime * freq+ 2 ) * 127 + 128 )
    result.b = math.floor( math.sin( curtime * freq + 4 ) * 127 + 128 )
    return result
end

function Utils.drawTxt(x,y,scale,text,r,g,b,a,font)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextCentre(1)
    SetTextOutline()
    SetTextEntry"STRING"
    AddTextComponentString(text)
    DrawText(x - 0.0/2, y - 0.0/2 + 0.005)
end

Utils.Container = {}
Utils.Container.__index = Utils.Container


function Utils.Container:draw(x,y)
    if self.active then 
        DrawRect((x or self.x),(y or self.y),self.width, self.height, self.color[1], self.color[2], self.color[3], self.color[4])
        if self.displaySprite then 
      --  Utils.drawTxt(self.x,self.y, .5, self.idx, 255,255,255,255)
           DrawSprite(self.sprite,self.sprite,self.x,self.y,.06,self.width,.0, 255,255,255,255)
        end

    end
end

Utils.Container.__call = Utils.Container.draw

function Utils.Container:setActive(boolean)
    self.active = boolean
    return self
end

function Utils.Container:setIndex(idx)
        self.idx = idx
end

function Utils.Container:getSprite()
    return self.sprite
end

function Utils.Container:getPosition()
    return self.idx
end

function Utils.Container:remove()
    self.active = false; self = nil
end

function Utils.Container:setSprite(sprite)
    self.sprite = sprite
end


function Utils.Container:offset(ax)
    self.x = ax.x + self.x; self.y = ax.y + self.y
end

function Utils.Container:dump()
    print("SPRITE: " .. self.sprite )
    for key,value in pairs(self) do 
        print(key, value)
    end
end

function Utils.Container:set( ... )
    local t = ...
    for key in pairs(self) do 
        if t[key] then 
            self[key] = t[key]
        end
    end
    print(self.color[1])
end

function Utils.Container:spriteToggle(boolean)
    self.displaySprite = boolean
end

function Utils.Container.new(x,y,width,height,sprite,color,active)
    return setmetatable({width = width, displaySprite = active, height = height, active = active, x = x, y = y , sprite = sprite, color = color, draw = Utils.Container.draw}, Utils.Container)
end

Utils.Button = {}
Utils.Button.__index = Utils.Button

local function isCursorInPosition(x,y,width,height)
	local sx, sy = GetActiveScreenResolution()
    local cx, cy = GetNuiCursorPosition ( )
    local cx, cy = (cx / sx), (cy / sy)
  
    local width = width / 2
    local height = height / 2
        
    if (cx >= (x - width) and cx <= (x + width)) and (cy >= (y - height) and cy <= (y + height)) then
        return true
    else
        return false
    end
end

function Utils.Button:setActive(bool)
    self.active = bool
    return self
end

function Utils.Button:setCallback(cb)
    self.cb = cb
end

function Utils.Button:delete()
    self.active = false; self = nil 
end


function Utils.Button:draw()
    if self.active then 
        if (isCursorInPosition(self.display.x,self.display.y, self.background.width , self.background.height )) then 
             self.inside = true 
             SetCursorSprite(5)
             if (IsDisabledControlJustPressed(0,24)) then 
                self.cb()
            end
        else
            if self.inside then SetCursorSprite(1); self.inside = false  end
        end

        if self.background.show then 
            DrawRect(self.x,self.y,self.background.width, self.background.height, self.background.color[1], self.background.color[2], self.background.color[3], self.background.color[4])
        end
      
        Utils.drawTxt(self.display.x,self.display.y, self.display.scale, self.display.text, self.display.r, self.display.g, self.display.b, self.display.a, self.display.font )
    end
   
end




function Utils.Button.new (display,x,y,background, start, cb )
    assert(type(cb) == 'function')
    local retInstance <const> = setmetatable({ zIndex = 1, display = display, text = text, x = x, y = y,background = background, cb = cb, active = start , draw = Utils.Button.draw},{__index = Utils.Button, __call = Utils.Button.draw})
    return retInstance
end

Utils.Buttons = { 

    exitButton = Utils.Button.new({
                text = SlotsConfig.UIConfig.exitText,
                r = 255, g = 0, b = 0, a = 170,
                font = 7,
                x = .27, 
                y = .68,
                scale = .4 },
                .27,.7, { width = 0.03, height = 0.038, color = {91, 176, 144,154 }, show = true  }, true, function() end),

    playButton = Utils.Button.new({
        text = SlotsConfig.UIConfig.playText,
        r = 0, g = 255, b = 0, a = 130,
        font = 7,
        x = .485, 
        y = .68,
        scale = .5
    },   .485,.698, { width = 0.053, height = 0.060, color = {91, 176, 144,154 }, show = true }, true, function() end),

    raisePot = Utils.Button.new({
        text = '+',
        r = 0, g = 255, b = 0, a = 130,
        font = 7,
        x = .566, 
        y = .795,
        scale = .9
    },   .47,.755, { width = 0.053, height = 0.060, color = {91, 176, 144,154 }, show = false }, true, function() end),
    
    decreasePot = Utils.Button.new({
        text = '-',
        r = 255, g = 0, b = 0, a = 130,
        font = 7,
        x = .39, 
        y = .795,
        scale = .9
    },   .47,.755, { width = 0.053, height = 0.038, color = {91, 176, 144,154 }, show = false }, true, function() end),

    gamble = Utils.Button.new({
        text = '~p~gamble',
        r = 255, g = 255, b = 255, a = 255,
        font = 7,
        x = .28, 
        y = .810,
        scale = .5
    },  .28,.830, { width = 0.053, height = 0.050, color = {0, 255, 81,60 }, show = true }, false, function() end),

   blackButton =  Utils.Button.new({
        text = 'Negru',
        r = 255, g = 255, b = 255, a = 255,
        font = 7,
        x = .41, 
        y = .61,
        scale = .35 },
        .41,.63, { width = 0.05, height = 0.048, color = {0,0,0,200 }, show = true  }, false, function() end),

    redButton =  Utils.Button.new({
            text = 'Rosu',
            r = 255, g =255, b = 255, a = 255,
            font = 7,
            x = .56, 
            y = .61,
            scale = .35 },
            .56,.63, { width = 0.05, height = 0.048, color = {255,0,0,150 }, show = true  }, false, function() end),

    cashOutButton =  Utils.Button.new({
                text = 'Incaseaza castiguri',
                r = 255, g =255, b = 255, a = 255,
                font = 7,
                x = .485, 
                y = .675,
                scale = .35 },
                .485,.688, { width = 0.1, height = 0.048, color = {0,255,0,150 }, show = true  }, false, function() end),
    
};
function Utils.Buttons.hide(boolean)
    for k in pairs(Utils.Buttons) do 
        if k ~= 'hide' then 
            Utils.Buttons[k]:setActive(not boolean)
        end
    end
end

setmetatable(Utils.Buttons, {__call = function()
    for _,v in pairs(Utils.Buttons) do 
        if _ ~= 'hide' then
            v()
        end
    end
end})

function Utils.getRandomValueFromTable(t)
    assert(type(t) == 'table')
    local count = 0 
    for _ in pairs(t) do count = count + 1 end
    return t[math.random(count)]
end

