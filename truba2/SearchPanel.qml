Activity {
	width: active ? 340 : 0;
	anchors.top: parent.top;
	anchors.right: renderer.right;
	anchors.bottom: parent.bottom;

	MouseArea {
		anchors.top: renderer.top;
		anchors.left: renderer.left;
		anchors.right: searchInnerPanel.left;
		anchors.bottom: renderer.bottom;
		hoverEnabled: parent.active;
		visible: parent.active;

		onClicked: { this.parent.stop(); }
	}

	Shadow {
		id: searchShadow;
		active: parent.active;
		leftToRight: false;
		anchors.top: parent.top;
		anchors.right: searchInnerPanel.left;
		anchors.bottom: parent.bottom;
	}

	Rectangle {
		id: searchInnerPanel;
		width: parent.width - searchShadow.width;
		height: parent.height;
		anchors.right: parent.right;
		color: colorTheme.backgroundColor;
		clip: true;

		Text {
			id: searchPanelTitle;
			width: parent.width;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.margins: 10;
			font.pointSize: 24;
			color: colorTheme.textColor;
			text: "Поиск";
		}

		Rectangle {
			height: 1;
			anchors.top: searchPanelTitle.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.margins: 10;
			color: "#ccc";
		}

		TextInput {
			id: searchInput;
			anchors.top: searchPanelTitle.bottom;
			anchors.left: parent.left;
			anchors.topMargin: 20;
			anchors.leftMargin: 10;
		}

		Button {
			anchors.left: searchInput.right;
			anchors.top: searchInput.top;
			innerText.font.pointSize: 10;
			text: "Поиск";

			onClicked: {
				foundPrograms.model.getEPGForSearchRequest(searchInput.text);
			}
		}

		ListView {
			id: foundPrograms;
			anchors.top: searchInput.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			anchors.margins: 10;
			clip: true;
			spacing: 10;
			model: epgModel;
			delegate: Item {
				height: foundContent.height;
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
	}

	Behavior on width { Animation { duration: 300; } }
}
