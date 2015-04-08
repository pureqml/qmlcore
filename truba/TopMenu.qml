Item {
	id: mainMenuProto;
	signal closeAll;
	signal searchRequest;
	property bool active;
	height: 60;
	anchors.top: renderer.top;
	anchors.left: renderer.left;
	anchors.right: renderer.right;
	opacity: active ? 1 : 0;

	Rectangle {
		id: menuTopPanel;
		height: parent.height;
		anchors.right: fullscreenButton.left;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.margins: 1;
		color: colorTheme.backgroundColor;

		Text {
			anchors.left: parent.left;
			anchors.leftMargin: 20;
			anchors.verticalCenter: parent.verticalCenter;
			text: "TRUBATV";
			font.pointSize: 32;
			color: colorTheme.accentTextColor;
		}

		//TextInput {
			//id: searchInput;
			//anchors.verticalCenter: parent.verticalCenter;
			//anchors.left: parent.left;
			//anchors.leftMargin: 250;
		//}

		//TextButton {
			//height: 50;
			//width: 50;
			//anchors.verticalCenter: parent.verticalCenter;
			//anchors.left: searchInput.right;
			//focusOnHover: true;

			//Image {
				//anchors.centerIn: parent;
				//source: "res/search.png";
			//}

			//onTriggered: {
				//console.log("search: " + searchInput.text);
				//mainMenuProto.searchRequest(searchInput.text);
			//}
		//}
	}

	TextButton {
		id: fullscreenButton;
		anchors.right: exitButton.left;
		anchors.top: parent.top;
		anchors.rightMargin: 1;
		anchors.topMargin: 1;
		height: parent.height;
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
		anchors.topMargin: 1;
		height: parent.height;
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
