/// Gris is a usefull way to automatically position its children 
Layout {
	property int horizontalSpacing; ///< horizontal spacing between rows, overrides regular spacing, pixels
	property int verticalSpacing; ///< vertical spacing between columns, overrides regular spacing, pixels
	property int rowsCount; ///< read-only property, represents number of row in a grid

	property enum horizontalAlignment {
		AlignLeft, AlignRight, AlignHCenter, AlignJustify
	};

	onWidthChanged: { this._delayedLayout.schedule() }

	function _layout() {
		var children = this.children;
		var cX = 0, cY = 0, xMax = 0, yMax = 0;
		var vsp = this.verticalSpacing || this.spacing, hsp = this.horizontalSpacing || this.spacing
		this.count = children.length
		var rows = []
		rows.push({idx: 0, width: 0}) //starting value
		for(var i = 0; i < children.length; ++i) {
			var c = children[i]
			var tm = c.anchors.topMargin || c.anchors.margins
			var bm = c.anchors.bottomMargin || c.anchors.margins
			var lm = c.anchors.leftMargin || c.anchors.margins
			var rm = c.anchors.rightMargin || c.anchors.margins
			var fullw = c.width + rm + lm
			var fullh = c.height + tm + bm
			if (c.recursiveVisible) {
				if (this.width - cX < fullw) { // not enough space to put the item, initiate a new row
					rows.push({idx: i, width: cX - hsp})
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
		this.rowsCount = rows.length;
		rows.push({idx: children.length, width: cX - hsp}) // add last point

		this.contentHeight = yMax;
		this.contentWidth = xMax;
		
		if (this.horizontalAlignment === this.AlignLeft)
			return

		var right = this.horizontalAlignment === this.AlignRight
		var center = this.horizontalAlignment === this.AlignHCenter
		var justify = this.horizontalAlignment === this.AlignJustify
		var shift, row

		for (var i = 0; i < rows.length - 1; ++i) {
			row = rows[i+1]

			if (right)
				shift = this.width - row.width
			else if (center)
				shift = (this.width - row.width) / 2
			else if (justify)
				shift = (this.width - row.width)

			if (shift !== 0) {
				var cindex = rows[i].idx, lindex = row.idx
				if (right || center) {
		 			for (; cindex < lindex; ++cindex) {
						children[cindex].x += shift
		 			}
		 		} else if (justify) {
		 			var c = lindex - cindex + 1
		 			var sp = shift / c
		 			for (; cindex < lindex; ++cindex) {
						children[cindex].x += sp * (cindex + c - lindex)
		 			}
		 		}
		 	}
 		}
	}

	function addChild(child) {
		_globals.core.Item.prototype.addChild.apply(this, arguments)
		var delayedLayout = this._delayedLayout
		child.onChanged('height', delayedLayout.schedule.bind(delayedLayout))
		child.onChanged('width', delayedLayout.schedule.bind(delayedLayout))
		child.onChanged('recursiveVisible', delayedLayout.schedule.bind(delayedLayout))
		child.anchors.on('marginsUpdated', delayedLayout.schedule.bind(delayedLayout))
	}

	function _update(name, value) {
		switch(name) {
			case 'horizontalSpacing':
			case 'verticalSpacing':
			case 'horizontalAlignment': 
				this._delayedLayout.schedule(); break;
		}
		_globals.core.Layout.prototype._update.apply(this, arguments);
	}
}
