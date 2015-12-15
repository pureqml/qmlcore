Item {
	id: programsListProto;
	signal disappeared;
	property bool showed: false;
	property int count: programsListView.count;
	//width: renderer.width / 2.8;
	anchors.top: parent.top;
	anchors.bottom: parent.bottom;
	opacity: showed ? 1.0 : 0.0;

	Background { }

	MainText {
		id: todaylabel;
		anchors.top: parent.top;
		anchors.horizontalCenter: parent.horizontalCenter;
		horizontalAlignment: Text.AlignHCenter;
		font.bold: true;
		color: colorTheme.accentTextColor;
		text: "Сегодня";
	}

	ListView {
		id: programsListView;
		anchors.top: todaylabel.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		model: epgModel;
		positionMode: ListView.Center;
		keyNavigationWraps: false;
		clip: true;
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
