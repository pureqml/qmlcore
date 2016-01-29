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

	VideoPlayer {
		id: player;
		anchors.fill: renderer;
		autoPlay: true;
		focus: false;
		loop: true;

		onPausedChanged: { if (value) this.playVideo("") }

		playVideo(url): { this.source = "http://www.quirksmode.org/html5/videos/big_buck_bunny.mp4" }
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
				player.playVideo(item.url)
				mainWindow.hideOsd()
			} else {
				descriptionPanel.show(item)
			}
		}

		onBackPressed: { mainWindow.hideOsd() }
	}

	DescriptionPanel {
		id: descriptionPanel;

		onPlay(media): {
			player.playVideo(media.url)
			mainWindow.hideOsd()
		}

		onBackPressed: {
			this.visible = false
			menu.setFocus()
		}
	}	

	InfoPanel {
		id: infoPanel;

		onBackPressed: { this.hide() }

		onKeyPressed: { return true; }
	}

	hideOsd: {
		menu.hide()
		infoPanel.hide()
		bgPreview.setPreview("")
		descriptionPanel.visible = false
	}

	onRedPressed: {
		this.hideOsd()
		infoPanel.show(this.currentPlay)
	}

	onKeyPressed: {
		if (key == "Menu") {
			this.hideOsd()
			menu.show()
		} else if (!menu.showed) {
			this.hideOsd()
			menu.show()
		}

		return (key != "Back")
	}

	onCompleted: { menu.show() }
}
