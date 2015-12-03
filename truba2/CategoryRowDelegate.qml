Item {
	id: categoryRowDelegate;
	signal isAlive;
	signal switched;
	signal movedUp;
	signal movedDown;
	signal returnedToMenu;
	property string genre: model.text;
	property variant list: model.list;
	width: parent.width;
	opacity: activeFocus ? 1 : 0.5;
	height: innerChannels.count > 10 ? 260 : 160;

	Text {
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.leftMargin: 10;
		text: model.text;
		color: colorTheme.accentTextColor;
		visible: parent.activeFocus;
		//style: Shadow;
		font.pixelSize: 18;
	}

	GridView {
		id: innerChannels;
		property int displayedCount: 8;
		height: count > 10 ? 200 : 100;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		cellWidth: (parent.width - horizontalSpacing * displayedCount) / displayedCount;
		cellHeight: 90;
		orientation: GridView.Horizontal;
		horizontalSpacing: 2;
		verticalSpacing: 2;
		handleNavigationKeys: false;
		model: ChannelsModel { }
		delegate: ChannelDelegate { }

		onActiveFocusChanged:	{ if (this.activeFocus) this.showCurrentChannel(); }
		onCurrentIndexChanged:	{ this.showCurrentChannel(); }
		showCurrentChannel:		{ categoryRowDelegate.isAlive(); }

		//onSelectPressed: {
			//if (!this.recursiveVisible)
				//return false;

			//var itemRect = this.getItemRect(innerChannels.currentIndex);
			//var row = this.model.get(this.currentIndex)

			//row.x = itemRect.Left - this.contentX + this.x - 10;
			//row.y = itemRect.Top + this.y - 10 - this.horizontalSpacing;
			//row.width = itemRect.Width() + 20;
			//row.height = itemRect.Height() + 25;

			//categoryRowDelegate.switched(row);
		//}

		onUpPressed: {
			var rowCount = Math.floor(this.height / this.cellHeight);
			if (this.currentIndex % rowCount == 0)
				categoryRowDelegate.movedUp();
			else
				--this.currentIndex;
		}

		onLeftPressed: {
			var rowCount = Math.floor(this.height / this.cellHeight);
			if (this.currentIndex < rowCount)
				categoryRowDelegate.returnedToMenu();
			else
				this.currentIndex -= rowCount;
		}

		onRightPressed: {
			var rowCount = Math.floor(this.height / this.cellHeight);
			this.currentIndex += rowCount;
		}

		onDownPressed: {
			var rowCount = Math.floor(this.height / this.cellHeight);
			if (this.currentIndex % rowCount == rowCount - 1)
				categoryRowDelegate.movedDown();
			else
				++this.currentIndex;
		}
	}

	onListChanged: {
		if (this.list)
			innerChannels.model.setList(this.list)
	}
}
