Rectangle {
	width: parent.cellWidth - 2;
	height: parent.cellHeight - 2;
	color: model.color;
	z: activeFocus ? parent.z + 100 : parent.z + 1;

	Rectangle {
		id: channelBgPanel;
		anchors.centerIn: parent;
		width: parent.activeFocus ? parent.width + 20 : parent.width;
		height: parent.activeFocus ? width - 40 : parent.height;
		color: model.color;
		visible: parent.activeFocus;

		Behavior on width { Animation { duration: 200; } }
	}

	Rectangle {
		id: titleBgPanel;
		height: parent.activeFocus ? channelDelegateLabel.paintedHeight : 0;
		anchors.top: channelBgPanel.bottom;
		anchors.left: channelBgPanel.left;
		anchors.right: channelBgPanel.right;
		color: colorTheme.activeFocusColor;
		clip: true;

		Text {
			id: channelDelegateLabel;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			horizontalAlignment: Text.AlignHCenter;
			wrap: true;
			text: model.text;
			color: colorTheme.focusedTextColor;
			font.pixelSize: 18;
		}
	}

	Image {
		anchors.fill: parent;
		anchors.margins: 10;
		fillMode: Image.PreserveAspectFit;
		source: model.source;
	}

	Item {
		anchors.top: channelBgPanel.top;
		anchors.left: channelBgPanel.left;
		anchors.right: channelBgPanel.right;
		anchors.bottom: titleBgPanel.bottom;
		effects.shadow.spread: 5;
		effects.shadow.color: "#000a";
		effects.shadow.blur: 6;
		visible: parent.activeFocus;
	}

}
