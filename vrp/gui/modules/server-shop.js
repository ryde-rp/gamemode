const ServerShop = new Vue({
	el: ".server-shop",
	data: {
		active: false,
		viewImages: false,
		coins: 0,
		CreatorCode: "",
		hoveredItems: {'bronze': false, 'silver': false, 'platinum': false, 'maybach_pack': false, 'audi_pack': false, 'bmw_pack': false, 'rolls_pack': false, 'exclusive_pack': false, 'plane_pack': false, 'starter_pack': false, 'car_plate': false, 'phone_number': false, 'smart_pack': false, money_benef: false, money_benef2: false, money_benef3: false, custom_house_card:false, house_wardrobe_card:false, house_garage_card:false},
		CurrentPage: 1,
		MaxPage: 7,		
		// Images Data
		ImageType: 'silver',
		viewImages: true,
		CurrentImageNumber : 0,

		ShopGalery: {
			'silver': [
				{name: "Wolkswagen Scirocco", type: "SILVER ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/scirocco.webp"},
				{name: "BMW M5 COMPETITION G30", type: "SILVER ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/18m5.webp"},
				// {name: "PORSCHE 911 TURBO S", type: "SILVER ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/911turbo.webp"},
				{name: "Audi RS7 C7", type: "SILVER ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/18rs7.webp"},
			],
			'gold': [
				// Gold Vehicles
				{name: "Ferrari Purosangue 2023", type: "GOLD ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/purosangue22.webp"},
				{name: "Nissan GTR Nismo Chargespeed", type: "GOLD ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/ikx3gtr20.webp"},
				{name: "Audi RS E-Tron GT", type: "GOLD ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/ikx3etron22.webp"},

				{name: "BENTLEY BACALAR 2020", type: "GOLD ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/bacalar.webp"},
				{name: "FERRARI F12 BERLINETA", type: "GOLD ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/ferrari.webp"},
				{name: "LAMBORGHINI LP770", type: "GOLD ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/lp770.webp"},
				// {name: "PORSCHE 911 GT3 RS", type: "GOLD ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/911turbos.webp"},
				{name: "NISSAN GTR SKYLINE LIBERTY WALK", type: "GOLD ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/nissan.webp"},
				//Silver Vehicles
				{name: "Wolkswagen Scirocco", type: "SILVER ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/scirocco.webp"},
				{name: "BMW M5 COMPETITION G30", type: "SILVER ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/18m5.webp"},
				// {name: "PORSCHE 911 TURBO S", type: "SILVER ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/911turbo.webp"},
				{name: "Audi RS7 C7", type: "SILVER ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/18rs7.webp"},
			],
			'platinum': [
				// Platinum Vehicles
				{name: "BMW M4 LIBERTY CS", type: "PLATINUM ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/libertym4cs.webp"},
				{name: "BMW S1000 RR 2022", type: "PLATINUM ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/GODzBMWS1000RR.webp"},
				{name: "Lamborghini Huracan Evo", type: "PLATINUM ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/hurlbp.webp"},
				{name: "Mercedes G-Class AMG", type: "PLATINUM ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/DL_G700.webp"},
				{name: "Audi RS7-R ABT", type: "PLATINUM ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/ikx3abt20.webp"},

				{name: "BUGATTI CHIRON", type: "PLATINUM ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/chiron17.webp"},
				{name: "KOENIGSEGG AGERA RS", type: "PLATINUM ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/agera.webp"},
				{name: "LAMBORGHINI VENENO", type: "PLATINUM ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/veneno.webp"},
				{name: "LAMBORGHINI AVENTADOR SVJ", type: "PLATINUM ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/svj.webp"},
				// {name: "ZONDA CINQUE", type: "PLATINUM ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/zonda.webp"},
				{name: "MCLAREN P1", type: "PLATINUM ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/mp1.webp"},
				{name: "FERRARI LAFERRARI", type: "PLATINUM ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/aperta.webp"},
				// Gold Vehicles
				{name: "Ferrari Purosangue 2023", type: "GOLD ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/purosangue22.webp"},
				{name: "Nissan GTR Nismo Chargespeed", type: "GOLD ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/ikx3gtr20.webp"},
				{name: "Audi RS E-Tron GT", type: "GOLD ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/ikx3etron22.webp"},

				{name: "BENTLEY BACALAR 2020", type: "GOLD ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/bacalar.webp"},
				{name: "FERRARI F12 BERLINETA", type: "GOLD ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/ferrari.webp"},
				{name: "LAMBORGHINI LP770", type: "GOLD ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/lp770.webp"},
				// {name: "PORSCHE 911 GT3 RS", type: "GOLD ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/911turbos.webp"},
				{name: "NISSAN GTR SKYLINE LIBERTY WALK", type: "GOLD ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/nissan.webp"},
				// Silver Vehicles
				{name: "Wolkswagen Scirocco", type: "SILVER ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/scirocco.webp"},
				{name: "BMW M5 COMPETITION G30", type: "SILVER ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/18m5.webp"},
				// {name: "PORSCHE 911 TURBO S", type: "SILVER ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/911turbo.webp"},
				{name: "Audi RS7 C7", type: "SILVER ACCOUNT", image: "https://cdn.fairplay-rp.ro/vehicles/18rs7.webp"},
			],
			'maybach_pack': [
				{name: "Mercedes Benz Maybach 2018 S 650 PULLMAN", type: "MAYBACH PACK", image: "https://cdn.fairplay-rp.ro/vehicles/2018s650p.webp"},
				{name: "Mercedes Benz Maybach 2018 S 650", type: "MAYBACH PACK", image: "https://cdn.fairplay-rp.ro/vehicles/2018s650.webp"},
			],
			'audi_pack': [
				{name: "AUDI RS5 MANSORY 2020", type: "AUDI PACK", image: "https://cdn.fairplay-rp.ro/vehicles/rs5mans.webp"},
				{name: "AUDI R8 ABT 2020", type: "AUDI PACK", image: "https://cdn.fairplay-rp.ro/vehicles/r8v10abt.webp"},
			],
			'bmw_pack': [
				{name: "BMW M4 COMPETITION 2020", type: 'BMW PACK', image: "https://cdn.fairplay-rp.ro/vehicles/bmwm4.webp"},
				{name: "BMW M8 COMPETITION 2020", type: 'BMW PACK', image: "https://cdn.fairplay-rp.ro/vehicles/rmodm8c.webp"},
			],
			'rolls_pack': [
				{name: "ROLLS ROYCE PHANTOM", type: "ROLLS ROYCE PACK", image: "https://cdn.fairplay-rp.ro/vehicles/ph8m.webp"},
				{name: "ROLLS ROYCE DAWN ONYX", type: "ROLLS ROYCE PACK", image: "https://cdn.fairplay-rp.ro/vehicles/dawnonyx.webp"},
			],
			'exclusive_pack': [
				{name: "Mercedes Benz AMG Vision Gran Turismo", type: "EXCLUSIVE PACK", image: "https://cdn.fairplay-rp.ro/vehicles/mvisiongt.webp"},
				{name: "Lamborghini Terzo Millennio", type: "EXCLUSIVE PACK", image: "https://cdn.fairplay-rp.ro/vehicles/terzo.webp"},
			],
			'smart_pack': [
				{name: "Audi E-Tron Sportback 2023 ", type: "SMART PACK", image: "https://cdn.fairplay-rp.ro/vehicles/gcmetronsportback2021.webp"},
				{name: "Tesla Model S Plaid", type: "SMART PACK", image: "https://cdn.fairplay-rp.ro/vehicles/gcmmodelsplaid2021.webp"},
				{name: "Tesla Model X Plaid", type: "SMART PACK", image: "https://cdn.fairplay-rp.ro/vehicles/xplaid24.webp"},
			],
		}
	},
	mounted() {
		window.addEventListener("keydown", this.onKey)
	},
	methods: {
		onKey() {
			var theKey = event.code;
			if (theKey == "Escape" && this.active) {
				if (this.viewImages) {
					this.viewImages = false;
					$('.shop-photos-wrapper').fadeOut();
				} else {
					this.destroy();
				}
			}
			if (theKey == "ArrowRight") {
				if (!this.viewImages) return;
				this.NextImage();
			}
			if (theKey == "ArrowLeft") {
				if (!this.viewImages) return;
				this.PrevImage();
			}
		},
		nextPage() {
			if (this.CurrentPage < this.MaxPage) {
				this.CurrentPage++;
			}
		},
		prevPage() {
			if (this.CurrentPage > 1) {
				this.CurrentPage--;
			}
		},
		OpenImageMenu(type) {
			this.ImageType = type;
			this.CurrentImageNumber = 0;

			$('.shop-photos-wrapper').show();
			this.viewImages = true;
		},
		GoToShop() {
			window.invokeNative('openUrl', 'https://discord.gg/ryde');
		},
		NextImage() {
			if (this.CurrentImageNumber < this.ShopGalery[this.ImageType].length - 1) {
				this.CurrentImageNumber++;
			}
		},
		PrevImage() {
			if (this.CurrentImageNumber > 0) {
				this.CurrentImageNumber--;
			}
		},
		async post(url, data = {}) {
			const response = await fetch(`https://${GetParentResourceName()}/${url}`, {
			    method: 'POST',
			    headers: { 'Content-Type': 'application/json' },
			    body: JSON.stringify(data)
			});
			
			return await response.json();
		},
		buy(item) {
			this.post("server-shop:buy", {item: item, code: this.CreatorCode.toUpperCase()});
			this.destroy();
		},
		async build() {
			this.active = true;
			$(".server-shop").fadeIn();
			let coinsData = await this.post("server-shop:getCoins");
			this.coins = coinsData;

		},
        destroy() {
            this.active = false;
            $(".server-shop").fadeOut();
            this.post("server-shop:destroy");
        },
	},
	computed: {
		GetImage() {
			return this.ShopGalery[this.ImageType][this.CurrentImageNumber].image
		},
		GetName() {
			return this.ShopGalery[this.ImageType][this.CurrentImageNumber].name
		},
		GetType() {
			return this.ShopGalery[this.ImageType][this.CurrentImageNumber].type
		},
	},
})