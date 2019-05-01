/// Colored rectangle with optional rounded corners, border and/or gradient.
Item {
	property color color: "#0000";		///< rectangle background color
	property lazy border: Border {}		///< object holding properties of the border
	property Gradient gradient;			///< if gradient object was set, it displays gradient instead of solid color
	constructor : {
		this._context.backend.initRectangle(this)
	}

	onColorChanged: {
		this.style('background-color', $core.Color.normalize(value))
	}

	prototypeConstructor: {
		var styleMap = RectanglePrototype._propertyToStyle = Object.create(RectangleBasePrototype._propertyToStyle)
		styleMap['color'] = 'background-color'
	}
}
