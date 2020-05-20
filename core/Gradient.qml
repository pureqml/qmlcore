/// gradient filled area, just place GradientStop in its scope
Object {
	property enum orientation { Vertical, Horizontal, BottomRight, TopRight, Custom };	///< gradient direction enumaration
	property real angle;	///< angle for custom orientated gradient

	///@private
	constructor: {
		this.stops = []
	}

	///@private
	function addChild(child) {
		$core.Object.prototype.addChild.apply(this, arguments)
		if (child instanceof $core.GradientStop) {
			this.stops.push(child)
			this.stops.sort(function(a, b) { return a.position > b.position; })
			this._updateStyle()
		}
	}

	///@private
	function _updateStyle() {
		var decl = this._getDeclaration()
		if (decl)
			this.parent.style({ 'background-color': '', 'background': decl })
	}

	///@private
	function _getDeclaration() {
		var stops = this.stops
		var n = stops.length
		if (n < 2)
			return

		var orientation
		switch(this.orientation) {
			default:
			case this.Vertical:	orientation = 'to bottom'; break
			case this.Horizontal:	orientation = 'to left'; break
			case this.BottomRight:	orientation = 'to bottom right'; break
			case this.TopRight:	orientation = 'to top right'; break
			case this.Custom:	orientation = this.angle + 'deg'; break
		}

		var grad = new $core.gradient.Gradient(orientation)

		for(var i = 0; i < n; ++i) {
			var stop = stops[i]
			grad.add(stop._getDeclaration())
		}

		return grad
	}

	///@private
	onCompleted: {
		this._updateStyle()
	}
}
