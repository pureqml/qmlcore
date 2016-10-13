Object {
	property enum orientation { Vertical, Horizontal, BottomRight, TopRight, Custom };
	property real angle;

	constructor: {
		this.stops = []
	}

	function addChild(child) {
		this.stops.push(child)
		this.stops.sort(function(a, b) { return a.position > b.position; })
		this._update()
	}

	function _update() {
		var decl = this._getDeclaration()
		if (decl)
			this.parent.style({ 'background-color': '', 'background': 'linear-gradient(' + decl + ')' })
	}

	function _getDeclaration() {
		var stops = this.stops
		var n = stops.length
		if (n < 2)
			return

		var decl = []
		var orientation = this.orientation == this.Vertical? 'bottom': 'left'

		switch(this.orientation) {
				case this.Vertical:	orientation = 'to bottom'; break
				case this.Horizontal:	orientation = 'to left'; break
				case this.BottomRight:	orientation = 'to bottom right'; break
				case this.TopRight:	orientation = 'to top right'; break
				case this.Custom:	orientation = this.angle + 'deg'; break
		}

		decl.push(orientation)

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
