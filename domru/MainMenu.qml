Item {
	anchors.fill: renderer;

	Rectangle {
		anchors.fill: parent;
		color: "#000";
		opacity: 0.7;
	}

	Item {
		anchors.fill: parent;
		anchors.leftMargin: 75;
		anchors.rightMargin: 75;
		anchors.bottomMargin: 40;
		anchors.topMargin: 42;

		DomruLogo { id: logo; }

		ListView {
			id: menuOptions;
			height: 70;
			anchors.top: logo.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.topMargin: 40;
			orientation: ListView.Horizontal;
			model: ListModel {
				property string text;

				ListElement { text: "РЕКОМЕНДУЕМ"; }
				ListElement { text: "ВИДЕО"; }
				ListElement { text: "НОВОСТИ"; }
				ListElement { text: "НАСТРОЙКИ"; }
			}
			delegate: Item {
				height: 70;
				width: optionText.paintedWidth + 30;

				Text {
					id: optionText;
					font.pointSize: 24;
					color: "#fff";
					opacity: parent.activeFocus ? 1.0 : 0.6;
					text: model.text;
				}
			}

			onDownPressed: { optionsPageStack.forceActiveFocus(); }
		}

		PageStack {
			id: optionsPageStack;
			anchors.top: menuOptions.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			currentIndex: menuOptions.currentIndex;

			Recomended { anchors.fill: parent; }
			Item { anchors.fill: parent; }
			Item { anchors.fill: parent; }
			SettingsPage { anchors.fill: parent; }

			onUpPressed: { menuOptions.forceActiveFocus(); }
		}
	}

	onCompleted: { menuOptions.forceActiveFocus(); }
}
