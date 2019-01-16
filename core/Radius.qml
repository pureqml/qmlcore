Object {
	property real radius;
	property real topLeft;
	property real topRight;
	property real bottomLeft;
	property real bottomRight;

	prototypeConstructor: {
		RadiusPrototype.defaultProperty = 'radius';
	}

	onRadiusUpdate,
	onTopLeftUpdate,
	onTopRightUpdate,
	onBottomLeftUpdate,
	onBottomRightUpdate: {
		log('updating border')
	}
	onCompleted: {
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
}
