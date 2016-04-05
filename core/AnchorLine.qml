Object {
	property int boxIndex;

	function toScreen() {
		return this.parent.toScreen()[this.boxIndex]
	}

}
