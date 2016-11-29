/// @private Anchor's vertical or horizontal line (left, right, center)
Object {
	property int boxIndex;

	function toScreen() {
		return this.parent.toScreen()[this.boxIndex]
	}

}
