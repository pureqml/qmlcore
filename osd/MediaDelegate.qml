Item {
	id: mediaDelegateProto;
	width: iconImage.defaultWidth + 20;
	height: iconImage.defaultHeight;

	Rectangle {
		anchors.fill: iconImage;
		color: model.color ? model.color : "#0000";
		effects.shadow.color: parent.activeFocus ? "#000" : "#0000";
		effects.shadow.spread: 8;
		effects.shadow.blur: 10;
	}

	Image {
		id: iconImage;
		property int defaultWidth: 200;
		property int defaultHeight: 300;
		anchors.centerIn: parent;
		width: height - 100;
		height: parent.activeFocus ? defaultHeight + 20 : defaultHeight;
		fillMode: Image.Stretch;
		source: model.icon;

		Behavior on height { Animation { duration: 300; } }
	}

	Item {
		height: mediTitle.paintedHeight + 15;
		anchors.left: iconImage.left;
		anchors.right: iconImage.right;
		anchors.bottom: iconImage.bottom;
		clip: true;

		Rectangle {
			anchors.fill: parent;
			color: mediaDelegateProto.activeFocus ? octoColors.accentColor : octoColors.panelColor;
			opacity: mediaDelegateProto.activeFocus ? 1.0 : 0.8;

			Behavior on color { ColorAnimation { duration: 300; } }
		}

		TinyText {
			id: mediTitle;
			property bool overriden: paintedWidth > width;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			anchors.leftMargin: overriden ? 5 : 0;
			anchors.rightMargin: overriden ? 5 : 0;
			anchors.bottomMargin: 8;
			horizontalAlignment: overriden ? Text.AlignLeft : Text.AlignHCenter;
			color: octoColors.textColor;
			text: model.text;
			clip: true;
		}
	}

	Rectangle {
		id: focusBorder;
		anchors.fill: iconImage;
		color: "#0000";
		border.color: octoColors.accentColor;
		border.width: 5;
		radius: 5;
		opacity: parent.activeFocus ? 1.0 : 0.0;

		Behavior on opacity { Animation { duration: 300; } }
	}
}
