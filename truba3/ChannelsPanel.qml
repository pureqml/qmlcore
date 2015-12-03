Item {
	id: channelsPanelProto;
	signal switched;
	signal isAlive;
	height: safeArea.height - y;
	anchors.left: safeArea.left;
	anchors.right: safeArea.right;

	ChannelsByCategory {
		id: panelContent;
		onIsAlive: { channelsPanelProto.isAlive(); }
		onSwitched: { channelInfoPanel.show(channel) }
	}

	ChannelInfoPanel {
		id: channelInfoPanel;
		onSwitched: { channelsPanelProto.switched(channel) }
		onIsAlive: { channelsPanelProto.isAlive(); }
	}
}
