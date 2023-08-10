---@diagnostic disable: undefined-global
TEXTURES = { 
    ['black'] = 'black',
    ['lemon'] = 'lemon', 
    ['cherry'] = 'cherry', 
    ['plum'] = 'plum',
    ['seven'] = 'seven',
    ['watermelon'] = 'watermelon',
    ['red'] = 'red', 
    ['orange'] = 'orange', 
    ['grapes'] = 'grapes',
}

coroutine.wrap(function()
    for name in pairs(TEXTURES) do 
        local txd <const> = CreateRuntimeTxd(name)
        CreateRuntimeTextureFromImage(txd, name, ("txds/%s.png"):format(name))
    end

    local name = 'card' local txd <const> = CreateRuntimeTxd(name) CreateRuntimeTextureFromImage(txd, name, ("txds/%s.png"):format(name)) local name = 'blackCard' local txd <const> = CreateRuntimeTxd(name) CreateRuntimeTextureFromImage(txd, name, ("txds/%s.png"):format(name)) local name = 'redCard' local txd <const> = CreateRuntimeTxd(name) CreateRuntimeTextureFromImage(txd, name, ("txds/%s.png"):format(name))

end)()
