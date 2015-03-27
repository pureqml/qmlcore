Item {
	id: mainMenuProto;
	signal closeAll;
	signal optionChoosed;
	signal searchRequest;
	property bool active;
	opacity: active ? 1 : 0;
	height: 60;

	ListView {
		id: mainManuListView;
		width: contentWidth;
		anchors.top: parent.top;
		anchors.left: parent.left;
		height: parent.height;
		orientation: ListView.Horizontal;
		spacing: 1;
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

	Rectangle {
		height: mainManuListView.height;
		anchors.top: parent.top;
		anchors.left: mainManuListView.right;
		anchors.right: fullscreenButton.left;
		anchors.leftMargin: 1;
		anchors.rightMargin: 1;
		color: colorTheme.backgroundColor;

		TextInput {
			id: searchInput;
			anchors.verticalCenter: parent.verticalCenter;
			anchors.left: parent.left;
			anchors.leftMargin: 20;
		}

		TextButton {
			height: 50;
			width: 50;
			anchors.verticalCenter: parent.verticalCenter;
			anchors.left: searchInput.right;
			focusOnHover: true;

			Image {
				anchors.centerIn: parent;
				source: "res/search.png";
			}

			onTriggered: {
				console.log("entering fullscreen mode");
				mainMenuProto.searchRequest(searchInput.text);
			}
		}
	}

	TextButton {
		id: fullscreenButton;
		anchors.right: exitButton.left;
		anchors.rightMargin: 1;
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
