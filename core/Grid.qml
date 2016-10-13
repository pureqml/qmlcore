Layout {
	property int hSpacing;
	property int vSpacing;

	onWidthChanged: { this._delayedLayout.schedule() }

	function _layout() {
		var children = this.children;
		var cX = 0, cY = 0, xMax = 0, yMax = 0;
		var vsp = this.vSpacing || this.spacing, hsp = this.hSpacing || this.spacing
		this.count = children.length
		for(var i = 0; i < children.length; ++i) {
			var c = children[i]
			var tm = c.anchors.topMargin || c.anchors.margins
			var bm = c.anchors.bottomMargin || c.anchors.margins
			var lm = c.anchors.leftMargin || c.anchors.margins
			var rm = c.anchors.rightMargin || c.anchors.margins
			var fullw = c.width + rm + lm
			var fullh = c.height + tm + bm
			if (c.recursiveVisible) {
				if (this.width - cX < fullw) {
					c.x = lm;
					cY = yMax + vsp;
					c.y = cY + tm;
					yMax = cY + fullh;
				} else {
					c.x = cX + lm;
					c.y = cY + tm;
				}
				if (yMax < cY + fullh)
					yMax = cY + fullh;

				cX = c.x + c.width + rm + hsp;

				if (xMax < cX - hsp)
					xMax = cX - hsp;
			}
		}
		this.contentHeight = yMax;
		this.contentWidth = xMax;
	}

	function addChild(child) {
		_globals.core.Item.prototype.addChild.apply(this, arguments)
		var delayedLayout = this._delayedLayout
		child.onChanged('height', delayedLayout.schedule.bind(delayedLayout))
		child.onChanged('width', delayedLayout.schedule.bind(delayedLayout))
		child.anchors.onChanged('margins', delayedLayout.schedule.bind(delayedLayout))
		child.anchors.onChanged('leftMargin', delayedLayout.schedule.bind(delayedLayout))
		child.anchors.onChanged('rightMargin', delayedLayout.schedule.bind(delayedLayout))
		child.anchors.onChanged('topMargin', delayedLayout.schedule.bind(delayedLayout))
		child.anchors.onChanged('bottomMargin', delayedLayout.schedule.bind(delayedLayout))
		child.onChanged('recursiveVisible', delayedLayout.schedule.bind(delayedLayout))
	}

	function _update(name, value) {
		switch(name) {
			case 'hSpacing': this._delayedLayout.schedule(); break;
			case 'vSpacing': this._delayedLayout.schedule(); break;
		}
		qml.core.Layout.prototype._update.apply(this, arguments);
	}
}
