Item {
	id: watchPageProto;
	signal switched;
	property variant currentList;
	property int currentLcn;
	anchors.fill: parent;

	CategoriesList {
		id: categories;

		onGenreChoosed(list): {
			channels.resetIndex()
			channels.setList(list)
			programs.hide()
		}

		onRightPressed: {
			if (channels.count)
				channels.setFocus()
		}

		onActiveFocusChanged: { if (this.activeFocus) categories.active = true }
	}

	ChannelsList {
		id: channels;
		anchors.left: categories.right;
		anchors.leftMargin: 2;

		onLeftPressed:	{ categories.setFocus() }
		onRightPressed:	{ if (programs.count) programs.setFocus() }
		onChannelChoosed(channel): { programs.setChannel(channel) }

		onSwitched(channel): {
			watchPageProto.switched(channel)
			watchPageProto.currentList = channels.currentList
			watchPageProto.currentLcn = channels.currentIndex
		}

		onActiveFocusChanged: { if (this.activeFocus) categories.active = false }
	}

	ProgramsList {
		id: programs;
		anchors.left: channels.right;
		anchors.right: parent.right;
		anchors.leftMargin: 2;

		onLeftPressed: { channels.setFocus() }
		onDisappeared: { channels.setFocus() }

		onActiveFocusChanged: { if (this.activeFocus) categories.active = false }
	}

	reset: { categories.active = true }

	onActiveFocusChanged: {
		categories.active = true
		if (this.activeFocus)
			categories.setFocus()
	}

	switchNextChannel: {
		if (!this.currentList || !this.currentList.length)
			return

		this.currentLcn = ++this.currentLcn % this.currentList.length;
		this.switched(this.currentList[this.currentLcn])
	}

	switchPreviousChannel: {
		if (!this.currentList || !this.currentList.length)
			return

		this.currentLcn = --this.currentLcn >= 0 ? this.currentLcn % this.currentList.length : this.currentList.length + this.currentLcn;
		this.switched(this.currentList[this.currentLcn])
	}
}
