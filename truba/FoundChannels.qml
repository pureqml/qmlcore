ListView {
	height: 80 * count + 40;
	anchors.left: parent.left;
	anchors.right: parent.right;
	contentFollowsCurrentItem: false;
	model: ChannelsModel {}
	delegate: Item {
		height: 80;
		width:  parent.width;
		clip: true;

		Rectangle {
			id: foundChannelBackground;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.leftMargin: 5;
			anchors.bottom: parent.bottom;
			width: height;
			color: model.color;

			Image {
				property int maxWidth: 50;
				anchors.centerIn: parent;
				width: paintedWidth >= maxWidth ? maxWidth : paintedWidth;
				height: paintedHeight * (width / paintedWidth);
				source: model.source;
			}
		}

		Column {
			anchors.left: foundChannelBackground.right;
			anchors.right: parent.right;
			anchors.verticalCenter: parent.verticalCenter;
			anchors.leftMargin: 5;
			anchors.rightMargin: 5;
			clip: true;
			spacing: 10;

			Text {
				anchors.left: parent.left;
				text: model.text;
				color: colorTheme.textColor;
				font.bold: true;
				font.pointSize: 14;
			}

			Text {
				id: foundChannelGenreText;
				anchors.left: parent.left;
				text: "(" + model.genre + ")";
				color: colorTheme.textColor;
				font.pointSize: 12;
			}
		}
	}
}
