Object {
	property enum orientation { Vertical, Horizontal };
	onCompleted: {
		this.parent._update('gradient', this)
	}
}
