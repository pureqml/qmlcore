Item {
	id: watchPageProto;
	signal switched;
	property variant currentList;
	property int currentLcn;
	anchors.fill: parent;

	LocalStorage {
		id: lastList;
		name: "lastList";

		onCompleted: {
			this.read();
			var lastListData = lastList.value ? JSON.parse(lastList.value): {};
			if (lastListData && lastListData.list) {
				watchPageProto.currentList = lastListData.list
				watchPageProto.currentLcn = lastListData.lcn
			}
		}
	}

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
	}

	ChannelsList {
		id: channels;
		anchors.left: categories.right;
		anchors.leftMargin: 2;

		onLeftPressed: { categories.setFocus() }
		onCurrentIndexChanged: { programs.hide() }
		onChannelChoosed(channel): { programs.setChannel(channel) }

		onEpgCalled: {
			programs.show()
			programs.setFocus()
		}

		onSwitched(channel): {
			watchPageProto.switched(channel)
			watchPageProto.currentList = channels.currentList
			watchPageProto.currentLcn = channels.currentIndex
			var lastListData = {
				list: watchPageProto.currentList,
				lcn: watchPageProto.currentLcn
			}
			lastList.value = JSON.stringify(lastListData)
		}
	}

	ProgramsList {
		id: programs;
		anchors.left: channels.right;
		anchors.right: parent.right;
		anchors.leftMargin: 2;

		onLeftPressed: { channels.setFocus() }
		onDisappeared: { channels.setFocus() }
	}

	onActiveFocusChanged: {
		if (this.activeFocus)
			categories.setFocus()
	}

	onVisibleChanged: {
		if (!this.visible) {
			channels.hide()
			programs.hide()
		}
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
