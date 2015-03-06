Activity {
	opcity: active ? 1.0 : 0.0;

	FocusablePanel {
		id: channelInfo;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		height: activeFocus ? 200 : 120;
		width: 230;

		onRightPressed: { programInfo.focus(); }
		onLeftPressed: { options.focus(); }
	}

	FocusablePanel {
		id: programInfo;
		anchors.left: channelInfo.right;
		anchors.right: options.left;
		anchors.leftMargin: 8;
		anchors.rightMargin: 8;
		anchors.bottom: parent.bottom;
		height: activeFocus ? 200 : 120;

		onRightPressed: { options.focus(); }
		onLeftPressed: { channelInfo.focus(); }
	}

	FocusablePanel {
		id: options;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;
		height: 120;
		width: 120;

		onRightPressed: { channelInfo.focus(); }
		onLeftPressed: { programInfo.focus(); }
	}

	onActiveChanged: {
		channelInfo.focus();
	}

	Behavior on opacity	{ Animation { duration: 300; } }
}