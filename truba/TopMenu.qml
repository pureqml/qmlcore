Item {
	id: mainMenuProto;
	signal closeAll;
	signal searchRequest;
	height: 50;
	anchors.top: renderer.top;
	anchors.left: renderer.left;
	anchors.right: renderer.right;

	Item {
		id: menuTopPanel;
		height: parent.height;
		width: renderer.width - 640;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.margins: 1;

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
			anchors.leftMargin: 270;
		}

		MouseArea {
			height: 50;
			width: 50;
			anchors.verticalCenter: parent.verticalCenter;
			anchors.left: searchInput.right;
			hoverEnabled: true;

			Rectangle {
				anchors.fill: parent;
				color: parent.containsMouse ? colorTheme.backgroundColor : "#0000";
			}

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
}
