/// layout for horizontal oriented content
Layout {
	///@private
	onKeyPressed: {
		if (!this.handleNavigationKeys)
			return false;

		switch(key) {
			case 'Left':	return this.focusPrevChild()
			case 'Right':	return this.focusNextChild()
		}
	}

	///@private
	function _layout() {
		if (!this.recursiveVisible && !this.offlineLayout)
			return

		var children = this.children;
		var p = 0
		var h = 0
		this.count = children.length
		for(var i = 0; i < children.length; ++i) {
			var c = children[i]
			if (!('height' in c))
				continue
			var b = c.y + c.height
			if (b > h)
				h = b
			c.viewX = p
			if (c.recursiveVisible)
				p += c.width + this.spacing
		}
		if (p > 0)
			p -= this.spacing
		this.contentWidth = p
		this.contentHeight = h
	}

	///@private
	function addChild(child) {
		_globals.core.Item.prototype.addChild.apply(this, arguments)
		child.onChanged('recursiveVisible', this._scheduleLayout.bind(this))
		child.onChanged('width', this._scheduleLayout.bind(this))
		child.onChanged('height', this._scheduleLayout.bind(this))
	}
}
