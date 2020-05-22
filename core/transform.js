var Value = function(value, unit) {
	this.value = value
	this.unit = unit
}

var ValuePrototype = Value.prototype
ValuePrototype.constructor = Value

ValuePrototype.toString = function() {
	var unit = this.unit
	return unit != undefined? this.value + unit: this.value
}

var Transform = function() {
	this.transforms = {}
}

var TransformPrototype = Transform.prototype
TransformPrototype.constructor = Transform

TransformPrototype.add = function(name, value, unit) {
	this.transforms[name] = new Value(value, unit)
}

TransformPrototype.toString = function() {
	var transforms = this.transforms
	var str = ''
	for(var name in transforms) {
		var value = transforms[name]
		str += name + '(' + value + ') '
	}
	return str
}

exports.Transform = Transform

