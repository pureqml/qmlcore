ListView {
	height: 130;
	anchors.top: parent.top;
	anchors.left: parent.left;
	anchors.right: parent.right;
	orientation: ListView.Horizontal;
	delegate: BaseButton {
		width: height;
		height: parent.height;
		clip: true;

		EllipsisText {
			id: delegateText;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			anchors.bottomMargin: 5;
			anchors.leftMargin: 10;
			anchors.rightMargin: 10;
			pointSize: 14;
			text: model.text;
			color: colorTheme.focusedTextColor;
			visible: reachedParentWidth;
		}

		Text {
			anchors.bottom: parent.bottom;
			anchors.horizontalCenter: parent.horizontalCenter;
			anchors.bottomMargin: 5;
			pointSize: 14;
			text: model.text;
			color: colorTheme.focusedTextColor;
			visible: !delegateText.reachedParentWidth;
		}

		Item {
			anchors.top: parent.top;
			anchors.bottom: parent.bottom;
			anchors.bottomMargin: 20;
			anchors.horizontalCenter: parent.horizontalCenter;

			Image {
				anchors.centerIn: parent;
				source: model.source;
			}
		}
	}
}
