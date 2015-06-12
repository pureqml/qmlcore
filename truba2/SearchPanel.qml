Activity {
	width: active ? 400 : 0;
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

		SectionLine { anchors.top: searchPanelTitle.bottom; }

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
				this._get("foundPrograms").model.getEPGForSearchRequest(searchInput.text);

				this._get("foundChannelsList").model.clear();
				var list = this._get("categoriesModel").findChannels(searchInput.text);
				if (list.length) {
					this._get("foundChannelsList").model.setList(list);
					searchContent.contentX = 0;
				}
			}
		}

		Flickable {
			id: searchContent;
			anchors.top: searchInput.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			anchors.topMargin: 21;
			anchors.bottomMargin: 20;
			dragging: true;
			draggingVertically: true;
			contentItem: Column {
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.right: parent.right;

				Column {
					id: searchChannelsItem;
					anchors.top: parent.top;
					anchors.left: parent.left;
					anchors.right: parent.right;

					Text {
						id: searchChannelLabel;
						anchors.left: parent.left;
						anchors.leftMargin: 10;
						font.pointSize: 16;
						color: colorTheme.textColor;
						text: "Каналы" + (foundChannelsList.count ? " (" + foundChannelsList.count + ")" : "");
						visible: foundChannelsList.count;
					}

					FoundChannels { id: foundChannelsList; }
				}

				Column {
					id: searchProgramItem;
					anchors.left: parent.left;
					anchors.right: parent.right;
					spacing: 20;

					Text {
						id: searchProgramsLabel;
						anchors.left: parent.left;
						anchors.leftMargin: 10;
						font.pointSize: 16;
						color: colorTheme.textColor;
						text: "Программы" + (foundPrograms.count ? " (" + foundPrograms.count + ")" : "");
						visible: foundPrograms.count;
					}

					FoundPrograms { id: foundPrograms; }
				}
			}
		}
	}

	onActiveChanged: {
		if (this.active) {
			this._get("foundPrograms").model.clear();
			this._get("foundChannelsList").model.clear();
		}
	}

	Behavior on width { Animation { duration: 300; } }
}
