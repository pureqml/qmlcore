Item {
	anchors.fill: renderer;

	Rectangle {
		anchors.fill: parent;
		color: "#000";
		opacity: 0.7;
	}

	DomruLogo { id: logo; }

	Item {
		anchors.fill: parent;
		anchors.leftMargin: 75;
		anchors.rightMargin: 75;
		anchors.bottomMargin: 40;
		anchors.topMargin: 42;

		ListView {
			id: menuOptions;
			height: 70;
			anchors.top: logo.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			orientation: ListView.Horizontal;
			model: ListModel {
				property string text;

				ListElement { text: "Рекомендуем"; }
				ListElement { text: "Видео"; }
				ListElement { text: "Новости"; }
				ListElement { text: "Настройки"; }
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
		}

		PageStack {
			anchors.top: menuOptions.bottom;
			anchors.left: parent.left;
			anchors.right: parent.right;
			anchors.bottom: parent.bottom;
			currentIndex: menuOptions.currentIndex;

			Item {}
			Item {}
			Item {}
			Item {}
		}
	}
}
