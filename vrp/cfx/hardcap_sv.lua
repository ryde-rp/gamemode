-- local playerCount = 0
-- local list = {}

-- RegisterServerEvent('hardcap:playerActivated')

-- AddEventHandler('hardcap:playerActivated', function()
--   if not list[source] then
--     playerCount = playerCount + 1
--     list[source] = true
--   end
-- end)

-- AddEventHandler('playerDropped', function()
--   if list[source] then
--     playerCount = playerCount - 1
--     list[source] = nil
--   end
-- end)

-- AddEventHandler('playerConnecting', function(name, setReason)
--   local cv = GetConvarInt('sv_maxclients', 32)
--   if playerCount >= cv then
--     setReason('Salutare! Serverul nostru a atins limita de jucatori, prin urmare suntem nevoiti sa iti respingem conectarea, insa, te poti reconecta pentru a astepta in Queue.')
--     CancelEvent()
--   end
-- end)
