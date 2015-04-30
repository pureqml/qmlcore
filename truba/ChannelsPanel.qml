Activity {
	id: channelsPanelProto;
	signal channelSwitched;
	width: categoriesList.width + channels.width;
	anchors.top: renderer.top;
	anchors.left: renderer.left;
	anchors.bottom: renderer.bottom;
	opacity: active ? 1.0 : 0.0;

	ChannelsModel { id: channelsModel; }

	Rectangle {
		width: categoriesList.width;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		color: colorTheme.backgroundColor;

		MouseArea {
			id: menuButton;
			anchors.left: parent.left;
			anchors.top: parent.top;
			anchors.topMargin: 31;
			anchors.leftMargin: 10;

			Image {
				anchors.top: parent.top;
				anchors.left: parent.left;
				source: "res/list.png";
			}

			onClicked: { channelsPanelProto.stop(); }
		}

		Image {
			id: trubaLogo;
			anchors.left: menuButton.right;
			anchors.top: menuButton.top;
			anchors.leftMargin: 37;
			source: "res/logo.png";
		}

		Rectangle {
			id: channelsPanelSectionLine;
			height: 1;
			anchors.top: trubaLogo.bottom;
			anchors.topMargin: 31;
			width: categoriesList.width;
			color: colorTheme.activeBackgroundColor;
		}

		CategoriesList {
			id: categoriesList;
			anchors.top: channelsPanelSectionLine.bottom;
			anchors.left: parent.left;
			anchors.bottom: parent.bottom;
			model: categoriesModel;
			spacing: 1;
			contentFollowsCurrentItem: false;

			onCountChanged: {
				if (this.count > 1 && !channels.count)
					channelsModel.setList(categoriesList.model.get(0).list);
			}

			onRightPressed: {
				channels.currentIndex = 0;
				channels.forceActiveFocus();
			}

			updateList: {
				channelsModel.setList(categoriesList.model.get(categoriesList.currentIndex).list);
				channels.contentX = 0;
			}

			onSelectPressed:	{ this.updateList(); }
			onClicked:			{ this.updateList(); }
		}
	}

	Rectangle {
		anchors.top: parent.top;
		anchors.left: categoriesList.right;
		anchors.right: channels.right;
		anchors.bottom: parent.bottom;
		anchors.rightMargin: -20;
		color: "#000";
		opacity: 0.5;
	}

	Item {
		id: channelsArea;
		width: channels.width + 40;
		height: channels.height;
		anchors.top: categoriesList.top;
		anchors.left: categoriesList.right;

		Item {
			anchors.top: parent.top;
			anchors.bottom: parent.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			clip: true;

			ChannelsList {
				id: channels;
				anchors.top: channelsArea.top;
				anchors.horizontalCenter: channelsArea.horizontalCenter;
				model: channelsModel;
				contentFollowsCurrentItem: false;
				pageScrolling: true;

				onSelectPressed:	{ this.switchTuCurrent(); }
				onClicked:			{ this.switchTuCurrent(); }

				switchTuCurrent: {
					var channel = this.model.get(this.currentIndex);
					channelInfo.fillInfo(channel);
					channelsPanelProto.channelSwitched(channel);
				}
			}
		}

		Image {
			id: leftArrow;
			anchors.right: channels.left;
			anchors.verticalCenter: channels.verticalCenter;
			anchors.rightMargin: -20;
			source: "res/nav_left.png";
			visible: channels.contentX >= channels.width;
		}

		Image {
			id: rightArrow;
			anchors.left: channels.right;
			anchors.verticalCenter: channels.verticalCenter;
			anchors.leftMargin: -20;
			source: "res/nav_right.png";
			visible: channels.contentWidth - channels.contentX > channels.width;
		}

		MouseArea {
			anchors.fill: rightArrow;

			onClicked: {
				if (this.rightArrow.visible)
					channels.contentX += channels.width;
			}
		}

		MouseArea {
			anchors.fill: leftArrow;

			onClicked: {
				if (this.leftArrow.visible)
					channels.contentX -= channels.width;
			}
		}
	}

	ChannelInfo {
		id: channelInfo;
		anchors.top: channels.bottom;
		anchors.left: categoriesList.right;
		anchors.bottom: parent.bottom;
		anchors.right: channels.right;
	
		onUpPressed: { channels.forceActiveFocus(); }
	}

	MouseArea {
		anchors.left: channelsArea.right;
		anchors.right: renderer.right;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		hoverEnabled: parent.active;

		onClicked: { channelsPanelProto.stop(); }
	}

	Behavior on opacity { Animation { duration: 250; } }
}
