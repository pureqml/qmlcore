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
		keyNavigationWraps: false;
		spacing: 2;
		model: ChannelsModel { protocol: protocol; }
		delegate: ChannelDelegate { }

		select: { channelListProto.switched(this.model.get(this.currentIndex)) }
		onClicked: { this.select(); }
		onSelectPressed: { this.select(); }

		onCurrentIndexChanged: { updateChannelTimer.restart() }

		onCompleted: {
			if (_globals.core.vendor != "webkit") {
				this.positionMode = ListView.Center
				this.contentFollowsCurrentItem = true
			} else {
				this.contentFollowsCurrentItem = false
			}
		}
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

	Behavior on width { Animation { duration: 300; } }
}
