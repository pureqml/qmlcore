Item {
	id: mainMenuProto;
	signal closeAll;
	property bool active;
	property alias currentIndex: mainManuListView.currentIndex;
	name: "mainMenu";
	opacity: active ? 1 : 0;
	height: 60;

	ListView {
		id: mainManuListView;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: fullscreenButton.left;
		height: parent.height;
		orientation: ListView.Horizontal;
		model: ListModel {
			property string text;

			ListElement { text: "Каналы"; }
			ListElement { text: "Телегид"; }
			ListElement { text: "Кино"; }
			ListElement { text: "Настройки"; }
		}
		delegate: TextButton { text: model.text; }
	}

	TextButton {
		id: fullscreenButton;
		anchors.right: exitButton.left;
		anchors.top: parent.top;
		height: 60;
		focusOnHover: true;
		text: "Fullscreen";

		onTriggered: {
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
		focusOnHover: true;
		text: "Exit";

		onTriggered: { mainMenuProto.closeAll(); }
	}

	Behavior on opacity { Animation { duration: 250; } }
}
