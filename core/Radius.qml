Object {
	property real radius;			///< radius for all corners
	property real topLeft;			///< top left corner radius
	property real topRight;			///< top right corner radius
	property real bottomLeft;		///< bottom left corner radius
	property real bottomRight;		///< bottom right corner radius

	prototypeConstructor: {
		RadiusPrototype.defaultProperty = 'radius';
	}

	_updateValue: {
		var radius = this.radius
		var tl = this.topLeft || radius
		var tr = this.topRight || radius
		var bl = this.bottomLeft || radius
		var br = this.bottomRight || radius
		if (tl == tr && bl == br && tl == bl)
			this.parent.style('border-radius', tl)
		else
			this.parent.style('border-radius', tl + 'px ' + tr + 'px ' + br + 'px ' + bl + 'px')
	}

	onRadiusChanged,
	onTopLeftChanged,
	onTopRightChanged,
	onBottomLeftChanged,
	onBottomRightChanged: {
		this._updateValue()
	}
}
