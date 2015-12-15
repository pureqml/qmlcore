Item {
	id: programsListProto;
	signal disappeared;
	property bool showed: false;
	property int count: programsListView.count;
	width: renderer.width / 2.8;
	anchors.top: parent.top;
	anchors.bottom: parent.bottom;
	opacity: showed ? 1.0 : 0.0;

	Background { }

	ListView {
		id: programsListView;
		anchors.fill: parent;
		model: epgModel;
		positionMode: ListView.Center;
		keyNavigationWraps: false;
		delegate: EPGDelegate { }
	}

	hide: { this.showed = false; if (this.activeFocus) programsListProto.disappeared(); }
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
