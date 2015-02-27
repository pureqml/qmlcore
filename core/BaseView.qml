Item {
	property Object model;
	property Item delegate;

	property int count;
	property int currentIndex;

	property int contentX;
	property int contentY;
	property int contentWidth: 1;
	property int contentHeight: 1;

	property bool handleNavigationKeys: true;
	property bool keyNavigationWraps: true;
	property bool dragEnabled: true;

	Behavior on contentX	{ Animation { duration: 300; } }
	Behavior on contentY	{ Animation { duration: 300; } }

	itemAt(x, y): {
		var idx = this.indexAt(x, y)
		return idx >= 0? this._items[idx]: null
	}

	onFocusedChildChanged: {
		var idx = this._items.indexOf(this.focusedChild)
		//console.log("focused child", this.focusedChild, idx)
		if (idx >= 0)
			this.currentIndex = idx
	}

	onCurrentIndexChanged: {
		this.focusCurrent()
	}

	MouseArea {
		anchors.fill: parent;
		hoverEnabled: parent.dragEnabled;

		onPressedChanged: {
			if (this.pressed) {
				var idx = this.parent.indexAt(this.mouseX, this.mouseY)
				this._x = this.mouseX
				this._y = this.mouseY
				if (idx >= 0)
					this.parent.currentIndex = idx
			}
		}

		onMouseXChanged: {
			if (!this.pressed)
				return
			var dx = this.mouseX - this._x
			this._x = this.mouseX
			var a = this.parent.getAnimation('contentX')
			if (a)
				a.disable()
			this.parent.move(-dx, 0)
			if (a)
				a.enable()
		}

		onMouseYChanged: {
			if (!this.pressed)
				return
			var dy = this.mouseY - this._y
			this._y = this.mouseY
			var a = this.parent.getAnimation('contentY')
			if (a)
				a.disable()
			this.parent.move(0, -dy)
			if (a)
				a.enable()
		}

		onWheelEvent(dp): {
			this.parent.currentIndex -= Math.round(dp)
		}

		z: parent.dragEnabled? parent.z + 1: -1000;
	}

	onBoxChanged: { this._layout() }
	onCompleted: { this._layout() }
}
