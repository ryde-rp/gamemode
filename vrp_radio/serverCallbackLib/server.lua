--  ██▓███  ▓█████     ▄▄▄       ██▓ ▄████▄   ██▓    ▄▄▄         ▄▄▄█████▓ ██▀███  ▓█████  ▄████▄   █    ██ ▄▄▄█████▓   ▒███████▒▓█████ ▓█████  ███▄    █ 
--  ▓██░  ██▒▓█   ▀    ▒████▄    ▓██▒▒██▀ ▀█  ▓██▒   ▒████▄       ▓  ██▒ ▓▒▓██ ▒ ██▒▓█   ▀ ▒██▀ ▀█   ██  ▓██▒▓  ██▒ ▓▒   ▒ ▒ ▒ ▄▀░▓█   ▀ ▓█   ▀  ██ ▀█   █ 
--  ▓██░ ██▓▒▒███      ▒██  ▀█▄  ▒██▒▒▓█    ▄ ▒██▒   ▒██  ▀█▄     ▒ ▓██░ ▒░▓██ ░▄█ ▒▒███   ▒▓█    ▄ ▓██  ▒██░▒ ▓██░ ▒░   ░ ▒ ▄▀▒░ ▒███   ▒███   ▓██  ▀█ ██▒
--  ▒██▄█▓▒ ▒▒▓█  ▄    ░██▄▄▄▄██ ░██░▒▓▓▄ ▄██▒░██░   ░██▄▄▄▄██    ░ ▓██▓ ░ ▒██▀▀█▄  ▒▓█  ▄ ▒▓▓▄ ▄██▒▓▓█  ░██░░ ▓██▓ ░      ▄▀▒   ░▒▓█  ▄ ▒▓█  ▄ ▓██▒  ▐▌██▒
--  ▒██▒ ░  ░░▒████▒    ▓█   ▓██▒░██░▒ ▓███▀ ░░██░    ▓█   ▓██▒     ▒██▒ ░ ░██▓ ▒██▒░▒████▒▒ ▓███▀ ░▒▒█████▓   ▒██▒ ░    ▒███████▒░▒████▒░▒████▒▒██░   ▓██░
--  ▒▓▒░ ░  ░░░ ▒░ ░    ▒▒   ▓▒█░░▓  ░ ░▒ ▒  ░░▓      ▒▒   ▓▒█░     ▒ ░░   ░ ▒▓ ░▒▓░░░ ▒░ ░░ ░▒ ▒  ░░▒▓▒ ▒ ▒   ▒ ░░      ░▒▒ ▓░▒░▒░░ ▒░ ░░░ ▒░ ░░ ▒░   ▒ ▒ 
--  ░▒ ░      ░ ░  ░     ▒   ▒▒ ░ ▒ ░  ░  ▒    ▒ ░     ▒   ▒▒ ░       ░      ░▒ ░ ▒░ ░ ░  ░  ░  ▒   ░░▒░ ░ ░     ░       ░░▒ ▒ ░ ▒ ░ ░  ░ ░ ░  ░░ ░░   ░ ▒░
--  ░░          ░        ░   ▒    ▒ ░░         ▒ ░     ░   ▒        ░        ░░   ░    ░   ░         ░░░ ░ ░   ░         ░ ░ ░ ░ ░   ░      ░      ░   ░ ░ 
--              ░  ░         ░  ░ ░  ░ ░       ░           ░  ░               ░        ░  ░░ ░         ░                   ░ ░       ░  ░   ░  ░         ░ 
--                                   ░                                                     ░                             ░                                 

radio={}
radio.ServerCallbacks={}


RegisterServerEvent('radio:triggerServerCallback')
AddEventHandler('radio:triggerServerCallback',function(a,b,...)
    local c=source

    radio.TriggerServerCallback(a,requestID,c,function(...)
        TriggerClientEvent('radio:serverCallback',c,b,...)end,...)
    end)
        
        
    
radio.RegisterServerCallback = function(a,t)
    radio.ServerCallbacks[a]=t 
end
                    
radio.TriggerServerCallback = function(a,b,source,t,...)
    if radio.ServerCallbacks[a]~=nil then 
        radio.ServerCallbacks[a](source,t,...)
    else 
        print('TriggerServerCallback => ['..a..'] does not exist')
    end 
end