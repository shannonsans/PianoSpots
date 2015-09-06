 function resetCanvas() {
 	var pjs = Processing.getInstanceById("PianoSpots");
	pjs.killAllSpots();
}

function hideInfo() {
	document.getElementById("intro").classList.add("hide");
}