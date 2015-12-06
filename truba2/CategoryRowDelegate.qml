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
		shadow: true;
		font.pixelSize: 28;
	}

	GridView {
		id: innerChannels;
		property int displayedCount: 10;
		height: count > 10 ? 200 : 100;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		cellWidth: parent.width / displayedCount;
		cellHeight: 90;
		flow: GridView.FlowTopToBottom;
		handleNavigationKeys: false;
		model: ChannelsModel { protocol: protocol; }
		delegate: ChannelDelegate { }

		//TODO: =(
		onCellWidthChanged: { this._layout(); }

		onActiveFocusChanged:	{ if (this.activeFocus) this.showCurrentChannel(); }
		onCurrentIndexChanged:	{ this.showCurrentChannel(); }
		showCurrentChannel:		{ categoryRowDelegate.isAlive(); }

		onSelectPressed: {
			if (!this.recursiveVisible)
				return false;

			var row = this.model.get(this.currentIndex)
			row.x = 0
			row.y = 0 
			row.width = 100 
			row.height = 100 
			categoryRowDelegate.switched(row);
		}

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

	onActiveFocusChanged: {
		if (this.activeFocus)
			innerChannels.forceActiveFocus()
	}

	onCompleted: {
		if (this.list)
			innerChannels.model.setList(this.list)
	}
}
