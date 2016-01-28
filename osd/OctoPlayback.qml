Item {
	id: octoPlaybackProto;
	signal playPauseToggled;
	signal rewind;
	signal forward;
	property bool showed: false;
	property bool played: false;
	property real progress: 0.5;
	height: progressItem.height + pbControlsRow.height;
	anchors.left: parent.left;
	anchors.right: parent.right;
	anchors.bottom: parent.bottom;
	anchors.margins: 60;
	focus: showed;
	opacity: showed ? 1.0 : 0.0;

	Item {
		id: progressItem;
		height: 20;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		clip: true;

		Rectangle {
			anchors.fill: parent;
			color: octoColors.panelColor;
			opacity: 0.6;
		}

		Rectangle {
			width: parent.width * octoPlaybackProto.progress;
			anchors.left: parent.left;
			anchors.top: parent.top;
			anchors.bottom: parent.bottom;
			color: octoColors.accentColor;

			Behavior on width { Animation { duration: 300; } }
		}
	}

	Row {
		id: pbControlsRow;
		anchors.top: progressItem.bottom;
		anchors.horizontalCenter: parent.horizontalCenter;
		anchors.topMargin: 10;
		spacing: 20;

		OctoPlayControl {
			icon: "rewind.png";

			onSelectPressed: {
				this.pressed = true
				octoPlaybackProto.rewind()
			}
		}

		OctoPlayControl {
			id: playIcon;
			icon: octoPlaybackProto.played ? "pause.png" : "play.png";

			onSelectPressed: {
				this.pressed = true
				octoPlaybackProto.playPauseToggled()
			}
		}

		OctoPlayControl {
			icon: "forward.png";

			onSelectPressed: {
				this.pressed = true
				octoPlaybackProto.forward()
			}
		}
	}

	hide: { this.showed = false; }

	show(media): {
		this.showed = true
		playIcon.setFocus()
		//progressAnim.complete()
	}
}
