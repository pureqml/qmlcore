///layout for displaying one of its children at the time
Layout {
	property int currentIndex: 0;	///< index of displaying child
	property int count: 0;			///< childrens count
	clip: true;

	/// @private
	onCurrentIndexChanged: {
		if (this.currentIndex < 0)
			this.currentIndex = 0;
		else if (this.currentIndex >= this.children.length)
			this.currentIndex = this.children.length - 1;

		this._delayedLayout.schedule()
	}

	/// @private
	onActiveFocusChanged: {
		if (value && this.count)
			this.children[this.currentIndex].setFocus()
	}

	/// @private
	function _layout() {
		this.count = this.children.length;
		for (var i = 0; i < this.count; ++i)
			this.children[i].visibleInView = (i == this.currentIndex);

		var c = this.children[this.currentIndex];
		if (!c)
			return

		this.contentHeight = c.height;
		this.contentWidth = c.width;
	}

	/// @private
	function addChild(child) {
		_globals.core.Item.prototype.addChild.apply(this, arguments)
		var delayedLayout = this._delayedLayout
		child.onChanged('height', delayedLayout.schedule.bind(delayedLayout))
		child.onChanged('recursiveVisible', delayedLayout.schedule.bind(delayedLayout))
	}
}
