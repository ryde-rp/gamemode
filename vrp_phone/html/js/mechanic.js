$(document).on("click", "#callMechanic", function(e) {
	if(QB.Phone.Data.currentApplication === "mechanic") {
        post("callForMechanic", []);
    }
})