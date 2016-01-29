ListView {
	signal toggled;
	keyNavigationWraps: false;
	contentFollowsCurrentItem: !globals.isWebkit;
	positionMode: globals.isWebkit ? ListView.Contain : ListView.Center;

	onClicked:			{ this.toggled(); }
	onSelectPressed:	{ this.toggled(); }

	onCurrentIndexChanged: {
		if (this.contentFollowsCurrentItem)
			return;

		var idx = this.currentIndex
		var itemBox = this.getItemPosition(idx)
		var itemY = itemBox[1]
		var itemH = itemBox[3]

		if (itemY < this.contentY)
			this.contentY -= itemH
		else if (itemY + itemH > this.contentY + this.height)
			this.contentY += itemH
	}
}
