Activity {

	Column{
		anchors.left: parent.left;
		anchors.verticaCenter: parent.verticaCenter;
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