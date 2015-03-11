Activity {
	anchors.top: parent.top;
	anchors.bottom: parent.bottom;
	anchors.left: parent.left;
	active: false;
	visible: active;

	Rectangle {
		anchors.fill: channelsPanelChannels;
		color: colorTheme.backgroundColor;
	}

	ChannelsList {
		id: channelsPanelChannels;
		anchors.left: channelsPanelCategories.left;
		anchors.leftMargin: 50;
		model: ListModel {}

		onLeftPressed: { channelsPanelCategories.forceActiveFocus(); }
	}

	Rectangle {
		anchors.fill: channelsPanelChannels;
		color: "#000";
		opacity: channelsPanelChannels.activeFocus ? 0.0 : 0.6;

		Behavior on opacity { Animation { duration: 300; } }
	}

	Rectangle {
		anchors.fill: channelsPanelCategories;
		color: colorTheme.backgroundColor;
	}

	CategoriesList {
		id: channelsPanelCategories;
		model: ListModel {
			property string text;
			property string source;

			//ListElement { text: "ololo"; source: "res/scrambled.png"; }
			//ListElement { text: "ololo"; source: "res/scrambled.png"; }
			//ListElement { text: "ololo"; source: "res/scrambled.png"; }
			//ListElement { text: "ololo"; source: "res/scrambled.png"; }
			//ListElement { text: "ololo"; source: "res/scrambled.png"; }
			//ListElement { text: "ololo"; source: "res/scrambled.png"; }
			//ListElement { text: "ololo"; source: "res/scrambled.png"; }
			//ListElement { text: "ololo"; source: "res/scrambled.png"; }
			//ListElement { text: "ololo"; source: "res/scrambled.png"; }
			//ListElement { text: "ololo"; source: "res/scrambled.png"; }
		}

		onCurrentIndexChanged: {
			//var list = [
				//{ text: "ololo", source: "res/scrambled.png" },
				//{ text: "ololo", source: "res/scrambled.png" },
				//{ text: "ololo", source: "res/scrambled.png" },
				//{ text: "ololo", source: "res/scrambled.png" },
				//{ text: "ololo", source: "res/scrambled.png" },
				//{ text: "ololo", source: "res/scrambled.png" }
			//]; 
			//channelsPanelChannels.setList(list);
		}

		onRightPressed: { channelsPanelChannels.forceActiveFocus(); }
	}
}
