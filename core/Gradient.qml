Object {
	property enum orientation { Vertical, Horizontal };

	constructor: {
		this.stops = []
	}

	function addChild(child) {
		this.stops.push(child)
		this.stops.sort(function(a, b) { return a.position > b.position; })
	}

	function _getDeclaration() {
		var decl = []
		var orientation = this.orientation == this.Vertical? 'bottom': 'left'
		decl.push(orientation)

		var stops = this.stops
		var n = stops.length
		if (n < 2)
			return

		for(var i = 0; i < n; ++i) {
			var stop = stops[i]
			decl.push(stop._getDeclaration())
		}
		return decl.join()
	}

	onCompleted: {
		this.parent._update('gradient', this)
	}
}
