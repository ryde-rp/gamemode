local protectedClientEvents = {
    ["vRP:onJobChange"] = {["vrp"] = true},
    ["fp-inventory:refreshDrops"] = {["vrp"] = true, ["fairplay-inventory"] = true},
    ["fp-jail:setState"] = {["vrp"] = true},
    ["vRP:setDealershipConfig"] = {["vrp"] = true},
}
  
RegisterServerEvent("vRP:onEventTriggered", function(eventName, inResource)
    local protectionData = protectedClientEvents[eventName]
    local user_id = vRP.getUserId(source)
    local theResource = tostring(inResource)
  
    if protectionData then
      if not protectionData[theResource] then
        vRP.banPlayer(0, user_id, -1, "Trigger Detected [res: "..theResource.."][e: "..eventName.."]")
      end
    end
end)