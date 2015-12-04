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
		onSwitched(channel): { channelInfoPanel.show(channel) }
	}

	ChannelInfoPanel {
		id: channelInfoPanel;
		onSwitched(channel): { channelsPanelProto.switched(channel) }
		onIsAlive: { channelsPanelProto.isAlive(); }
	}

	onActiveFocusChanged: { panelContent.forceActiveFocus(); }
}
