Layout {
	property int currentIndex: 0;
	property int count: 0;

	onCurrentIndexChanged: {
		if (this.currentIndex < 0)
			this.currentIndex = 0;
		else if (this.currentIndex >= this.children.length)
			this.currentIndex = this.children.length - 1;
			
		this._layout();
	}
}
