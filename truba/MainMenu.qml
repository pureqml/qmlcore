Item {
	id: mainMenuProto;
	signal closeAll;
	signal optionChoosed;
	signal searchRequest;
	property bool active;
	opacity: active ? 1 : 0;

	Rectangle {
		id: menuTopPanel;
		height: 60;
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
			color: colorTheme.textColor;
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

	ListView {
		id: mainManuListView;
		width: activeFocus ? 250 : 100;
		anchors.top: menuTopPanel.bottom;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		anchors.margins: 1;
		spacing: 1;
		model: ListModel {
			property string text;

			ListElement { text: "Каналы"; source: "res/menu/channels.png"; }
			ListElement { text: "Телегид"; source: "res/menu/epg.png"; }
			ListElement { text: "Кино"; source: "res/menu/vod.png"; }
			ListElement { text: "Настройки"; source: "res/menu/settings.png"; }
		}
		delegate: BaseButton {
			width: parent.width;
			height: 100;

			Image {
				id: menuItemIcon;
				anchors.left: parent.left;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.leftMargin: 10;
				source: model.source;
			}

			Text {
				anchors.left: menuItemIcon.right;
				anchors.leftMargin: 10;
				anchors.verticalCenter: parent.verticalCenter;
				text: model.text;
				font.pointSize: 16;
				color: colorTheme.textColor;
				visible: parent.parent.activeFocus;
			}
		}

		onClicked:			{ mainMenuProto.optionChoosed(this.currentIndex); }
		onSelectPressed:	{ mainMenuProto.optionChoosed(this.currentIndex); }

		Behavior on width { Animation { duration: 250; } }
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
