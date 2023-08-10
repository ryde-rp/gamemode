$(document).on("click", "#callTaxi", function(e) {
	if(QB.Phone.Data.currentApplication === "taxi") {
        var notes = $("#taxiCall-notes").val();
        post("callForTaxi", [notes]);
        
        $("#taxiCall-notes").val("");
    }
})