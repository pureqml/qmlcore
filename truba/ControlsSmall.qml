Item {
	id: controlsSmallProto;
	signal volumeUpdated;
	signal fullScreenClicked;
	property color		channelColor: colorTheme.backgroundColor;
	property string		channelName;
	property string		programName;
	property string		programDescription;
	property string		programTimeInterval;
	property float		programDuration;
	property float		volume;
	property int		channelNumber;
	property Protocol	protocol;

	FocusablePanel {
		id: channelInfo;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		height: 50;
		color: controlsSmallProto.channelColor;
		width: parent.width;
	}

	FocusablePanel {
		id: volumePanel;
		property int spacing: (50 - volumeIcon.height) / 2;
		height: activeFocus ? 50 + spacing + volumeTrackBar.height : 50;
		width: 50;
		anchors.right: fullscreenButton.left;
		anchors.bottom: parent.bottom;
		clip: true;

		TrackBar {
			id: volumeTrackBar;
			anchors.horizontalCenter: parent.horizontalCenter;
			anchors.bottom: volumeIcon.top;
			anchors.bottomMargin: volumePanel.spacing;
			visible: parent.activeFocus;

			onValueChanged: { controlsSmallProto.volumeUpdated(this.value); }
		}

		Image {
			id: volumeIcon;
			anchors.horizontalCenter: parent.horizontalCenter;
			anchors.bottom: parent.bottom;
			anchors.bottomMargin: volumePanel.spacing;
			source: controlsSmallProto.volume > 0.6 ? "res/small/volume.png" : controlsSmallProto.volume > 0.3 ? "res/small/volume_mid.png" : "res/small/volume_min.png";
		}
	}

	BaseButton {
		id: fullscreenButton;
		height: 50;
		width: 50;
		anchors.right: parent.right;
		anchors.bottom: parent.bottom;

		Image {
			anchors.centerIn: parent;
			source: "res/small/fullscreen.png";
		}

		onSelectPressed:	{ controlsSmallProto.fullScreenClicked(); }
		onClicked:			{ controlsSmallProto.fullScreenClicked(); }
	}

	//fillChannelInfo(channel): {
		//this.programName = "";
		//this.programDescription = "";
		//this.programTimeInterval = "";

		//if (!channel) {
			//log("InfoPanel: Empty channel info.");
			//return;
		//}

		//this.channelColor = channel.color;
		//this.channelNumber = channel.lcn;
		//this.channelName = this.channelNumber + ". " + channel.text;

		//var curChannel = channel.text;
		//var self = this;
		//var program = this.protocol.getCurrentPrograms(function(programs){
			//for (var i in programs) {
				//if (curChannel == programs[i].channel) {
					//self.programName = programs[i].title;
					//self.programDescription = programs[i].description;
					//var start = new Date(programs[i].start);
					//var stop = new Date(programs[i].stop);
					//self.programTimeInterval = start.getHours() + ":" + (start.getMinutes() < 10 ? "0" : "") + start.getMinutes() + " - ";
					//self.programTimeInterval += stop.getHours() + ":" + (stop.getMinutes() < 10 ? "0" : "") + stop.getMinutes();
					//break;
				//}
			//}
		//});
	//}

	//onVolumeChanged:		{ volumeTrackBar.value = controlsSmallProto.volume; }

	//Behavior on opacity	{ Animation { duration: 300; } }
}
