/// @private Anchor's vertical or horizontal line (left, right, center)
DummyObject {
	property int boxIndex;

	function toScreen() {
		return this.parent.toScreen()[this.boxIndex]
	}
}
