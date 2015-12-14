Item {
	id: watchPageProto;
	signal switched;
	anchors.fill: parent;

	CategoriesList {
		id: categories;

		onGenreChoosed(list): { channels.resetIndex(); channels.setList(list) }

		onRightPressed: { channels.setFocus() }
	}

	ChannelsList {
		id: channels;
		anchors.left: categories.right;
		anchors.leftMargin: 2;

		onLeftPressed:	{ categories.setFocus() }
		onRightPressed:	{ programs.setFocus() }
		onSwitched(channel): { watchPageProto.switched(channel) }
		onChannelChoosed(channel): { programs.setChannel(channel) }
	}

	ProgramsList {
		id: programs;
		anchors.left: channels.right;
		anchors.leftMargin: 2;

		onLeftPressed: { categories.setFocus() }
	}
}
