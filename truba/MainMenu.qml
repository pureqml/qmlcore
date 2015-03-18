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
		anchors.top: menuButton.bottom;
		x: mainMenuProto.open && mainMenuProto.active ? 0 : -width;
		anchors.topMargin: mainMenuProto.open && mainMenuProto.active ? 2 : -500;
		width: 240;

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

		Behavior on x { Animation { duration: 250; } }
	}

	FocusablePanel {
		id: menuButton;
		anchors.left: parent.left;
		anchors.top: parent.top;
		height: 60;
		width: 180;
		focusOnHover: true;

		Text {
			anchors.verticalCenter: parent.verticalCenter;
			anchors.left: parent.left;
			anchors.leftMargin: 20;
			font.pointSize: 18;
			text: "Truba\.TV";
			color: "white";
		}

		Rectangle {
			anchors.right: parent.right;
			anchors.rightMargin: 20;
			anchors.top: parent.top;
			anchors.topMargin: 20;
			width: 25;
			height: 2;
			color: "white";
		}

		Rectangle {
			anchors.right: parent.right;
			anchors.rightMargin: 20;
			anchors.verticalCenter: parent.verticalCenter;
			width: 25;
			height: 2;
			color: "white";
		}

		Rectangle {
			anchors.right: parent.right;
			anchors.rightMargin: 20;
			anchors.bottom: parent.bottom;
			anchors.bottomMargin: 20;
			width: 25;
			height: 2;
			color: "white";
		}

		onClicked: {
			mainMenuProto.open = !mainMenuProto.open;
		}
	}

	TextButton {
		id: fullscreenButton;
		anchors.right: exitButton.left;
		anchors.top: parent.top;
		height: 60;
		width: 145;
		focusOnHover: true;
		text: "Fullscreen";

		onClicked: {
			console.log("entering fullscreen mode");
			if (renderer.inFullscreenMode())
				renderer.exitFullscreenMode();
			else
				renderer.enterFullscreenMode();
		}
	}

	TextButton {
		id: exitButton;
		anchors.right: parent.right;
		anchors.top: parent.top;
		height: 60;
		text: "Exit";

		onClicked: {
			mainMenuProto.open = false;
			mainMenuProto.closeAll();
		}
	}

	Behavior on opacity { Animation { duration: 250; } }
}