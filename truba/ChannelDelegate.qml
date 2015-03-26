BaseButton {
	width: height;
	height: parent.height;
	clip: false;

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
		cut: !parent.activeFocus;
		bgcolor: parent.color;
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
