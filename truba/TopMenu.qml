Item {
	id: mainMenuProto;
	signal closeAll;
	signal searchRequest;
	height: 50;
	anchors.top: renderer.top;
	anchors.left: renderer.left;
	anchors.right: renderer.right;

	//Rectangle {
	Item {
		id: menuTopPanel;
		height: parent.height;
		width: renderer.width - 640;
		//anchors.right: fullscreenButton.left;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.margins: 1;
		//color: colorTheme.backgroundColor;

		Text {
			id: topMenuCaption;
			anchors.left: parent.left;
			anchors.leftMargin: 10;
			anchors.verticalCenter: parent.verticalCenter;
			text: "TRUBATV";
			font.pointSize: 32;
			color: colorTheme.accentTextColor;
		}

		TextInput {
			id: searchInput;
			anchors.verticalCenter: parent.verticalCenter;
			anchors.left: parent.left;
			anchors.leftMargin: 250;
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
				console.log("search: " + searchInput.text);
				mainMenuProto.searchRequest(searchInput.text);
			}
		}
	}

	Behavior on opacity { Animation { duration: 250; } }
}
