Item {
	width: 450;
	anchors.top: parent.top;
	anchors.bottom: parent.bottom;

	Rectangle {
		anchors.fill: parent;
		color: colorTheme.focusablePanelColor;
		visible: programsList.count;
	}

	ListView {
		id: programsList;
		anchors.fill: parent;
		model: epgModel;
		positionMode: ListView.Center;
		keyNavigationWraps: false;
		delegate: EPGDelegate { }
	}

	setChannel(channel): {
		programsList.model.getEPGForChannel(channel.id);
	}
}
