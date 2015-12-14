Item {
	id: channelListProto;
	signal switched;
	signal channelChoosed;
	width: 450;
	anchors.top: parent.top;
	anchors.bottom: parent.bottom;

	ListView {
		id: channelsListView;
		anchors.fill: parent;
		positionMode: ListView.Center;
		keyNavigationWraps: false;
		spacing: 2;
		model: ChannelsModel { protocol: protocol; }
		delegate: ChannelDelegate { }

		onSelectPressed: { channelListProto.switched(this.model.get(this.currentIndex)) }
		onCurrentIndexChanged: { updateChannelTimer.restart() }
	}

	Timer {
		id: updateChannelTimer;
		interval: 800;
		repeat: false;

		onTriggered: { channelListProto.channelChoosed(channelsListView.model.get(channelsListView.currentIndex)) }
	}

	setList(list): { channelsListView.model.setList(list) }

	onActiveFocusChanged: {
		if (this.activeFocus)
			updateChannelTimer.restart()
	}

	resetIndex: {
		channelsListView.contentY = 0
		channelsListView.currentIndex = 0
	}
}
