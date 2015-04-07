ListView {
	id: scrollableListViewProto;
	property int scrollbarWidth: 20;
	dragEnabled: !scrollBar.containsMouse;

	MouseArea {
		id: scrollBar;
		width: scrollableListViewProto.scrollbarWidth;
		anchors.top: parent.top;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		hoverEnabled: true;
		visible: parent.contentHeight > parent.height;
		z: parent.z + 1;

		Rectangle {
			anchors.fill: parent;
			color: parent.containsMouse ? colorTheme.activeBackgroundColor : colorTheme.backgroundColor;
		}

		Rectangle {
			id: positionRect;
			height: 30;
			width: parent.width;
			anchors.right: parent.right;
			color: parent.containsMouse ? colorTheme.textColor : colorTheme.activeBackgroundColor;

			updateSize:	{
				var h = scrollableListViewProto.height;
				var ch = scrollableListViewProto.contentHeight;
				this.height = (h / ch) * h;
			}

			onYChanged: {
				if (!scrollBar.containsMouse)
					return;
				var h = scrollableListViewProto.height;
				var ch = scrollableListViewProto.contentHeight;
				scrollableListViewProto.contentY = (this.y / h) * ch;
			}
		}

		onClicked: { this.updatePosition(); }

		updatePosition:	{
			var halfHeight = positionRect.height / 2;
			if (this.mouseY < halfHeight)
				positionRect.y = 0;
			else if (this.mouseY > this.height - halfHeight)
				positionRect.y = this.height - positionRect.height;
			else
				positionRect.y = this.mouseY - halfHeight;
		}

		onMouseYChanged: {
			if (!this.pressed)
				return;
			this.updatePosition();
		}
	}

	onContentHeightChanged:	{ positionRect.updateSize(); }

	onContentYChanged: {
		if (scrollBar.containsMouse)
			return;

		var y = (scrollableListViewProto.contentY / (scrollableListViewProto.contentHeight - scrollBar.height)) * scrollBar.height;
		var halfHeight = positionRect.height / 2;

		if (y < halfHeight)
			positionRect.y = 0;
		else if (y > scrollBar.height - halfHeight)
			positionRect.y = scrollBar.height - positionRect.height;
		else
			positionRect.y = y - halfHeight;
	}
}
