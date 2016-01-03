Item {
	id: programsListProto;
	signal disappeared;
	property bool showed: false;
	property int count: programsListView.count;
	property int curHeight: todaylabel.paintedHeight + 20 + programsListView.contentHeight;
	height: curHeight >= renderer.height ? renderer.height : curHeight;
	anchors.top: parent.top;
	opacity: showed ? 1.0 : 0.0;

	Background { }

	MainText {
		id: todaylabel;
		anchors.top: parent.top;
		anchors.horizontalCenter: parent.horizontalCenter;
		horizontalAlignment: Text.AlignHCenter;
		anchors.topMargin: 10;
		font.bold: true;
		color: colorTheme.accentTextColor;
		text: "Сегодня";
	}

	TrubaListView {
		id: programsListView;
		anchors.top: todaylabel.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		anchors.topMargin: 10;
		clip: true;
		model: epgModel;
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
