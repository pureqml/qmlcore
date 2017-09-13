/// Colored rectangle with optional rounded corners, border and/or gradient.
Item {
	property color color: "#0000";		///< rectangle background color
	property lazy border: Border {}		///< object holding properties of the border
	property Gradient gradient;			///< if gradient object was set, it displays gradient instead of solid color

	onColorChanged: {
		this.style('background-color', _globals.core.normalizeColor(value))
	}

	prototypeConstructor: {
		RectanglePrototype._propertyToStyle = Object.create(RectangleBasePrototype._propertyToStyle)
		Object.assign(RectanglePrototype._propertyToStyle, {
			'color': 'background-color'
		})
	}
}
