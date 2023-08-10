---@diagnostic disable: undefined-global
SlotsConfig = {}

FormatMoney = function(amount)
	local left,num,right = string.match(tostring(amount),'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

SlotsConfig.WinPatterns = {
    -- 5X3 GRID ( 15 TOTAL )
    {1,2,3},
    {1,2,3,4,15},

    {1,2,3,4},
    {5,6,7},
    {5,6,7,8},
    {5,6,7,8,9},
    {10,11,12},
    {10,11,12,13},
    {10,11,12,13,14},
    {1,6,12},
    {1,6,12,8,15}



}

SlotsConfig.serverName = '~HUD_COLOUR_PURPLE~Ryde Romania'

SlotsConfig.xyz = {
    vector3(972.67877197266,52.31827545166,74.476188659668),
    vector3(977.25390625,54.684638977051,74.476272583008),
    vector3(981.73400878906,52.750949859619,74.476272583008),
    vector3(981.82391357422,47.14123916626,74.476295471191),
    vector3(986.26324462891,47.594844818115,74.476295471191)

}
SlotsConfig.enterText = '~w~Apasa [~g~E~w~] pentru a deschide meniul'
SlotsConfig.enterKey = {1,51}

SlotsConfig.minMaxPot = {min = 500000, max = 20000000 }
SlotsConfig.minMaxPot.text =  'Miza trebuie sa fie intre ~g~' .. FormatMoney(SlotsConfig.minMaxPot.min) .. '$~w~ si ~g~' .. FormatMoney(SlotsConfig.minMaxPot.max) .. '$~w~ !'

SlotsConfig.raiseNumber = 1000
SlotsConfig.decreaseNumber = 1000

SlotsConfig.rows = 5
SlotsConfig.columns = 3

SlotsConfig.UIConfig = {
    backgroundColor = {69, 88, 230,70},
    potText = 'Miza: %s',
    playText = 'joaca',
    exitText = 'exit'

}

SlotsConfig.blipConfig = { 

    blipSprite = 679,
    blipColor = 69,
    blipScale = .8,
    blipName = 'Slots'

 }

SlotsConfig.hackerDropText = '[rydeSlots] Afara'
