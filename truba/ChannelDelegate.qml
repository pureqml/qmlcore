Rectangle {
	width: height;
	height: parent.height;
	color: activeFocus ? colorTheme.backgroundColor : "#0000";

	Rectangle {
		width: delegateText.paintedWidth + 10;
		height: delegateText.paintedHeight;
		anchors.bottom: parent.bottom;
		anchors.horizontalCenter: parent.horizontalCenter;
		visible: parent.activeFocus;
		color: parent.color;

		Text {
			id: delegateText;
			anchors.centerIn: parent;
			color: parent.parent.activeFocus ? colorTheme.focusedTextColor : colorTheme.textColor;
			text: model.text;
		}
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
