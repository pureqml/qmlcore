Activity {
	id: mainWindow;
	property variant currentPlay;
	property string mountedPath;
	name: "osd";
	anchors.fill: renderer;

	OctoColors { id: octoColors; }

	Data {
		id: data;
	
		onCompleted: { menu.fill(this.value) }
	}

	//function playVideo(url) {
		//backGroundPlayer.playMedia(multimediaModelWrap.getMediaDataFromMp4(mainWindow.mountedPath + "/test.mp4"))
	//}

	VideoPlayer {
		id: backGroundPlayer;
		anchors.fill: renderer;
		autoPlay: true;
		//source: "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";
		//http://www.quirksmode.org/html5/videos/big_buck_bunny.mp4

		//onFinished: { if (this.currenMedia) this.playUrl(this.currenMedia) }
	}

	BackgroundPreview { id: bgPreview; }

	OctoMenu {
		id: menu;
		anchors.fill: parent;
		anchors.topMargin: 70;
		anchors.leftMargin: 50;
		anchors.rightMargin: 50;

		onItemFocused(item): {
			if (item && item.preview && item.preview.length)
				bgPreview.setPreview(item.preview[0])
		}

		onItemSelected(item): {
			mainWindow.currentPlay = item
			if (item.program) {
				//rootFolder.playVideo(item.url)
				//mainWindow.hideOsd()
			} else {
				descriptionPanel.show(item)
			}
		}

		//onBackPressed: { mainWindow.hideOsd() }
	}

	DescriptionPanel {
		id: descriptionPanel;

		onPlay(media): {
			//rootFolder.playVideo(media.url)
			//mainWindow.hideOsd()
		}

		onBackPressed: {
			this.visible = false
			menu.setFocus()
		}
	}	

	InfoPanel {
		id: infoPanel;
		//progress: backGroundPlayer.duration ? 1.0 * backGroundPlayer.progress / backGroundPlayer.duration : 0.0;

		onBackPressed: { this.hide() }
	}

	//Gradient {
		//height: 80;
		//anchors.left: renderer.left;
		//anchors.right: renderer.right;
		//anchors.bottom: renderer.bottom;
		//opacity: (pbControl.showed || volumeControl.showed) && !menu.showed ? 1.0 : 0.0;

		//GradientStop { position: 0; color: "#0000"; }
		//GradientStop { position: 1; color: "#000"; }

		//Behavior on opacity { id: progressAnim; animation: Animation { duration: 300; } }
	//}

	OctoVolume {
		id: volumeControl;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		anchors.margins: 60;
	}

	OctoPlayback {
		id: pbControl;
		//property int seekInterval: backGroundPlayer.duration ? backGroundPlayer.duration / 20 : 1000;
		//played: !backGroundPlayer.paused;
		//progress: backGroundPlayer.duration ? 1.0 * backGroundPlayer.progress / backGroundPlayer.duration : 0.0;

		//onPlayPauseToggled: { backGroundPlayer.togglePlay() }
		//onRewind:	{ backGroundPlayer.seek(-this.seekInterval) }
		//onForward:	{ backGroundPlayer.seek(this.seekInterval) }

		//onBackPressed: { this.hide() }
	}

	hideOsd: {
		menu.hide()
		pbControl.hide()
		infoPanel.hide()
		bgPreview.setPreview("")
		descriptionPanel.visible = false
	}

	onRedPressed: {
		this.hideOsd()
		infoPanel.show(this.currentPlay)
	}

	onUpPressed: { volumeControl.volumeUp(); }
	onDownPressed: { volumeControl.volumeDown(); }

	//onKeyPressed: {
		//if (key == "Left" || key == "Right") {
			//this.hideOsd()
			//if (this.currentPlay.program)
				//infoPanel.show(this.currentPlay)
			//else
				//pbControl.show(this.currentPlay)
		//} else if (key == "Up") {
			//volumeControl.volumeUp();
		//} else if (key == "Down") {
			//volumeControl.volumeDown();
		//} else if (key == "Menu") {
			//this.hideOsd()
			//menu.show()
		//} else if (!menu.showed) {
			//this.hideOsd()
			//menu.show()
		//}
		//return true
	//}

	onCompleted: { menu.show() }
}
