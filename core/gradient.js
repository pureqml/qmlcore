var GradientStop = function(color, position) {
	this.color = $core.Color.normalize(color)
	this.position = position
}

var GradientStopPrototype = GradientStop.prototype
GradientStopPrototype.constructor = GradientStop

GradientStopPrototype.toString = function() {
	return this.color + " " + Math.floor(100 * this.position) + "%"
}

var Gradient = function(orientation, type) {
	this.orientation = orientation
	this.stops = []
	this.type = type
}

var GradientPrototype = Gradient.prototype
GradientPrototype.constructor = Gradient

GradientPrototype.add = function(stop) {
	this.stops.push(stop)
}

GradientPrototype.toString = function() {
	if (this.type === $core.Gradient.Linear) {
		return 'linear-gradient(' + this.orientation + ',' + this.stops.join() + ')'
	}
	else if (this.type === $core.Gradient.Conical) {
		var gradientString = 'conic-gradient(from ' + this.orientation
		for(var i = 0; i < this.stops.length; ++i) {
			var stop = this.stops[i]
			gradientString += ', ' + stop.color.hex() + ' '  + 2 * Math.PI * stop.position + 'rad'
		}
		gradientString += ')'
		return gradientString;
	}

	throw new Error("Gradient Type " + this.type + " is not supported")
	return "";
}

exports.GradientStop = GradientStop
exports.Gradient = Gradient
