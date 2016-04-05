Layout {
	property int maxWidth: 1000;

	onWidthChanged: { this._delayedLayout.schedule() }

	function _layout() {
		var children = this.children;
		var cX = 0, cY = 0, xMax = 0, yMax = 0;
		for(var i = 0; i < children.length; ++i) {
			var c = children[i]
			if (c.recursiveVisible) {
				if (this.width - cX < c.width) {
					c.x = 0;
					c.y = yMax + c.anchors.topMargin;// + (cY === 0 ? 0 : this.spacing);
					cY = yMax;// + this.spacing;
					yMax = c.y + c.height + this.spacing;
				} else {
					c.x = cX;
					c.y = cY + c.anchors.topMargin;
				}
				if (yMax < c.y + c.height)
					yMax = c.y + c.height + this.spacing;
				if (xMax < c.x + c.width)
					xMax = c.x + c.width;
				cX = c.x + c.width + this.spacing;
			}
		}
		this.contentHeight = yMax;
		this.contentWidth = xMax;
	}

	function addChild(child) {
		qml.core.Item.prototype.addChild.apply(this, arguments)
		var delayedLayout = this._delayedLayout
		child.onChanged('height', delayedLayout.schedule.bind(delayedLayout))
		child.onChanged('width', delayedLayout.schedule.bind(delayedLayout))
		child.onChanged('recursiveVisible', delayedLayout.schedule.bind(delayedLayout))
	}

}
