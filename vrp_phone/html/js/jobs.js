

const jobsList = [
    {
        jobTitle: "Sofer de Autobuz",
        pos: [441.44943237304,-628.14428710938],
        jobHours: 0,
    },

    {
        jobTitle: "Gradinar",
        pos: [2016.9776611328,4987.822265625],
        jobHours: 0,
    },

    {
        jobTitle: "Culegator de mere",
        pos: [2335.2333984375,4859.8715820312],
        jobHours: 0,
    },

    {
        jobTitle: "Taxi",
        pos: [898.48217773438,-175.52201843262],
        jobHours: 0,
    },

    {
        jobTitle: "Mecanic",
        pos: [1737.9959716797,3709.2326660156],
        jobHours: 0,
    },

    {
        jobTitle: "Livrator Glovo",
        pos: [87.893203735352,292.38330078125],
        jobHours: 0,
    },
    
    {
        jobTitle: "Electrician",
        pos: [718.83526611328,152.36094665527],
        jobHours: 5,
    },
    {
        jobTitle: "Pescar",
        pos: [-1593.9592285156,5192.8315429688],
        jobHours: 10,
    },
    {
        jobTitle: "Constructor",
        pos: [-96.838928222656,-1013.2667236328],
        jobHours: 5,
    },

    {
        jobTitle: "Farmer",
        pos: [2029.7957763672,4980.6938476562],
        jobHours: 45,
    },

    {
        jobTitle: "Miner",
        pos: [2832.3134765625,2799.8601074219],
        jobHours: 5,
    },
    {
        jobTitle: "Petrolist",
        pos: [-458.25259399414,-2266.1918945312],
        jobHours: 20,
    },
    {
        jobTitle: "Taietor de Lemne",
        pos: [-567.41461181641,5252.984375],
        jobHours: 30,
    },
    {
        jobTitle: "Trucker",
        pos: [815.62811279297,-3000.296875],
        jobHours: 50,
    },

    {
        jobTitle: "Gunoier",
        pos: [-539.80291748047,-1638.0561523438],
        jobHours: 45,
    },
    {
        jobTitle: "Scafandru",
        pos: [3817.1594238281,4483.009765625],
        jobHours: 50,
    },
];

const setJobPos = (x, y) => {
	$.post("https://vrp_phone/SharedLocation", JSON.stringify({
		coords: {x: x, y: y},
	}))
}

const useJobEvent = (e) => {
	$.post("https://vrp_phone/workAtJob", JSON.stringify({
		job: e,
	}))
}

const setupJobs = () => {
	$(".jobs-app > .content > .jobs-list").html("");

	for(let i = jobsList.length - 1; i >= 0; i--) {
		var groupData = jobsList[i];

		$(".jobs-app > .content > .jobs-list").prepend(`
			<div>
				<p>${groupData.jobTitle} <span>(${groupData.jobHours || 0}h)</span></p>
				<div class="job-btns">
					${groupData.pos ? '<i class="fas fa-map-location-dot" onclick="setJobPos(' + groupData.pos[0] +','+ groupData.pos[1] +')"></i>' : ''}
					${groupData.jobEvent ? `<i class="fas fa-briefcase" onclick="useJobEvent('` + groupData.jobEvent + `')"></i>` : ''}
				</div>
			</div>
		`);
	}
}