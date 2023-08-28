///layout for displaying one of its children at the time
Layout {
	property int currentIndex: 0;	///< index of displaying child
	property int count: 0;			///< childrens count
	clip: true;	///@private

	/// @private
	onCurrentIndexChanged: {
		if (this.currentIndex < 0)
			this.currentIndex = 0;
		else if (this.children.length > 0 && this.currentIndex >= this.children.length)
			this.currentIndex = this.children.length - 1;

		this._scheduleLayout()
	}

	/// @private
	onActiveFocusChanged: {
		if (value && this.count)
			this.children[this.currentIndex].setFocus()
	}

	/// @private
	function _layout() {
		this.count = this.children.length;
		if (this.trace)
			log('laying out ' + this.count + ' children in ' + this.width + 'x' + this.height)

		for (var i = 0; i < this.count; ++i)
			this.children[i].visibleInView = (i === this.currentIndex);

		var c = this.children[this.currentIndex];
		if (!c)
			return

		this.contentHeight = c.height;
		this.contentWidth = c.width;
	}

	/// @private
	function addChild(child) {
		$core.Layout.prototype.addChild.apply(this, arguments)
		var children = this.children
		var index = children.length - 1
		var lastChild = children[index]
		lastChild.visibleInView = (index === this.currentIndex)
		var update = this._scheduleLayout.bind(this)
		child.onChanged('height', update)
		child.onChanged('recursiveVisible', update)
	}
}
