Item {
	id: mainWindow;
	anchors.fill: renderer;
	anchors.leftMargin: 75;
	anchors.rightMargin: 75;
	anchors.bottomMargin: 40;
	anchors.topMargin: 42;

	Item {
		//TODO: use Column instead.
		id: bottomPanel;
		property int spacing: 8;
		height: 68;
		anchors.bottom: parent.bottom;
		anchors.bottomMargin: footer.top;
		anchors.left: parent.left;
		anchors.right: parent.right;

		GreenButton {
			id: timePanel;
			height: parent.height;
			width: 144;
			anchors.bottom: parent.bottom;
			anchors.left: parent.left;

			Text {
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.topMargin: 12;
				anchors.leftMargin: 10;
				color: "#fff";
				text: "15:19";
			}

			Text {
				anchors.bottom: parent.bottom;
				anchors.left: parent.left;
				anchors.bottomMargin: 12;
				anchors.leftMargin: 10;
				color: "#ccc";
				text: "22 сентября Пн";
			}

			onRightPressed: { channelPanel.forceActiveFocus(); }
		}

		GreenButton {
			id: channelPanel;
			height: parent.height;
			width: 144;
			anchors.bottom: parent.bottom;
			anchors.left: timePanel.right;
			anchors.leftMargin: bottomPanel.spacing;

			Text {
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.topMargin: 12;
				anchors.leftMargin: 10;
				color: "#ccc";
				text: "015";
			}

			onRightPressed: { programPanel.forceActiveFocus(); }
			onLeftPressed: { timePanel.forceActiveFocus(); }
		}

		GreenButton {
			id: programPanel;
			height: parent.height;
			width: 675;
			anchors.bottom: parent.bottom;
			anchors.left: channelPanel.right;
			anchors.leftMargin: bottomPanel.spacing;

			Text {
				id: programText;
				anchors.top: parent.top;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.topMargin: 12;
				anchors.leftMargin: 10;
				anchors.rightMargin: 10;
				color: "#fff";
				text: "Название текущей передачи";
			}

			Text {
				anchors.top: programText.bottom;
				anchors.left: parent.left;
				anchors.right: parent.right;
				anchors.leftMargin: 10;
				anchors.rightMargin: 10;
				color: "#ccc";
				text: "8:45 - 9:00, Россия 2, Спорт, 18";
			}

			onRightPressed: { settingsButton.forceActiveFocus(); }
			onLeftPressed: { channelPanel.forceActiveFocus(); }
		}

		GreenButton {
			id: settingsButton;
			height: parent.height;
			width: height;
			anchors.bottom: parent.bottom;
			anchors.left: programPanel.right;
			anchors.leftMargin: bottomPanel.spacing;

			onRightPressed: { exitButton.forceActiveFocus(); }
			onLeftPressed: { programPanel.forceActiveFocus(); }
		}

		GreenButton {
			id: exitButton;
			height: parent.height;
			width: height;
			anchors.bottom: parent.bottom;
			anchors.left: settingsButton.right;
			anchors.leftMargin: bottomPanel.spacing;

			onLeftPressed: { settingsButton.forceActiveFocus(); }
		}
	}

	Item {
		id: footer;
		height: 20;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
	}
}
