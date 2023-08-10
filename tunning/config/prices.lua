Config = Config or {}

-- The vehicle price will be the first option and will change the upgrades price 
Config.VehicleOverridePrice = {}


-- If a is not included in "Config.VehicleOverridePrice" then price of the vehicle will be as the class
Config.VehicleClassPrice = {
    ['0'] = 100000, -- Compacts
    ['1'] = 150000, -- Sedans
    ['2'] = 200000, -- SUVs
    ['3'] = 150000, -- Coupes
    ['4'] = 250000, -- Muscle
    ['5'] = 250000, -- Sports Classics
    ['6'] = 200000, -- Sports
    ['7'] = 350000, -- Super
    ['8'] = 200000, -- Motorcycles
    ['9'] = 150000, -- Off-road
    ['10'] = 100000, -- Industrial
    ['11'] = 100000, -- Utility
    ['12'] = 100000, -- Vans
    ['13'] = 1000, -- Cycles
    ['14'] = 100000, -- Boats
    ['15'] = 500000, -- Helicopters
    ['16'] = 500000, -- Planes
    ['17'] = 100000, -- Service
    ['18'] = 100000, -- Emergency
    ['20'] = 100000 -- Commercial
}

-- If a is not included in "Config.VehicleOverridePrice" and the class of the vehicle is not included in the "Config.VehicleClassPrice" the price will be as the "Config.VehicleDefaultPrice"
Config.VehicleDefaultPrice = 200000


-- The price of the repair for the points with whitelist job (for the open points the "Config.PriceMultiplierWithoutTheJob" multiplier will apply)
Config.VehicleRepairPrice = 1000

-- The multiplier of parts for the points with whitelist job (for the open points the "Config.PriceMultiplierWithoutTheJob" multiplier will add to that)
Config.VehicleCustomisePriceMultiplier = {
    ['engine'] = {5.0, 6.0, 8.0, 10.5, 14.0, 17.0},
    ['brakes'] = {5.0, 6.0, 8.0, 10.5, 14.0},
    ['transmission'] = {5.0, 6.0, 8.0, 10.5, 14.0},
    ['suspension'] = {1.0, 3.0, 3.5, 4.0, 10.00, 10.0, 10.0},
    ['armor'] = {1.0, 4.0, 4.5, 5.0, 5.5, 6.0, 6.0, 6.0},
    ['turbo'] = {1.0, 10.0},

    ['extras'] = 5.0,
    ['windowTint'] = 0.3,

    ['horn'] = 35.00,
    ['speakers'] = 1.0,
    ['trunk'] = 1.0,
    ['hydrulics'] = 3.00,
    ['engine_block'] = 2.00,
    ['air_filter'] = 150.000,
    ['struts'] = 1.0,
    ['tank'] = 1.0,

    ['spoilers'] = 1.50,
    ['front_bumper'] = 2.00,
    ['rear_bumper'] = 2.00,
    ['side_skirts'] = 1.50,
    ['exhaust'] = 2.50,
    ['cage'] = 1.50,
    ['grille'] = 1.00,
    ['hood'] = 2.00,
    ['left_fender'] = 1.00,
    ['right_fender'] = 1.00,
    ['roof'] = 2.00,
    ['arch_cover'] = 1.00,
    ['aerials'] = 1.00,
    ['wings'] = 1.50,
    ['windows'] = 0.50,

    ['dashboard'] = 1.50,
    ['dashboard_color'] = 1.0,
    ['dial'] = 0.20,
    ['door_speaker'] = 1.00,
    ['seat'] = 1.00,
    ['steering_wheel'] = 1.00,
    ['shifter_leaver'] = 1.00,
    ['ornaments'] = 0.9,
    ['interior'] = 1.00,
    ['plaques'] = 1.00,
    ['interior_color'] = 1.0,

    ['primary_paint'] = 1.12,
    ['secondary_paint'] = 0.66,
    ['primary_paint_type'] = 1.0,
    ['secondary_paint_type'] = 1.0,
    ['pearlescent'] = 0.88,

    ['wheels_color'] = 0.66,
    ['smoke_color'] = 1.12,

    ['sport'] = 20.00,
    ['muscle'] = 15.00,
    ['lowrider'] = 25.00,
    ['suv'] = 13.00,
    ['offroad'] = 30.00,
    ['tuner'] = 55.00,
    ['bike_wheels'] = 65.00,
    ['high_end'] = 65.00,
    ['bennys_original'] = 65.00,
    ['bennys_bespoke'] = 35.00,
    ['open_wheel'] = 25.00,
    ['street'] = 26.00,

    ['plate_type'] = 1.1,
    ['plate_color'] = 1.1,
    ['plate_holder'] = 3.49,

    ['xenon'] = 6.5,
    ['neon'] = 5.5,

    ['stickers'] = 5.0,
    ['livery'] = 6.0
}
