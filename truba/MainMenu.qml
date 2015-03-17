Item {
	id: mainMenuProto;
	signal optionChoosed;
	signal closeAll;
	name: "mainMenu";
	property bool active;
	property bool open;
	opacity: active ? 1 : 0;

	onActiveChanged: {
		if (!this.active)
			this.open = false;
	}

	Column{
		anchors.left: parent.left;
		anchors.top: panelRect.bottom;
		anchors.topMargin: mainMenuProto.open && mainMenuProto.active ? 2 : -500;
		width: 260;
		spacing: 2;

		MenuButton {
			id: channelList;
			anchors.left: parent.left;
			width: parent.width;
			source: "res/pipeline.png";
			text: "Каналы";

			onTriggered: { mainMenuProto.open = false; mainMenuProto.optionChoosed("channelList"); }
		}

		MenuButton {
			id: epg;
			anchors.left: parent.left;
			width: parent.width;
			source: "res/pipeline.png";
			text: "Телегид";

			onTriggered: { mainMenuProto.open = false; mainMenuProto.optionChoosed("epg"); }
		}

		MenuButton {
			id: movies;
			anchors.left: parent.left;
			width: parent.width;
			source: "res/pipeline.png";
			text: "Кино";

			onTriggered: { mainMenuProto.open = false; mainMenuProto.optionChoosed("movies"); }
		}

		MenuButton {
			id: settings;
			anchors.left: parent.left;
			width: parent.width;
			source: "res/pipeline.png";
			text: "Настройки";

			onTriggered: { mainMenuProto.open = false; mainMenuProto.optionChoosed("settings"); }
		}

		Behavior on y { Animation { duration: 250; } }
	}

	Rectangle {
		id: panelRect;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: parent.right;
		height: 60;
		color: "#424242";

		FocusablePanel {
			id: menuButton;
			anchors.left: parent.left;
			anchors.top: parent.top;
			anchors.bottom: parent.bottom;
			width: 180;
			color: containsMouse ? "#212121" : "#424242";

			Text {
				anchors.verticalCenter: parent.verticalCenter;
				anchors.left: parent.left;
				anchors.leftMargin: 20;
				font.pointSize: 18;
				text: "Truba\.TV";
				color: parent.containsMouse ? "red" : "white";
				Behavior on color	{ ColorAnimation { duration: 250; } }
			}

			Rectangle {
				anchors.right: parent.right;
				anchors.rightMargin: 20;
				anchors.top: parent.top;
				anchors.topMargin: 20;
				width: 25;
				height: 2;
				color: parent.containsMouse ? "red" : "white";
				Behavior on color	{ ColorAnimation { duration: 250; } }
			}

			Rectangle {
				anchors.right: parent.right;
				anchors.rightMargin: 20;
				anchors.verticalCenter: parent.verticalCenter;
				width: 25;
				height: 2;
				color: parent.containsMouse ? "red" : "white";
				Behavior on color	{ ColorAnimation { duration: 250; } }
			}

			Rectangle {
				anchors.right: parent.right;
				anchors.rightMargin: 20;
				anchors.bottom: parent.bottom;
				anchors.bottomMargin: 20;
				width: 25;
				height: 2;
				color: parent.containsMouse ? "red" : "white";
				Behavior on color	{ ColorAnimation { duration: 250; } }
			}

			onClicked: {
				mainMenuProto.open = !mainMenuProto.open;
			}
		}

		FocusablePanel {
			id: fullscreenButton;
			anchors.right: exitButton.left;
			anchors.top: parent.top;
			anchors.bottom: parent.bottom;
			width: 145;
			color: containsMouse ? "#212121" : "#424242";

			Text {
				anchors.verticalCenter: parent.verticalCenter;
				anchors.right: parent.right;
				anchors.rightMargin: 18;
				font.pointSize: 16;
				text: "Fullscreen";
				color: parent.containsMouse ? "red" : "white";
				Behavior on color	{ ColorAnimation { duration: 250; } }
			}

			onClicked: {
				console.log("entering fullscreen mode");
				if (renderer.inFullscreenMode())
					renderer.exitFullscreenMode();
				else
					renderer.enterFullscreenMode();
			}
		}

		FocusablePanel {
			id: exitButton;
			anchors.right: parent.right;
			anchors.top: parent.top;
			anchors.bottom: parent.bottom;
			width: 78;
			color: containsMouse ? "#212121" : "#424242";

			Text {
				anchors.verticalCenter: parent.verticalCenter;
				anchors.right: parent.right;
				anchors.rightMargin: 18;
				font.pointSize: 16;
				text: "Exit";
				color: parent.containsMouse ? "red" : "white";
				Behavior on color	{ ColorAnimation { duration: 250; } }
			}

			onClicked: {
				mainMenuProto.open = false;
				mainMenuProto.closeAll();
			}
		}
	}

	Rectangle {
		anchors.left: parent.left;
		anchors.right: parent.right;
		anchors.top: panelRect.bottom;
		width: 1;
		color: "#F5F5F5";
	}


	Behavior on opacity { Animation { duration: 250; } }
}