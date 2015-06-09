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
				foundPrograms.model.getEPGForSearchRequest(searchInput.text);

				foundChannelsList.model.clear();
				var list = this._get("categoriesModel").findChannels(searchInput.text);
				if (list.length) {
					foundChannelsList.model.setList(list);
					foundChannelsList.contentX = 0;
				}
			}
		}

		SectionLine { anchors.top: searchChannelLabel.bottom; }

		Column {
			anchors.top: searchInput.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			anchors.topMargin: 21;
			spacing: 20;

			Column {
				id: searchChannelsItem;
				anchors.left: parent.left;
				anchors.right: parent.right;
				spacing: 20;

				Text {
					id: searchChannelLabel;
					anchors.left: parent.left;
					anchors.leftMargin: 10;
					font.pointSize: 16;
					color: colorTheme.textColor;
					text: "Каналы" + (foundChannelsList.count ? " (" + foundChannelsList.count + ")" : "");
				}

				ListView {
					id: foundChannelsList;
					height: 100;
					anchors.left: parent.left;
					anchors.right: parent.right;
					spacing: 10;
					orientation: ListView.Horizontal;
					contentFollowsCurrentItem: false;
					model: ChannelsModel {}
					delegate: Item {
						height: parent.height;
						width: (foundChannelHeader.width > foundChannelContent.width ? foundChannelHeader.width : foundChannelContent.width) + 10;
						clip: true;

						Row {
							id: foundChannelHeader;
							anchors.left: parent.left;
							anchors.top: parent.top;
							anchors.leftMargin: 5;
							spacing: 5;

							Image {
								anchors.left: parent.left;
								anchors.verticalCenter: foundChannelGenreText.verticalCenter;
								width: foundChannelGenreText.paintedHeight;
								height: width - 5;
								source: "res/list.png";
							}

							Text {
								id: foundChannelGenreText;
								text: model.genre;
								font.bold: true;
								color: colorTheme.textColor;
								font.pointSize: 12;
							}
						}

						Row {
							id: foundChannelContent;
							anchors.top: foundChannelGenreText.bottom;
							anchors.left: parent.left;
							anchors.leftMargin: 5;
							anchors.bottom: parent.bottom;
							spacing: 5;

							Rectangle {
								anchors.top: parent.top;
								anchors.left: parent.left;
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

							Text {
								anchors.right: parent.right;
								anchors.verticalCenter: parent.verticalCenter;
								text: model.text;
								color: colorTheme.textColor;
								font.pointSize: 14;
							}
						}
					}
				}
			}

			Column {
				id: searchProgramItem;
				anchors.left: parent.left;
				spacing: 10;
				anchors.right: parent.right;
				spacing: 10;

				Text {
					id: searchProgramsLabel;
					anchors.left: parent.left;
					anchors.leftMargin: 10;
					font.pointSize: 16;
					color: colorTheme.textColor;
					text: "Программы" + (foundPrograms.count ? " (" + foundPrograms.count + ")" : "");
				}

				ListView {
					id: foundPrograms;
					height: parent.parent.height - searchProgramsLabel.paintedHeight - searchChannelsItem.height - 20;
					anchors.left: parent.left;
					anchors.right: parent.right;
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
		}
	}

	Behavior on width { Animation { duration: 300; } }
}
