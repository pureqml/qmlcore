/// Layout for vertical oriented content
Layout {
	///@private
	onKeyPressed: {
		if (!this.handleNavigationKeys)
			return false;

		switch (key) {
			case 'Up':		this.focusPrevChild(); return true;
			case 'Down':	this.focusNextChild(); return true;
		}
	}

	///@private
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

			var tm = c.anchors.topMargin || c.anchors.margins
			var bm = c.anchors.bottomMargin || c.anchors.margins

			var r = c.x + c.width
			if (r > w)
				w = r
			c.viewY = p + tm
			if (c.recursiveVisible)
				p += c.height + tm + bm + this.spacing
		}
		if (p > 0)
			p -= this.spacing
		this.contentWidth = w
		this.contentHeight = p
	}

	///@private
	function addChild(child) {
		_globals.core.Item.prototype.addChild.apply(this, arguments)

		if (!('height' in child))
			return

		var delayedLayout = this._delayedLayout
		child.onChanged('height', delayedLayout.schedule.bind(delayedLayout))
		child.onChanged('recursiveVisible', delayedLayout.schedule.bind(delayedLayout))
		child.anchors.on('marginsUpdated', delayedLayout.schedule.bind(delayedLayout))
	}
}
