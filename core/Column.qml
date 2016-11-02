Layout {
	onKeyPressed: {
		if (!this.handleNavigationKeys)
			return false;

		switch(key) {
			case 'Up':		this.focusPrevChild(); return true;
			case 'Down':	this.focusNextChild(); return true;
		}
	}

	function _layout() {
		if (!this.recursiveVisible)
			return
			
		var children = this.children;
		var p = 0
		var w = 0
		this.count = children.length
		for(var i = 0; i < children.length; ++i) {
			var c = children[i]
			if (!('height' in c))
				continue
			var r = c.x + c.width
			if (r > w)
				w = r
			c.viewY = p + c.anchors.topMargin
			if (c.recursiveVisible)
				p += c.height + c.anchors.topMargin + this.spacing
		}
		if (p > 0)
			p -= this.spacing
		this.contentWidth = w
		this.contentHeight = p
	}

	function addChild(child) {
		_globals.core.Item.prototype.addChild.apply(this, arguments)
		var delayedLayout = this._delayedLayout
		child.onChanged('height', delayedLayout.schedule.bind(delayedLayout))
		child.onChanged('recursiveVisible', delayedLayout.schedule.bind(delayedLayout))
	}

}
