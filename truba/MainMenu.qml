Item {
	id: mainMenuProto;
	signal closeAll;
	signal optionChoosed;
	signal searchCalled;
	property bool active;
	name: "mainMenu";
	opacity: active ? 1 : 0;
	height: 60;

	ListView {
		id: mainManuListView;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.right: searchButton.left;
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

		onClicked:			{ mainMenuProto.optionChoosed(this.currentIndex); }
		onSelectPressed:	{ mainMenuProto.optionChoosed(this.currentIndex); }
	}

	TextButton {
		id: searchButton;
		anchors.right: fullscreenButton.left;
		anchors.top: parent.top;
		height: 60;
		width: 100;
		focusOnHover: true;

		Image {
			anchors.centerIn: parent;
			source: "res/search.png";
		}

		onTriggered: { mainMenuProto.searchCalled(); }
	}

	TextButton {
		id: fullscreenButton;
		anchors.right: exitButton.left;
		anchors.top: parent.top;
		height: 60;
		width: 100;
		focusOnHover: true;

		Image {
			anchors.centerIn: parent;
			source: "res/fullscreen.png";
		}

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
		width: 100;
		focusOnHover: true;

		Image {
			anchors.centerIn: parent;
			source: "res/close.png";
		}

		onTriggered: { mainMenuProto.closeAll(); }
	}

	Behavior on opacity { Animation { duration: 250; } }
}
