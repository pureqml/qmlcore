Activity {

	Column{
		anchors.left: parent.left;
		anchors.verticalCenter: parent.verticalCenter;
		width: 250;

		FocusablePanel {
			id: channelList;
			anchors.left: parent.left;
			height: 160;
			width: parent.width;
		}

		FocusablePanel {
			id: epg;
			anchors.left: parent.left;
			height: 160;
			width: parent.width;
		}

		FocusablePanel {
			id: settings;
			anchors.left: parent.left;
			height: 160;
			width: parent.width;
		}
	}
}
