/* qml.core javascript code */

function Context() {
	console.log("context created");
}


exports.Property = function(type, value) {
	this.type = type;
	this.value = value;
}

exports.context = new Context();
