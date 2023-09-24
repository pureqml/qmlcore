/// Layout for vertical oriented content
Layout {
	///@private
	onKeyPressed: {
		if (!this.handleNavigationKeys)
			return false;

		switch (key) {
			case 'Up':		return this.focusPrevChild()
			case 'Down':	return this.focusNextChild()
		}
	}

	///@private
	function _layout() {
		if (!this.recursiveVisible && !this.offlineLayout)
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
			if (c.visible)
				p += c.height + tm + bm + this.spacing
		}
		if (p > 0)
			p -= this.spacing
		this.contentWidth = w
		this.contentHeight = p
	}

	///@private
	function addChild(child) {
		$core.Item.prototype.addChild.apply(this, arguments)

		if (!('height' in child))
			return

		var update = this._scheduleLayout.bind(this)
		child.onChanged('height', update)
		child.onChanged('recursiveVisible', update)
		child.on('anchorsMarginsUpdated', update)
		this._scheduleLayout()
	}
}
