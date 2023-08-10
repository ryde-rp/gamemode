local lastBag = ""
local bagsData = {
  ["Borseta"] = {
    ["male"] = {
      component = 7,
      drawable = 43,
      texture = 1,
      default = 15,
    },

    ["female"] = {},
  },

  ["Ghiozdan Mic"] = {
    ["male"] = {
      component = 5,
      drawable = 1,
      texture = 0,
      default = 0,
    },

    ["female"] = {
      component = 5,
      drawable = 7,
      texture = 0,
      default = 0,
    },
  },

  ["Geanta"] = {
    ["male"] = {
      component = 5,
      drawable = 91,
      texture = 0,
      default = 0,
    },

    ["female"] = {
      component = 5,
      drawable = 82,
      texture = 0,
      default = 0,
    },
  },

  ["Ghiozdan Mediu"] = {
    ["male"] = {
      component = 5,
      drawable = 11,
      texture = 0,
      default = 0,
    },

    ["female"] = {
      component = 5,
      drawable = 6,
      texture = 0,
      default = 0,
    },
  },
  
  ["Ghiozdan Mare"] = {
    ["male"] = {
      component = 5,
      drawable = 5,
      texture = 0,
      default = 0,
    },

    ["female"] = {
      component = 5,
      drawable = 5,
      texture = 0,
      default = 0,
    },
  },
}

RegisterNetEvent("vRP:setBackpackProp", function(theBag)
  local pedType = IsPedMale(tempPed) and "male" or "female"

  if type(theBag) == "boolean" then
    return SetPedComponentVariation(tempPed, bagsData[lastBag][pedType].component, bagsData[lastBag][pedType].default, 0, 0)
  end

  local bagData = bagsData[theBag][pedType]
  lastBag = theBag

  SetPedComponentVariation(tempPed, bagData.component, bagData.drawable, bagData.texture, 1)
end)