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

		Image {
			id: delegateIcon;
			anchors.top: parent.top;
			anchors.horizontalCenter: parent.horizontalCenter;
			anchors.topMargin: 10;
			source: model.source;
		}
	}
}
