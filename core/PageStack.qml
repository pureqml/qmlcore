Layout {
	property int currentIndex: 0;
	property int count: 0;
	clip: true;

	onCurrentIndexChanged: {
		if (this.currentIndex < 0)
			this.currentIndex = 0;
		else if (this.currentIndex >= this.children.length)
			this.currentIndex = this.children.length - 1;
			
		this._delayedLayout.schedule()
	}

	function _layout() {
		this.count = this.children.length;
		for (var i = 0; i < this.count; ++i)
			this.children[i].visible = (i == this.currentIndex);

		var c = this.children[this.currentIndex];
		this.contentHeight = c.height;
		this.contentWidth = c.width;
	}

	function addChild(child) {
		exports.core.Item.prototype.addChild.apply(this, arguments)
		var delayedLayout = this._delayedLayout
		child.onChanged('height', delayedLayout.schedule.bind(delayedLayout))
		child.onChanged('recursiveVisible', delayedLayout.schedule.bind(delayedLayout))
	}

}
