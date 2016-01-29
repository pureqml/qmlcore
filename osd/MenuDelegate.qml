MouseArea {
	id: menuDelegateProto;
	signal itemFocused;
	signal itemSelected;
	property variant content: model.content;
	height: 320 + topLabel.paintedHeight + 30;
	width: parent.width;
	hoverEnabled: true;

	ListModel { id: menuDelegateModel; }

	MainText {
		id: topLabel;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.leftMargin: 10;
		color: octoColors.textColor;
		text: model.text;
		font.shadow: true;
	}

	ListView {
		id: innerList;
		anchors.top: topLabel.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		anchors.topMargin: 10;
		orientation: ListView.Horizontal;
		positionMode: ListView.Center;
		hoverEnabled: true;
		keyNavigationWraps: false;
		model: menuDelegateModel;
		delegate: MediaDelegate { }
		spacing: 10;

		choose: {
			if (!this.count)
				return
			if (this.currentIndex >= this.count)
				this.currentIndex = 0

			menuDelegateProto.itemFocused(this.model.get(this.currentIndex))
		}

		onCurrentIndexChanged: { this.choose() }

		onSelectPressed: {
			var row = this.model.get(this.currentIndex)
			var itemBox = this.getItemPosition(this.currentIndex)
			row.x = innerList.x + itemBox[0] - innerList.contentX
			row.y = innerList.y + itemBox[1]
			row.height = itemBox[3]
			menuDelegateProto.itemSelected(row)
		}
	}

	onActiveFocusChanged: {
		if (this.activeFocus)
			innerList.choose()
	}

	onCompleted: {
		if (!this.content)
			return

		menuDelegateModel.clear();

		for (var i in this.content)
			menuDelegateModel.append(this.content[i])
	}
}
