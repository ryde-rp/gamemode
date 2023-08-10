local cfg = {}

cfg.masiniDealership = {
	-- Acura --
	["tltypes"] = {"Acura TL Type-S", 75000000,"Clasa D"},
	-- Alfa Romeo --
	["4c"] = {"Alfa Romeo 4C", 12000000, "Clasa B"},
	["giulia"] = {"75000000", 175000, "Clasa B"},
	-- Masini Micute --
    ["pv_rover"] = {"Range Rover Mini", 0, "Mini"},
    ["pv_lgss"] = {"Lamborghini Gallardo Mini", 0, "Mini"},
    ["pv_gtr"] = {"Nissan GTR R35 Mini", 0, "Mini"},
    ["pv_bugvr"] = {"Bugatti Veyron Mini", 0, "Mini"},
    ["pv_bugatti"] = {"Bugatti La Voiture Noire Mini", 0, "Mini"},
    ["pv_bmwe46"] = {"Bmw e36 Mini", 0, "Mini"},
    ["kidscar"] = {"Masina Copii", 0, "Mini"},
    ["pv_sianr"] = {"Lamborghini Sian Mini", 0, "Mini"},
    ["pv_urus"] = {"Lamborghini Urus Mini", 0, "Mini"},
    ["babycar"] = {"Babycaru' lui Proxy", 0, "Mini"},
    ["pv_dawn"] = {"Rolls Royce Dawn Onyx Mini", 0, "Mini"},
	-- Altele --
    ["ttshrr"] = {"Audi TTS BodyKit", 0,"Altele"},
    ["rmodmonster"] = {"Quartz Regalia Monster", 0,"Altele"},
    ["rmodmonsterr34"] = {"Nissan Skyline R34 Monster", 0,"Altele"},
    ["air_baloon2"] = {"Balon Cu Aer Cald V.I.P.", 0,"Altele"},
    ["couchcar"] = {"Canapea", 0, "Altele"},
    ["tunak"] = {"Tuc Tuc", 0, "Altele"},
	-- Licitatii --
    ["alfa67"] = {"Alfa Romeo 33 Stradale 1967", 0,"Licitatii"},
    ["duetto"] = {"Alfa Romeo Spider Duetto 1966", 0,"Licitatii"},
    ["audif103"] = {"Audi F103", 0,"Licitatii"},
    ["eb110"] = {"Bugatti EB110 1992", 0,"Licitatii"},
    ["impala67"] = {"Chevrolet Impala", 0,"Licitatii"},
    ["69charger"] = {"Dodge Charger R/T 1969", 0,"Licitatii"},
    ["ikx3hemi9"] = {"Dodge Charger RT Hemi", 0,"Licitatii"},
    ["512tr"] = {"Ferrari 512TR", 0,"Licitatii"},
    ["cali57"] = {"Ferrari California 1957", 0,"Licitatii"},
    ["f4090"] = {"Ferrari F40 1990", 0,"Licitatii"},
    ["mig"] = {"Ferrari Enzo", 0,"Licitatii"},
    ["cc8s"] = {"Koenigsegg CC8S", 0,"Licitatii"},
    ["regalia"] = {"Quartz Regalia", 0,"Licitatii"},
    ["mclarenf1"] = {"McLaren F1 1992", 0,"Licitatii"},
    ["montego"] = {"Mercury Montego", 0,"Licitatii"},
    ["morgan"] = {"Morgan Aero 8", 0,"Licitatii"},
    ["fairlane64"] = {"Ford Fairlane", 0,"Licitatii"},
    ["tbird64"] = {"Ford Thunderbird", 0,"Licitatii"},
    ["fordc32"] = {"Ford V-8 Coupe 1932", 0,"Licitatii"},
    ["fgt"] = {"Ford GT 2005", 0,"Licitatii"},
    ["fastback"] = {"Ford Mustang Fastback", 0,"Licitatii"},
    ["2dopelr3"] = {"Opel Rekord 1965", 0,"Licitatii"},
    ["firebird"] = {"Pontiac Firebird 1968", 0,"Licitatii"},
    ["por959"] = {"Porsche 959 1987", 0,"Licitatii"},
    ["mb300sl"] = {"Mercedes-Benz 300SL 1955", 0,"Licitatii"},
    ["69nova"] = {"Chevrolet Nova", 0,"Licitatii"},
    ["ss69"] = {"Chevrolet Camaro SS", 0,"Licitatii"},
    ["packard48"] = {"Packard Eight 1948", 0,"Licitatii"},
    ["jb700"] = {"Aston Martin DB5 1965", 0,"Licitatii"},
    ["fnfdaytona"] = {"Dodge Daytona 1969", 0,"Licitatii"},
    ["jagtwr"] = {"Jaguar XJ220S TWR 1993", 0 ,"Licitatii"},
    ["torino70"] = {"Ford Gran Torino", 0,"Licitatii"},
    ["911rwb"] = {"Porsche 911 RWB", 0,"Licitatii"},
    ["a110s"] = {"Renault Alpine A110 1600 S 1970", 0,"Licitatii"},
    ["m1"] = {"BMW M1 1981", 0, "Licitatii"},
    ["skylineken"] = {"Nissan Skyline H/T 2000 GT-R", 0, "Licitatii"},
    ["benz220s"] = {"Mercedes-Benz 220S W111 1964", 0, "Licitatii"},
    ["jarama"] = {"Lamborghini Jarama", 0, "Licitatii"},
    ["356ac"] = {"Porsche 356 Speedster 1956", 0, "Licitatii"},
    ["rufyb"] = {"Porsche 911", 0, "Licitatii"},
    ["zephyr41c"] = {"Lincoln Zephyr 1941", 0, "Licitatii"},
    ["porrs73"] = {"Porsche Carrera 1973", 0, "Licitatii"},
    ["bmw507"] = {"BMW 507 1959", 0, "Licitatii"},
    ["3csl"] = {"BMW M3 CSL 1973", 0, "Licitatii"},
    ["v877"] = {"Aston Martin V8 Vantage 1977", 0, "Licitatii"},

	-- Aston Martin --
    ["ast"] = {"Aston Martin Vanquish", 27500000, "Clasa B"},
    ["db11"] = {"Aston Martin DB11", 25000000, "Clasa B"},
    ["dbx"] = {"Aston Martin DBX", 20000000, "Clasa B"},
    -- Audi --
    ["rs5r"] = {"Audi RS5 ABT", 15000000, "Clasa B"},
    ["2014rs5"] = {"Audi RS5", 9000000, "Clasa C"},
    ["rmodrs6r"] = {"Audi RS6 ABT", 23500000, "Clasa B"},
    ["r820"] = {"Audi R8", 30000000, "Clasa B"},
    ["audiq8"] = {"Audi Q8", 17500000, "Clasa B"},
    ["aaq4"] = {"Audi A4", 5500000, "Clasa C"},
    ["a8l"] = {"Audi A8", 6500000, "Clasa C"},
    ["a7"] = {"Audi A7", 12000000, "Clasa B"},
    ["a6"] = {"Audi A6", 7500000, "Clasa C"},    
    ["sq72016"] = {"Audi SQ7", 18000000,"Clasa B"},
    ["ttrs"] = {"Audi TTRS", 3500000,"Clasa C"},
    ["rs318"] = {"Audi RS3", 2500000,"Clasa C"},
    ["rs7c8"] = {"Audi RS7", 17500000,"Clasa B"},
    ["audquattros"] = {"Audi Quattro", 50000000,"WANTED"},
    ["ben17"] = {"Bentley Continental Supersports", 30000000,"Clasa B"},
    ["bentayga17"] = {"Bentley Bentayga", 28000000,"Clasa B"},
    ["contgt13"] = {"Bentley Continental GT", 25000000,"Clasa B"},
    -- BMW --
    ["e34"] = {"BMW M3 E34", 80000000,"Clasa D"},
    ["e36"] = {"BMW M3 E36", 25000000,"WANTED"},
    ["f82"] = {"BMW M4 F82", 16500000,"Clasa B"},
    ["e46"] = {"BMW M3 E46", 90000000,"Clasa D"},
    ["m3e92"] = {"BMW M3 E92", 3250000,"Clasa C"},
    ["m3f80"] = {"BMW M3 F80" , 6750000,"Clasa C"},
    ["m4c"] = {"BMW M4 Cabriolet", 6250000,"Clasa C"},
    ["m5e60"] = {"BMW M5 E60", 65000000,"Clasa D"},
    ["m6e24"] = {"BMW M6 E24", 1750000,"Clasa D"},
    ["m6f13"] = {"BMW M6 F13", 22500000,"Clasa B"},
    ["x5bmw"] = {"BMW X5", 19500000,"Clasa B"},
    ["x6m"] = {"BMW X6M", 17250000,"Clasa B"},

    ["17m760i"] = {"BMW M760i", 18750000,"Clasa B"},
    ["850csi"] = {"BMW 850CSI", 30000000,"Clasa B"},
    ["bmci"] = {"BMW M5 ", 425000,"WANTED"},
    ["gcmm5sb"] = {"BMW 530d Touring", 4750000,"Clasa C"},
    ["m2"] = {"BMW M2", 14500000,"Clasa B"},
    ["m3e30"] = {"BMW M3 E30", 15000000,"Clasa D"},
    ["bmwe39"] = {"BMW M3 E39", 2000000,"Clasa D"},
    ["isetta"] = {"BMW Isetta", 1250000,"Clasa D"},
    ['f10m5'] = {"BMW M5 F10", 125000000,"WANTED"},
    -- Bugatti --
    ["divo"] = {"Bugatti Divo", 570000000,"Clasa A"},
    ["rmodatlantic"] = {"Bugatti Atlantic", 1350000000,"Clasa A"},
    ["rmodbugatti"] = {"Bugatti La Voiture Noire", 1500000000,"Clasa A"},
    ["bugatti"] = {"Bugatti Veyron", 200000000,"Clasa A"},
    ["bug300ss"] = {"Bugatti Chiron Super Sport", 750000000,"Clasa A"},
    ["ikx3gp22"] = {"Bugatti Chiron Pur Sport", 900000000,"Clasa A"},
    -- Cadillac --
    ["ctsv16"] = {"Cadillac CTS-V", 11500000,"Clasa B"},
    -- Camioane --
    ["actros"] = {"Mercedes-Benz Actros", 65000000,"Camioane"},
    ["daf"] = {"Daf X6 EURO 6", 55000000,"Camioane"},
    ["fh500"] = {"Volvo FH500", 180000000,"Camioane"},
    ["man"] = {"Man TGX V8", 72500000,"Camioane"},
    ["r730"] = {"Scania R730", 90000000,"Camioane"},
    ["phantom"] = {"Tir Phantom", 125000000,"Camioane"},
    ["terbyte"] = {"MTL Terbyte", 40000000,"Camioane"},
    ["hauler2"] = {"Tir Hauler", 2500000,"Camioane"},
    ["brickade"] = {"MTL Brickade Heavy", 50000000,"Camioane"},
    ["hauler"] = {"Tir Hauler", 20000000,"Camioane"},
    ["cerberusc"] = {"Tir Cerberus", 15000000,"Camioane"},
    ["oiltanker"] = {"MTL OilTanker", 20000000,"Camioane"},
    ["20blazer"] = {"Chevrolet Blazer", 40000000,"Clasa C"},
    ["21camaro"] = {"Chevrolet Camaro", 14500000,"Clasa B"},
    ["c7"] = {"Chevrolet Corvette C7", 18000000,"Clasa B"},
    ["czr2"] = {"Chevrolet Colorado", 6500000,"Clasa C"},
    ["stingray"] = {"Chevrolet Corvette Stingray", 20500000,"Clasa B"},
    ["tahoe21"] = {"Chevrolet Tahoe", 8000000,"Clasa C"},
    -- Dacia --
    ["cutlass"] = {"Dacia Logan Papuc", 500000,"Dacia"},
    ["stepway"] = {"Dacia Sandero Stepway", 750000,"Dacia"},
    ["sandero"] = {"Dacia Sandero", 650000,"Dacia"},
    ["dacialogan"] = {"Dacia Logan", 300000,"Dacia"},
    ["1310s"] = {"Dacia 1310 Sport", 750000,"Dacia"},
    -- Daewoo --
    ["tico"] = {"Daewoo Tico", 350000000000000000,"Clasa D"},
    -- Dodge --
    ["vip8"] = {"Dodge Viper", 13500000,"Clasa B"},
    ["trx"] = {"Dodge RAM 1500 TRX", 7600000,"Clasa C"},
    ["dl2016"] = {"Dodge Ram 1500", 3000000,"Clasa C"},
    ["demonboi"] = {"Dodge Demon SRT", 16750000,"Clasa B"},
    ["1500ghoul"] = {"Dodge 1500 Ghoul", 8950000,"Clasa C"},
    -- Ferrari --
    ["f8spider"] = {"Ferrari F8 Spider", 385000000, "Clasa B"},
    ["fct"] = {"Ferrari California T", 425000000, "Clasa B"},
    ["fxxk2"] = {"Ferrari FXX K Evo", 285000000, "Clasa A"},
    ["pista"] = {"Ferrari 488 Pista", 565000000, "Clasa A"},
    ["porto18"] = {"Ferrari Portofino", 325000000, "Clasa B"},
    ["monzasp2"] = {"Ferrari Monza", 215000000, "Clasa A"},
    ["gtc4"] = {"Ferrari Lusso", 335000000, "Clasa B"},
    ["430s"] = {"Ferrari Scuderia 430", 300000000, "Clasa B"},
    ["575m"] = {"Ferrari 575M Maranello", 150000000,"Clasa B"},
    ["sf90"] = {"Ferrari SF90 Stradale", 225000000,"Clasa A"},
    ["laferrari"] = {"Ferrari LaFerrari", 450000000,"Clasa A"},
    -- Ford --
    ["wildtrak"] = {"Ford Bronco", 55000,"Clasa C"},
    ["mgt"] = {"Ford Mustang GT", 85000,"Clasa C"},
    ["gt17"] = {"Ford GT", 550000,"Clasa B"},
    ["frs"] = {"Ford Raptor F-150", 75000,"Clasa C"},
    ["f150"] = {"Ford Raptor F-150 SVT", 120000,"Clasa B"},
    -- GMC --
    ["gmc1500"] = {"GMC Sierra 1500", 22500,"Clasa C"},
    -- Honda --
    ["ek9"] = {"Honda Civic EK9", 194500,"WANTED"},
    ["civic"] = {"Honda Civic", 30000,"Clasa C"},
    ["ap2"] = {"Honda S2000", 8750,"Clasa D"},
    ["na1"] = {"Honda NSX", 350000,"WANTED"},
    ["honcrx91"] = {"Honda CRX", 175000,"WANTED"},
    -- Jaguar --
    ["cx75"] = {"Jaguar C-X75", 1150000, "Clasa A"},
    ["jaguarftype"] = {"Jaguar F-Type", 125000, "Clasa B"},
    -- Jeep --
    ["srt8"] = {"Jeep Grand Cherokee SRT", 135000, "Clasa B"},
    ["jeep2012"] = {"Jeep Wrangler Rubicon", 12500,"Clasa D"},
    ["jeepg"] = {"Jeep Gladiator", 45000,"Clasa C"},
    ["jp12"] = {"Jeep Rubicon", 42500,"Clasa C"},
    -- Kia --
    ["gcmsportage2022"] = {"Kia Sportage", 18500, "Clasa D"},
    -- Koenigsegg --
    ["rmodjesko"] = {"Koenigsegg Jesko", 4500000,"Clasa A"},
    ["agera"] = {"Koenigsegg Agera R", 4000000,"Clasa A"},
    ["gxone"] = {"Koenigsegg Agera One:1", 6500000,"Clasa A"},
    ["ccx"] = {"Koenigsegg CCX", 2750000,"Clasa A"},
    ["gemera"] = {"Koenigsegg Gemera", 1950000,"Clasa A"},
    ["regera"] = {"Koenigsegg Regera", 3500000,"Clasa A"},
    -- Lamborghini --
    ["2013lp560"] = {"Lamborghini Gallardo", 235000,"Clasa B"},
    ["lp770r"] = {"Lamborghini Centenario", 5500000,"Clasa A"},
    ["urus"] = {"Lamborghini Urus", 350000,"Clasa B"},
    ["18performante"] = {"Lamborghini Huracan Performante", 435000,"Clasa B"},
    ["reventonr"] = {"Lamborghini Reventon", 3000000,"Clasa A"},
    ["lp670sv"] = {"Lamborghini Murcielago SV", 1000000,"Clasa A"},
    -- Lexus --
    ["lx2018"] = {"Lexus LX 570", 92500,"Clasa C"},
    ["lfa"] = {"Lexus LFA", 600000, "Clasa A"},
    ["gs350"] = {"Lexus GS 350", 51500,"Clasa C"},
    -- Lotus --
    ["esprit02"] = {"Lotus Esprit", 112500,"Clasa B"},
    ["evija"] = {"Lotus Evija", 2500000,"Clasa A"},
    -- Maserati --
    ["mlnovitec"] = {"Maserati Levante Novitec", 145500,"Clasa B"},
    ["ghis2"] = {"Maserati Ghibli", 110000,"Clasa B"},
    ["mqgts"] = {"Maserati Quattroporte", 185000,"Clasa B"},
    -- Mazda --
    ["fc3s"] = {"Mazda RX-7 Savanna", 132500, "Clasa B"},
    ["fd"] = {"Mazda RX-7", 450000, "Clasa A"},
    ["na6"] = {"Mazda Miata", 15000, "Clasa C"},
    ["rx811"] = {"Mazda RX-8", 400000, "Clasa B"},
    ["rx7veilside"] = {"Mazda RX-7 Veilside(Corky)", 0, "Clasa A"},
    -- McLaren --
    ["720spider"] = {"McLaren 720 Spider", 350000,"Clasa B"},
    ["rmodspeed"] = {"McLaren Speedtail", 3350000,"Clasa A"},
    ["senna"] = {"McLaren Senna", 1000000,"Clasa A"},
    -- Mercedes --
    ["sl65bs"] = {"Mercedes-Benz SL65 AMG", 250000},
    ["19s63"] = {"Brabus 800 S63 Coupe", 625000},
    ["rmodc63amg"] = {"Mercedes AMG C63S Coupe", 225000},
    ["s63amg"] = {"Mercedes-AMG S63 Sedan", 175000},
    ["rmodgt63"] = {"Mercedes-AMG GT63S", 325000},
    ["rmode63s"] = {"Brabus 800 E63S", 350000},
    ["a45"] = {"Mercedes AMG A45", 115000},
    ["amggtc"] = {"Mercedes AMG GT C", 589500},
    ["benze55"] = {"Mercedes-Benz E55 AMG", 23500},


    ["brabus850"] = {"Brabus 850", 175000,"Clasa B"},
    ["bs900convertible"] = {"Brabus 900 Convertible", 400000,"Clasa B"},
    ["c63w205"] = {"Mercedes-Benz C63 AMG S", 120000,"Clasa B"},
    ["cls53"] = {"Mercedes-Benz CLS 53 AMG", 85000,"Clasa C"},
    ["cls2015"] = {"Mercedes-AMG CLS 63", 120000,"Clasa B"},
    ["e400"] = {"Mercedes-Benz E400", 75000,"Clasa C"},
    ["g65amg"] = {"Mercedes-AMG G65", 254500,"Clasa B"},
    ["gle53"] = {"Mercedes-Benz GLE Coupe 53 AMG", 125000,"Clasa B"},
    ["gle450"] = {"Mercedes-Benz GLE 450", 65000,"Clasa C"},
    ["mbw124"] = {"Mercedes-Benz 300D", 5750,"Clasa D"},
    ["mers63c"] = {"Mercedes-AMG S63 Cabriolet", 185000,"Clasa B"},
    ["slsamg"] = {"Mercedes-Benz SLS AMG", 355000,"Clasa B"},
    -- Mitsubishi --
    ["cp9a"] = {"Mitsubishi Lancer Evolution VI", 650000, "WANTED"},
    ["eclipse"] = {"Mitsubishi Eclipse", 475000,"WANTED"},
    ["evo9mr"] = {"Mitsubishi Lancer Evolution IX", 1500000,"WANTED"},
    ["mitsugto"] = {"Mitsubishi GTO", 325000,"WANTED"},
    -- Nissan --
    ["silvias15"] = {"Nissan Silvia S15", 375000,"WANTED"},
    ["nis13"] = {"Nissan Silvia S13", 550000,"WANTED"},
    ["gtr"] = {"Nissan GTR R35", 1200000,"WANTED"},
    ["bnr34"] = {"Nissan Skyline R34 Nismo", 650000,"WANTED"},
    ["bnr32"] = {"Nissan Skyline R32", 300000,"WANTED"},
    ["gx370z"] = {"Nissan 370Z", 117500,"WANTED"},
    ["180sx"] = {"Nissan 180SX", 235000,"WANTED"},
    ["tulenis"] = {"Nissan Patrol Nismo", 175000,"Clasa B"},
    ["skyline"] = {"Nissan Skyline R34", 400000,"WANTED"},
    ["r33"] = {"Nissan Skyline R33", 350000,"WANTED"},
    ["c210"] = {"Nissan Skyline C210", 50000,"Clasa C"},
    ["2000gtr"] = {"Nissan Skyline 2000GT-R", 287500,"WANTED"},
    ["maj350z"] = {"Nissan 350Z", 450000,"WANTED"},
    ["gc34"] = {"Nissan Laurel GC34", 135000,"WANTED"},
    ["nisgtir"] = {"Nissan Sunny", 550000,"WANTED"},
    -- Noble --
    ["m600"] = {"Noble M600", 397500,"Clasa B"},
    -- Pagani --
    ["zonda"] = {"Pagani Zonda Barchetta", 1800000,"Clasa A"},
    ["imola"] = {"Pagani Imola", 5500000,"Clasa A"},
    -- Porsche --
    ["918"] = {"Porsche 918 Spyder", 900000, "Clasa A"},
    ["17mansorypnmr"] = {"Porsche Panamera Mansory", 217500, "Clasa B"},
    ["ursa"] = {"Porsche Macan Ursa", 135000, "Clasa B"},
    ["gcm992gt3"] = {"Porsche 992 GT3", 200000, "Clasa B"},
    ["porcgt03"] = {"Porsche Carrera GT", 1350000, "Clasa A"},
    ["porche911speedhunter"] = {"Porsche 911 Turbo S Speedhunter", 325000, "Clasa B"},
    -- Range Rover --
    ["rmodrover"] = {"Range Rover SVR Mansory", 195000,"Clasa B"},
    ["rrs08"] = {"Range Rover Supercharged", 9500,"Clasa D"},
    ["18velar"] = {"Range Rover Velar", 70000,"Clasa C"},
    -- Renault --
    ["twizy"] = {"Reunault Twizy", 16500,"Clasa D"},
    ["cliors"] = {"Renault Clio RS", 32500,"Clasa C"},
    -- Skoda --
    ["superb"] = {"Skoda Superb", 6500,"Clasa D"},
    -- Rolls Royce --
    ["rculi"] = {"Rolls Royce Cullinan", 450000,"Clasa B"},
    ["wraith"] = {"Rolls Royce Wraith", 350000,"Clasa B"},
    -- Saleen --
    ["ss7"] = {"Saleen S7", 850000, "Clasa A"},
    -- GTA --
    ["spano2016"] = {"GTA Spano", 1750000,"Clasa A"},
    -- Subaru --
    ["subisti08"] = {"Subaru WRX STi", 175000,"WANTED"},
    ["brztuning"] = {"Subaru BRZ", 330000,"WANTED"},
    ["22b"] = {"Subaru Impreza 22B", 780000, "WANTED"},
    -- Tesla --
    ["models"] = {"Tesla Model S", 200000,"Clasa B"},
    ["teslax"] = {"Tesla Model X", 240000,"Clasa B"},
    ["tr22"] = {"Tesla Roadster", 400000,"Clasa B"},
    -- Toyota --
    ["tsgr20"] = {"Toyota Supra MK5", 500000, "WANTED"},
    ["a80"] = {"Toyota Supra MK4", 400000, "WANTED"},
    ["mr2sw20"] = {"Toyota MR-2 GT", 150000, "WANTED"},
    ["mk2100"] = {"Toyota Mark II", 75000, "WANTED"},
    ["jzx100"] = {"Toyota Chaser", 125000, "Clasa B"},
    ["21rav4"] = {"Toyota RAV4", 27500, "Clasa C"},
    ["toy86"] = {"Toyota GT86", 475000, "WANTED"},
    ["cruiser80"] = {"Toyota Cruiser", 7500,"Clasa D"},
    ["cam8tun"] = {"Toyota Camry", 65000, "WANTED"},
    ["celgt4"] = {"Toyota Celica GT4", 33500, "Clasa C"},
    -- VolksWagen --
    ["amgli"] = {"Volkswagen GLI", 25000, "Clasa C"},
    ["golf4"] = {"Volksagen Golf 4", 4750, "Clasa D"},
    ["golf75r"] = {"Volkswagen Golf 7R", 43500, "Clasa C"},
    ["r50"] = {"Volkswagen Touareg R50", 40000, "Clasa C"},
    ["golf8gti"] = {"Volkswagen Golf 8 GTI", 33000, "Clasa C"},
    ["golfmk6"] = {"Volkswagen Golf 6", 15000, "Clasa D"},
    ["vwbeetlenaj"] = {"Volkswagen Beetle", 5000, "Clasa D"},
    -- Dube --
    ["speedo"] = {"Duba Speedo", 12500, "Dube"},
    ["burrito3"] = {"Duba Burrito", 5000, "Dube"},
    ["gburrito2"] = {"Duba Burrito Sport", 10000, "Dube"},
    ["rumpo"] = {"Duba Rumpo", 7500, "Dube"},
    ["youga2"] = {"Duba Youga", 3000, "Dube"},
    -- Volvo --
    ["v242"] = {"Volvo V242", 3000,"Clasa D"},
    ["volvo850r"] = {"Volvo 850R", 13500, "Clasa D"},
    ["xc90"] = {"Volvo XC90", 90000,"Clasa C"},
    -- WMotors --
    ["wmfenyr"] = {"WMotors Fenyr", 1500000, "Clasa A"},
    ["lykan"] = {"WMotors Lykan", 3750000, "Clasa A"},
    -- Weeny -- 
    ["tamworth"] = {"Weeny Tamworth", 2000, "Clasa D"},
    -- Can-Am --
    ["can"] = {"Can-Am Maverick", 17500, "Clasa D"},
    -- LADA --
    ["lada2107"] = {"Lada 2107", 30000, "Lada"},
    -- ZONDA --
    ["zondacinque"] = {"Pagani Zonda Cinque", 0,"Clasa A"},
    -- VIP LA VANZARE --
    ["hycadeurus"] = {"Lamborghini Urus V.I.P.", 0},
    ["hycadepassat"] = {"Volkswagen Passat V.I.P.", 0},
    ["hurbyv"] = {"Lamborghini Huracan V.I.P.", 0},
    ["gtrlb2"] = {"Nissan GTR R35 Godzilla V.I.P.", 0},
    ["gtr50"] = {"Nissan GTR R50 V.I.P.", 0},
    ["fgt2"] = {"Ferrari F8 Tributo V.I.P.", 0},
    ["21charscat"] = {"Dodge Charger V.I.P.", 0},
    ["392scat"] = {"Dodge Challenger SRT V.I.P.", 0},
    ["x6hamann"] = {"BMW X6 Hamann V.I.P.", 0},
    ["taycan"] = {"Porsche Taycan V.I.P.", 0},
    ["variszupra"] = {"Toyota Supra V.I.P.", 0},
    ["techart17"] = {"Porsche Grand GT V.I.P.", 0},
    ["rrst"] = {"Range Rover Startech V.I.P.", 0},
    ["rrc5wd2"] = {"Chevrolet Corvette Drag V.I.P.", 0},
    ["casup"] = {"Toyota Supra MK5 V.I.P.", 0},
    ["pandeme36"] = {"BMW M3 E36 V.I.P.", 0},
    ["m2fd20"] = {"BMW M2 V.I.P.", 0},
    ["sianr"] = {"Lamborghini Sian Roadster V.I.P.", 0},
    ["lp610"] = {"Lamborghini Huracan Evo Spyder V.I.P.", 0},
    ["rmodmi8lb"] = {"BMW I8 LibertyWalk V.I.P.", 0},
    ["amggtsmansory"] = {"Mercedes AMG GT S Mansory V.I.P.", 0},
    ["rmodcharger"] = {"Dodge Charger SRT V.I.P.", 0},
    ["rmodskyline34"] = {"Nissan Skyline R34 Sponsor", 0},
    ["718gts"] = {"Porsche 718 Cayman GTS V.I.P.", 0},
    ["bmwx7kahn"] = {"BMW X7 Khann V.I.P.", 0},
    ["m516"] = {"BMW M5 F10 V.I.P.", 0},
    ["amgone"] = {"Mercedes-Benz AMG ONE V.I.P.", 0},
    ["roma"] = {"Ferrari 599 V.I.P.", 0},
    ["911turbos"] = {"Porsche 911 Turbo S V.I.P.", 0,"VIP"},
    -- Motociclete --
    ["flhxs_streetglide_special18"] = {"Street Glide Special", 23500, "Motociclete"},
    ["crfsm"] = {"Honda CRF450R", 4500, "Motociclete"},
    ["cbr500r"] = {"Honda CBR500R", 25000, "Motociclete"},
    ["cb1000r"] = {"Honda CB1000R", 13500, "Motociclete"},
    ["cb500x"] = {"Honda CB500X", 16500, "Motociclete"},
    ["blazer6"] = {"ATV Blazer", 11500, "Motociclete"},
    ["africat"] = {"Honda Africat Twin", 33500, "Motociclete"},
    ["20r1"] = {"Yamaha R1", 43500, "Motociclete"},
    ["goldwing"] = {"Honda Goldwing", 36500, "Motociclete"},
    ["gs1"] = {"BMW R1200", 14500, "Motociclete"},
    ["gsxr19"] = {"Suzuki GSX-R1000R", 34500, "Motociclete"},
    ["hvrod"] = {"Harley-Davidson V-Rod", 56000, "Motociclete"},
    ["monsteratv"] = {"ATV Monster", 15000, "Motociclete"},
    ["r6"] = {"Yamaha R6", 22500, "Motociclete"},
    ["r25"] = {"Yamaha R25", 26500, "Motociclete"},
    ["s1000rr"] = {"BMW S1000RR", 37500, "Motociclete"},
    ["tmaxdx"] = {"Yamaha Tmax", 6500, "Motociclete"},
    ["xadv"] = {"Honda X-ADV", 3500,"Motociclete"},
    ["yzfr125"] = {"Yamaha Yzf R125", 8500,"Motociclete"},
    ["zh2"] = {"Kawasaki ZH2", 43500, "Motociclete"},
    ["zx10r"] = {"Kawaski Ninja ZX-10R", 45000, "Motociclete"},
    ["xt66"] = {"Yamaha XT660R", 75000, "Motociclete"},
    -- Mini Cooper --
    ["austminlhd"] = {"Mini Cooper Austin", 3000, "Clasa d"},
    -- REMORCI --
    ["trailers"] = {"Cisterna", 300000,"Remorci"},
    ["trailers2"] = {"Prelata Mare", 900000,"Remorci"},
    ["trailers3"] = {"Remorca Minereuri", 300000,"Remorci"},
    ["trflat"] = {"Prelata Mica", 400000,"Remorci"},
    -- AVIOANE --
    ["dodo"] = {"Avion Dodo", 1000000,"Avioane"},
    ["cuban800"] = {"Avion Cuban 800", 600000, "Avioane"},
    ["luxor"] = {"Avion Luxor", 5000000,"Avioane"},
    ["velum"] = {"Avion Velum", 800000, "Avioane"},
    -- ELICOPTERE --
    ["buzzard2"] = {"Elicopter Buzzaard", 1750000,"Elicoptere"},
    ["maverick"] = {"Elicopter Maverick", 1250000,"Elicoptere"},
    ["supervolito2"] = {"Elicopter Supervolito", 2000000, "Elicoptere"},
    ["seasparrow"] = {"Elicopter Seasparrow", 2000000,"Elicoptere"},
    ["volatus"] = {"Elicopter Volatus", 2500000,"Elicoptere"},
    -- BARCI --
    ["yacht2"] = {"Yacht Sea Ray L650", 1500000, "Barci"},
    ["frauscher16"] = {"Barca Frauscher", 600000, "Barci"},
    ["fxho"] = {"Yamaha FX HO", 25000, "Barci"},
    ["dinghy"] = {"Barca RIB", 30000, "Barci"},
    ["jetmax"] = {"Barca Jetmax", 100000, "Barci"},
    ["speeder2"] = {"Barca Speeder", 150000, "Barci"},
    ["tropic"] = {"Barca Tropic", 55000, "Barci"},
    ["tug"] = {"TUG", 2000000, "Barci"},
    ["avisa"] = {"Submarin Avisa", 350000,"Barci"},
    ["submersible2"] = {"Submarin Kraken", 225000, "Barci"},
    ["submersible"] = {"Submarin Submersible", 500000,"Barci"},
    -- MASINI VANILLA --
    ["sunrise1"] = {"Karin Sunrise", 700000,"WANTED"},
    -- LOWRIDER --
    ["buccaneer2"] = {"Albany Buccaneer", 85000, "Lowrider"},
    ["voodoo"] = {"DeClasse Voodoo", 32750, "Lowrider"},
    ["virgo2"] = {"Dundrary Virgo", 50000, "Lowrider"},
    ["moonbeam2"] = {"DeClasse MoobBeam", 97500, "Lowrider"},
    ["sabregt2"] = {"Sabre Turbo", 60000, "Lowrider"},
    ["primo2"] = {"Albany Primo", 42000, "Lowrider"},
    ["chino2"] = {"Vapid Chino", 65000, "Lowrider"},
    ["faction2"] = {"Willard Faction", 52000, "Lowrider"},
    ["faction3"] = {"Willard Faction Wheels", 125000,"Lowrider"},
    ["hermes"] = {"Albany Hermes", 38500,"Lowrider"},
    ["minivan2"] = {"Vapid MiniVan", 70000,"Lowrider"},
    -- CAYO --
    ["surfer2"] = {"BF Surfer", 450000, "Cayo"},
    ["comet4"] = {"Pfister Comet Off-Road", 300000, "Cayo"},
    ["sanchez2"] = {"Maibatsu Sanchez", 125000, "Cayo"},
    ["hellion"] = {"Annis Hellion", 235000, "Cayo"},
    ["kamacho"] = {"Canis Kamacho", 180000, "Cayo"},
    ["savestra"] = {"Annis Savestra", 135000, "Cayo"},
    ["bfinjection"] = {"BF Injection", 200000, "Cayo"},
    ["bifta"] = {"BF Bifta", 100000, "Cayo"},
    ["cheburek"] = {"RUNE Cheburek", 50000, "Cayo"},
    -- MASINI VIPURI --

	-- ["Silver Account"]
	["drescirocco"] = {"Volkswagen Scirocco V.I.P.", 0,"VIP"},
	["18mh5"] = {"BMW M5 Manhart V.I.P.", 0,"VIP"},
	-- ["Gold Account"]
    ["rmodf12tdf"] = {"Ferrari F12TDF V.I.P.", 0, "VIP"},
    ["rmodbacalar"] = {"Bentley Bacalar V.I.P.", 0, "VIP"},
    ["lp700r"] = {"Lamborghini Aventador V.I.P.", 0, "VIP"},
    ["2019gt3rs"] = {"Porsche 911 GT3RS V.I.P.", 0, "VIP"},
    ["lwgtr"] = {"Nissan GTR R35 LibertyWalk V.I.P.", 0, "VIP"},
    ["havok"] = {"Elicopter Havok", 0, "VIP"},
    ["supra"] = {"Toyota Supra MK4 V.I.P.", 0, "VIP"},
    ["toro2"] = {"Barca Toro V.I.P.", 0, "VIP"},
    -- ["Platinum Account"]
    ["rmodveneno"] = {"Lamborghini Veneno V.I.P.", 0,"VIP"},
    ["agerars"] = {"Koenigsegg Agera RS V.I.P.", 0,"VIP"},
    ["mclp1"] = {"McLaren P1 V.I.P.", 0,"VIP"},
    ["rmodsvj"] = {"Lamborghini Aventador SVJ V.I.P.", 0,"VIP"},
    ["chiron17"] = {"Bugatti Chiron V.I.P.", 0,"VIP"},
    ["sr650fly"] = {"Yacht SR 650 FLY V.I.P.", 0,"VIP"},
    ["rmodpagani"] = {"Pagani Huayra Roadster V.I.P.", 0,"VIP"},
    ["aperta"] = {"Ferrari LaFerrari Aperta V.I.P.", 0,"VIP"},
    
    ["swift2021"] = {"Suzuki Swift",0,"VIP"},
    ["vwpassat"] = {"Volkswagen Passat B8",0,"VIP"},
    ["gcmcascada2018"] = {"Cascada 2018",0,"VIP"},
    ["HEVO"] = {"Lamborghini Huracan Performante",0,"VIP"},

    -- QUEST-URI --
   	["sanctus"] = {"Sanctus", 0,"Halloween Event"},
    ["patroly60"] = {"Nissan Patrol Y60", 0, "Christmas Event"},
    ["bf400"] = {"KTM SX", 0,"Christmas Event"},
    ["blazer4"] = {"ATV Blazer", 0,"Christmas Event"},

    ["GODzLBWKM4GTS"] = {"BMW M4 GTS", 0,"VIP"},
    ["libertym4cs"] = {"BMW M4 LIBERTY CS", 0,"VIP"},
    ["GODzBMWS1000RR"] = {"BMW S1000 RR 2022", 0,"VIP"},
    ["purosangue22"] = {"Ferrari Purosangue 2023", 0,"VIP"},
    ["ikx3machegt21"] = {"Ford Mustang MACH E-GT 2021", 0,"VIP"},
    ["ie1"] = {"Apollo Intesa", 0,"VIP"},
    ["hurlbp"] = {"Lamborghini Huracan Evo", 0,"VIP"},
    ["DL_G700"] = {"Mercedes G-Class AMG", 0,"VIP"},
    ["ikx3gtr20"] = {"Nissan GTR Nismo Chargespeed", 0,"VIP"},
    ["rmod911gt3"] = {"Porsche 911 GT3", 0,"VIP"},
    ["ikx3abt20"] = {"Audi RS7-R ABT", 0,"VIP"},
    ["ikx3etron22"] = {"Audi RS E-Tron GT", 0,"VIP"},
    ["18rs7"] = {"Audi RS7 C7", 0,"VIP"},
    ["rs7c821"] = {"Audi RS7 C8 ABT", 0,"VIP"},

    -- QUEST PASTE --
    ["cla250"] = {"Mercedes Cla AMG", 0, "Easter Event"},
    ["gls63"] = {"Mercedes Gls AMG", 0, "Easter Event"},
    ["rr21shelbyf150"] = {"Ford Shelby F150", 0, "Easter Event"},

    -- PACHET MAYBACH --
    ["2018s650"] = {"Mercedes-Benz Maybach S650 V.I.P.", 0, "VIP"},
    ["2018s650p"] = {"Mercedes-Benz Maybach S650 Pullman V.I.P.", 0, "VIP"},
    -- PACHET BMW --
    ["bmwm4"] = {"BMW M4 Competition V.I.P.", 0,"VIP"},
    ["rmodm8c"] = {"BMW M8 Cabriolet V.I.P.", 0,"VIP"},
    -- PACHET AUDI --
    ["rs5mans"] = {"Audi RS5 Mansory V.I.P.", 0, "VIP"},
    ["r8v10abt"] = {"Audi R8 ABT V.I.P.", 0,"VIP"},
    -- PACHET ROLLS --
    ["dawnonyx"] = {"Rolls-Royce Dawn Onyx V.I.P.", 0,"VIP"},
    ["ph8m"] = {"Rolls-Royce Phantom 8 V.I.P.", 0, "VIP"},
    -- EXCLUSIVE PACK --
    ["mvisiongt"] = {"Mercedes-Benz Vision GT V.I.P.", 0, "VIP"},
    ["terzo"] = {"Lamborghini Terzo Millennio", 0, "VIP"},
    -- FLYERS PACK --
    ["swift2"] = {"Elicopter Swift GOLD V.I.P.", 0, "VIP"},
    ["luxor2"] = {"Avion Luxor GOLD V.I.P.", 0, "VIP"},

    -- SMART PACK --
    ["gcmetronsportback2021"] = {"Audi E-Tron Sportback 2023", 0, "VIP"},
    ["gcmmodelsplaid2021"] = {"Tesla Model S Plaid", 0, "VIP"},
    ["xplaid24"] = {"Tesla Model X Plaid", 0, "VIP"},
}

return cfg