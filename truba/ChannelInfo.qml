Item {
	ScrollableListView {
		id: programsList;
		anchors.fill: parent;
		anchors.topMargin: 20;
		anchors.leftMargin: 60;
		clip: true;
		model: epgModel;
		delegate: Rectangle {
			width: parent.width;
			height: 50;
			color: activeFocus ? colorTheme.activeBackgroundColor : "#0000";

			Text {
				id: epgDelegaetTimeText;
				anchors.left: parent.left;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.leftMargin: 10;
				color: parent.activeFocus ? colorTheme.textColor : colorTheme.focusedTextColor;
				text: model.start;
			}

			Text {
				anchors.left: epgDelegaetTimeText.right;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.leftMargin: 10;
				color: parent.activeFocus ? colorTheme.textColor : colorTheme.focusedTextColor;
				text: model.title;
			}
		}
	}

	fillInfo(channel): {
		programsList.model.getEPGForChannel(channel.text);
		programsList.currentIndex = 0;
	}

	onActiveFocusChanged: {
		if (this.activeFocus)
			programsList.forceActiveFocus();
	}
}
