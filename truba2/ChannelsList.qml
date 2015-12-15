Item {
	id: channelListProto;
	signal switched;
	signal channelChoosed;
	property int count: channelsListView.count;
	width: renderer.width / 2.8;
	anchors.top: parent.top;
	anchors.bottom: parent.bottom;
	opacity: activeFocus ? 1.0 : 0.8;

	ListView {
		id: channelsListView;
		anchors.fill: parent;
		positionMode: ListView.Center;
		keyNavigationWraps: false;
		spacing: 2;
		model: ChannelsModel { protocol: protocol; }
		delegate: ChannelDelegate { }

		onSelectPressed: { channelListProto.switched(this.model.get(this.currentIndex)) }

		onCurrentIndexChanged: {
			log("channel index changed " + this.currentIndex);
			updateChannelTimer.restart()
		}
	}

	Timer {
		id: updateChannelTimer;
		interval: 800;
		repeat: false;

		onTriggered: {
			log("channel timer triggered")
			channelListProto.channelChoosed(channelsListView.model.get(channelsListView.currentIndex))
		}
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

	//Behavior on opacity { Animation { duration: 300; } }
}
