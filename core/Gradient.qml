Object {
	property int orientation;
	onCompleted: {
		this.parent._update('gradient', this)
	}
}
