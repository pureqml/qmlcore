Item {
	property Object model;
	property Item delegate;

	property int orientation;
	property int spacing;

	property int count;
	property int currentIndex;

	property int contentX;
	property int contentY;
	property int contentWidth;
	property int contentHeight;

	property bool handleNavigationKeys: true;

	onKeyPressed: {
		var horizontal = this.orientation == this.Horizontal
		if (horizontal) {
			if (key == 'Left')
				--this.currentIndex;
			else if (key == 'Right')
				++this.currentIndex;
		} else {
			if (key == 'Up')
				--this.currentIndex;
			else if (key == 'Down')
				++this.currentIndex;
		}
	}

	focusCurrent: {
		var n = this.count
		if (n == 0)
			return
		var idx = this.currentIndex
		if (idx < 0 || idx >= n) {
			this.currentIndex = (idx + n) % n
			return
		}
		console.log(this._items, this.count)
		var item = this._items[idx]
		if (item)
			this.focusChild(item)
	}

	onCountChanged: {
		if (!this.focusedChild)
			this.focusCurrent()
	}

	onCurrentIndexChanged: {
		this.focusCurrent()
	}
}
