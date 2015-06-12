ListView {
	id: foundPrograms;
	height: contentHeight;
	anchors.left: parent.left;
	anchors.right: parent.right;
	clip: true;
	spacing: 10;
	model: epgModel;
	delegate: Item {
		height: 60;
		width: parent.width;
		clip: true;

		Column {
			id: foundContent;
			width: parent.width;
			anchors.verticalCenter: parent.verticalCenter;

			Text {
				anchors.left: parent.left;
				anchors.leftMargin: 5;
				text: model.channel;
				font.pointSize: 16;
				font.bold: true;
			}

			Item {
				height: startProgramText.paintedHeight;
				width: parent.width;

				Text {
					id: foundProgramStart;
					anchors.left: parent.left;
					anchors.verticalCenter: parent.verticalCenter;
					anchors.margins: 5;
					color: colorTheme.textColor;
					text: model.start;
					font.pointSize: 12;
					font.bold: true;
				}

				Text {
					anchors.left: foundProgramStart.right;
					anchors.right: parent.right;
					anchors.verticalCenter: parent.verticalCenter;
					anchors.margins: 5;
					color: colorTheme.textColor;
					text: model.title;
					font.pointSize: 12;
				}
			}
		}
	}
}
