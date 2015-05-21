Item {
	visible: false;

	Rectangle {
		width: parent.width;
		height: parent.height;
		color: colorTheme.backgroundColor;
		visible: epgModel.count && parent.visible;
		clip: true;
		
		Rectangle {
			width: 1;
			height: programsList.contentHeight;
			anchors.top: parent.top;
			anchors.left: parent.left;
			color: colorTheme.activeBackgroundColor;
		}

		Rectangle {
			width: 1;
			height: programsList.contentHeight;
			anchors.top: parent.top;
			anchors.right: parent.right;
			color: colorTheme.activeBackgroundColor;
		}

		ListView {
			id: programsList;
			anchors.fill: parent;
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
