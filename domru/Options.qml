ListView {
	id: options;
	signal optionChoosed;
	width: contentWidth;
	height: parent.height;
	anchors.right: parent.right;
	anchors.bottom: parent.bottom;
	orientation: ListView.Horizontal;
	spacing: 25;
	delegate: Item {
		width: icon.paintedWidth + optionText.paintedWidth * 2;
		height: parent.height;
		opacity: activeFocus ? 1.0 : 0.6;

		Image {
			id: icon;
			source: model.source;
			anchors.left: parent.left;
			anchors.verticalCenter: parent.verticalCenter;
		}

		Text {
			id: optionText;
			anchors.left: icon.right;
			anchors.leftMargin: 10;
			anchors.verticalCenter: parent.verticalCenter;
			text: model.text;
			color: "#fff";
		}

		Behavior on opacity { Animation { duration: 300; } }
	}

	chooseCurrent: {
		var text = this.model.get(this.currentIndex).text;
		this.optionChoosed(text);
	}

	onSelectPressed: { this.chooseCurrent(); }
	onClicked: { this.chooseCurrent(); }
}
