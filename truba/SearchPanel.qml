Activity {
	id: searchPanelProto;
	signal channelSwitched;
	property Protocol protocol;
	property Array channels;
	anchors.fill: parent;
	visible: active;
	name: "search";

	Input {
		id: inputDialog;
		height: 50;
		width: 345;
		anchors.left: keyBoard.left;

		onTextChanged: { this.parent.search(); }
	}

	Keyboard {
		id: keyBoard;
		anchors.top: inputDialog.bottom;
		anchors.right: parent.right;
		anchors.topMargin: 5;

		onKeySelected(key): { inputDialog.text += key; }
		onBackspase: { inputDialog.removeChar(); }
		onUpPressed: { inputDialog.forceActiveFocus(); }
	}

	search: {
		foundChannelModel.clear();

		var request = inputDialog.text;
		if (!request.length)
			return;

		if (!this.channels.length) {
			log("There are no channels.");
			return;
		}

		var list = this.channels;
		for (var i in list)
			if (list[i].title.toLowerCase().indexOf(request) >= 0)
				foundChannelModel.append({
					text:	list[i].title,
					url:	list[i].url,
					lcn:	list[i].url,
					source:	list[i].icon ? "http://truba.tv" + list[i].icon.source : "",
					color:	list[i].icon ? list[i].icon.color : "#0000"
				});
	}

	ListModel { id: foundChannelModel; }

	Column {
		anchors.left: parent.left;
		anchors.right: keyBoard.left;
		anchors.leftMargin: 10;
		anchors.rightMargin: 10;
		spacing: 10;

		Rectangle {
			height: 130;
			width: parent.width;
			color: colorTheme.backgroundColor;

			Text {
				id: foundChannelsLabel;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.left: parent.left;
				anchors.leftMargin: 10;
				color: colorTheme.textColor;
				font.pointSize: 32;
				text: "Каналы:";
			}

			ListView {
				id: foundChannelsResult;
				height: parent.height;
				anchors.left: foundChannelsLabel.right;
				anchors.right: parent.right;
				anchors.leftMargin: 10;
				orientation: ListView.Horizontal;
				clip: true;
				model: foundChannelModel;
				delegate: ChannelDelegate { }

				onSelectPressed:	{ this.switchTuCurrent(); }
				onClicked:			{ this.switchTuCurrent(); }

				switchTuCurrent:	{
					searchPanelProto.stop();
					searchPanelProto.channelSwitched(this.model.get(this.currentIndex));
				}
			}
		}

		Rectangle {
			height: 130;
			width: parent.width;
			color: colorTheme.backgroundColor;

			Text {
				anchors.verticalCenter: parent.verticalCenter;
				anchors.left: parent.left;
				anchors.leftMargin: 10;
				color: colorTheme.textColor;
				font.pointSize: 32;
				text: "Видео:";
			}
		}
	}

	onVisibleChanged: {
		if (!this.visible)
			return;

		var protocol = this.protocol;
		if (!protocol)
			return;

		var self = this;
		protocol.getChannels(function(res) {
			self.channels = res;
		})
	}
}
