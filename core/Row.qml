Layout {
	onKeyPressed: {
		if (!this.handleNavigationKeys)
			return false;

		switch(key) {
			case 'Left':	this.focusPrevChild(); return true;
			case 'Right':	this.focusNextChild(); return true;
		}
	}

	function _layout() {
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

	function addChild(child) {
		qml.core.Item.prototype.addChild.apply(this, arguments)
		var delayedLayout = this._delayedLayout
		child.onChanged('recursiveVisible', delayedLayout.schedule.bind(delayedLayout))
		child.onChanged('width', delayedLayout.schedule.bind(delayedLayout))
		child.onChanged('height', delayedLayout.schedule.bind(delayedLayout))
	}
}
