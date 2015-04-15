Item {
	property string channelIcon;
	property string channelName;

	Image {
		id: channelInfoIcon;
		anchors.top: parent.top;
		anchors.left: parent.left;
		source: parent.channelIcon;
	}

	Text {
		anchors.verticalCenter: channelInfoIcon.verticalCenter;
		anchors.left: channelInfoIcon.right;
		anchors.leftMargin: 20;
		color: colorTheme.textColor;
		text: parent.channelName;
		font.pointSize: 24;
	}

	fillInfo(channel): {
		this.channelIcon = channel.source;
		this.channelName = channel.text;

		programsList.model.getEPGForChannel(channel.text);
		programsList.currentIndex = 0;
	}

	ScrollableListView {
		id: programsList;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		anchors.top: channelInfoIcon.bottom;
		anchors.topMargin: 20;
		clip: true;
		model: epgModel;
		delegate: Rectangle {
			width: parent.width;
			height: 50;
			color: activeFocus ? colorTheme.backgroundColor : "#0000";

			Text {
				id: epgDelegaetTimeText;
				anchors.left: parent.left;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.leftMargin: 10;
				color: parent.activeFocus ? colorTheme.focusedTextColor : colorTheme.textColor;
				text: model.start;
			}

			Text {
				anchors.left: epgDelegaetTimeText.right;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.leftMargin: 10;
				color: parent.activeFocus ? colorTheme.focusedTextColor : colorTheme.textColor;
				text: model.title;
			}
		}
	}

	onActiveFocusChanged: {
		if (this.activeFocus)
			programsList.forceActiveFocus();
	}
}
