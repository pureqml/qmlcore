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
	height: showed ? (isChannel ? 160 : 250) : 0;
	anchors.left: parent.left;
	anchors.right: parent.right;
	anchors.bottom: parent.bottom;
	anchors.margins: 10;
	focus: showed;

	Rectangle {
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
			width: 160;
			anchors.top: parent.top;
			anchors.left: parent.left;
			anchors.bottom: parent.bottom;
			fillMode: Image.Stretch;
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

			Text {
				//font: mainFont;
				color: octoColors.textColor;
				text: infoPanelProto.title;
			}

			Text {
				//font: tinyFont;
				color: octoColors.subTextColor;
				text: infoPanelProto.year;
			}

			Text {
				height: paintedHeight + 20;
				//font: tinyFont;
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

		Text {
			anchors.top: currentProgramProgress.bottom;
			anchors.left: infoPanelShort.left;
			anchors.right: infoPanelShort.right;
			anchors.topMargin: infoPanelProto.isChannel ? 5 : 40;
			//font: smallFont;
			color: octoColors.textColor;
			text: infoPanelProto.description;
			wrapMode: Text.Wrap;
		}
	}

	show(media): {
		this.showed = true 

		infoPanelImage.source = media.icon
		this.title = media.text
		this.isChannel = !media.movieInfo

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
	}

	hide: { this.showed = false }
}
