Item {
	visible: false;

	Rectangle {
		width: parent.width;
		height: programsList.height;
		color: colorTheme.backgroundColor;
		visible: epgModel.count && parent.visible;
		border.width: 1;
		border.color: colorTheme.activeBackgroundColor;
		clip: true;
		
		ListView {
			id: programsList;
			height: contentHeight;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.right: parent.right;
			model: epgModel;
			delegate: Item {
				width: parent.width;
				height: 40;

				Text {
					id: epgStartProgramText;
					anchors.left: parent.left;
					anchors.verticalCenter: parent.verticalCenter;
					anchors.leftMargin: 5;
					color: colorTheme.textColor;
					text: model.start;
					font.pointSize: 12;
					font.bold: true;
				}

				Text {
					anchors.verticalCenter: parent.verticalCenter;
					anchors.left: epgStartProgramText.right;
					anchors.right: parent.right;
					anchors.leftMargin: 5;
					anchors.rightMargin: 5;
					color: colorTheme.textColor;
					text: model.title;
					font.pointSize: 12;
					clip: true;
				}
			}
		}
	}

	show(channel): {
		programsList.model.getEPGForChannel(channel.text);
		programsList.currentIndex = 0;
		this.visible = true;
	}

	hide: { this.visible = false; }
}
