Item {
	id: infoPanelProto;
	property string title;
	property string duration;
	property string year;
	property string director;
	property string genre;
	property string description;
	property Color channelColor;
	property bool isChannel: false;
	property bool showed: false;
	property real progress: 0.0;
	height: infoPanelImage.paintedHeight;
	anchors.left: parent.left;
	anchors.right: parent.right;
	anchors.bottom: parent.bottom;
	anchors.margins: 10;
	visible: showed;
	focus: showed;

	Rectangle {
		id: innerPanel;
		anchors.fill: parent;
		color: octoColors.panelColor;
		clip: true;

		Rectangle {
			anchors.fill: infoPanelImage;
			color: infoPanelProto.channelColor;
			visible: infoPanelProto.isChannel;
		}

		Image {
			id: infoPanelImage;
			//width: 160;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.bottom: parent.bottom;
			//fillMode: Image.Stretch;
		}

		Column {
			id: infoPanelShort;
			anchors.top: parent.top;
			anchors.left: infoPanelImage.right;
			anchors.right: parent.right;
			anchors.topMargin: 5;
			anchors.leftMargin: 10;
			anchors.rightMargin: 10;
			visible: !infoPanelProto.isChannel;

			MainText {
				color: octoColors.textColor;
				text: infoPanelProto.title;
			}

			MainText {
				color: octoColors.subTextColor;
				text: infoPanelProto.year;
			}

			MainText {
				height: paintedHeight + 20;
				color: octoColors.textColor;
				text: infoPanelProto.duration;
			}
		}

		Rectangle {
			id: currentProgramProgress;
			height: 10;
			visible: infoPanelProto.isChannel;
			anchors.top: parent.top;
			anchors.left: infoPanelShort.left;
			anchors.right: infoPanelShort.right;
			anchors.topMargin: 50;
			color: "#000";
			clip: true;

			Rectangle {
				width: parent.width * infoPanelProto.progress;
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.bottom: parent.bottom;
				color: octoColors.accentColor;
			}
		}

		SmallText {
			anchors.top: infoPanelShort.bottom;
			anchors.left: infoPanelShort.left;
			anchors.right: infoPanelShort.right;
			color: octoColors.textColor;
			text: infoPanelProto.description;
			wrap: true;
		}
	}

	show(media): {
		if (!media)
			return

		this.showed = true 

		infoPanelImage.source = media.icon
		this.title = media.text
		//this.isChannel = !media.movieInfo
		this.isChannel = false 

		if (media.movieInfo) {
			var info = media.movieInfo
			this.year = info.year
			this.duration = info.duration + " min"
			this.description = info.description
		} else {
			var program = media.program
			this.channelColor = media.color
			this.year = "" 
			this.duration = ""
			this.description = program.description
		}
		innerPanel.setFocus()
	}

	onActiveFocusChanged: {
	log("focus", this.activeFocus)
	}

	hide: { this.showed = false }
}
