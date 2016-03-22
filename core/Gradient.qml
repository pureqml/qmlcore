Object {
	property enum orientation { Vertical, Horizontal };

	constructor: {
		this.stops = []
	}

	onCompleted: {
		this.parent._update('gradient', this)
	}
}
