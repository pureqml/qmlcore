Item {
	id: mainMenuProto;
	signal settingsCalled;
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

		Image {
			id: topLogo;
			anchors.left: parent.left;
			anchors.verticalCenter: parent.verticalCenter;
			source: "res/logo.png";
		}

		Text {
			id: topMenuCaption;
			anchors.left: topLogo.right;
			anchors.leftMargin: 10;
			anchors.verticalCenter: parent.verticalCenter;
			text: "TRUBA";
			font.pointSize: 32;
			color: colorTheme.accentTextColor;
		}

		Text {
			anchors.top: topMenuCaption.top;
			anchors.left: topLogo.right;
			anchors.leftMargin: topMenuCaption.paintedWidth;
			text: "TV";
			font.pointSize: 32;
			color: colorTheme.textColor;
		}

		TextInput {
			id: searchInput;
			anchors.verticalCenter: parent.verticalCenter;
			anchors.left: parent.left;
			anchors.leftMargin: 280;
		}

		MouseArea {
			id: searchButton;
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
				source: parent.containsMouse ? "res/search_active.png" : "res/search.png";
			}

			onTriggered: {
				console.log("search: " + searchInput.text);
				mainMenuProto.searchRequest(searchInput.text);
			}
		}

		MouseArea {
			height: 50;
			width: 50;
			anchors.verticalCenter: parent.verticalCenter;
			anchors.left: searchButton.right;
			hoverEnabled: true;

			Rectangle {
				anchors.fill: parent;
				color: parent.containsMouse ? colorTheme.backgroundColor : "#0000";
			}

			Image {
				anchors.centerIn: parent;
				source: parent.containsMouse ? "res/settings_active.png" : "res/settings.png";
			}

			onTriggered: {
				mainMenuProto.settingsCalled();
			}
		}
	}
}
