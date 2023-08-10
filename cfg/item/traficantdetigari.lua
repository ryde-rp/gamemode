local items = {}

items["fp_filtre"] = {
  name = "Filtre Tigari",
  description = "Aceste filtre se folosesc pentru producerea tigarilor de contrabanda.",
  choices = function() end,
  weight = 0.02,
}

items["fp_foite"] = {
  name = "Foite Tigari",
  description = "Aceste foite se folosesc pentru producerea tigarilor de contrabanda.",
  choices = function() end,
  weight = 0.02,
}

items["fp_tigara"] = {
  name = "Tigara",
  description = "Aceste tigara se foloseste pentru a completa pachetel de tigari de contrabanda.",
  choices = function() end,
  weight = 0.01,
}

items["fp_tutun_procesat"] = {
  -- name = "Tutun Procesat",
  name = "Tutun",
  description = "Acest tutun se foloseste pentru a produce tigari de contrabanda.",
  choices = function() end,
  weight = 0.02,
}

items["fp_frunza_tutun_uscat"] = {
  name = "Frunza de Tutun Uscata",
  description = "Aceasta frunza o poti folosii pentru a face Tutun Procesat.",
  choices = function() end,
  weight = 0.1,
}

items["fp_frunza_tutun"] = {
  name = "Frunza de Tutun",
  description = "Aceasta frunza o vei pune la uscat pentru a face Frunza de Tutun Uscata.",
  choices = function() end,
  weight = 0.5,
}
return items