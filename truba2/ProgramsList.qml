Item {
	id: programsList;
	property bool showed: false;
	width: 450;
	anchors.top: parent.top;
	anchors.bottom: parent.bottom;
	opacity: showed ? 1.0 : 0.0;

	Rectangle {
		anchors.fill: parent;
		color: colorTheme.focusablePanelColor;
	}

	ListView {
		id: programsListView;
		anchors.fill: parent;
		model: epgModel;
		positionMode: ListView.Center;
		keyNavigationWraps: false;
		delegate: EPGDelegate { }
	}

	hide: { this.showed = false }
	show: { this.showed = true }

	setChannel(channel): {
		programsListView.model.getEPGForChannel(channel.id)
		programsListView.currentIndex = 0
		if (channel.program.start)
			this.show()
		else
			this.hide()
	}

	Behavior on opacity { Animation { duration: 300; } }
}
