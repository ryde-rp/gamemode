const vehSpeedometer = new Vue({
	el: ".speedometer-layout",
	data: {
      speed: 0,
      gear: 1,
      tank: 0,
      engine: false,
      seatbelt: false,
      lights: false,
      doors: false,
      odometer: 0,
	},
})