Item {
	id: mainMenuProto;
	property bool active: false;
	property alias currentIndex: menuList.currentIndex;
	property width minWidth: 80;
	width: active ? renderer.width / 4.5 : minWidth;
	anchors.top: parent.top;
	anchors.left: parent.left;
	anchors.bottom: parent.bottom;
	clip: true;

	Background { opacity: parent.activeFocus || innerMenuArea.containsMouse ? 1.0 : 0.8; }

	ListView {
		id: menuList;
		anchors.fill: parent;
		delegate: MenuDelegate { }
		model: ListModel {
			property string text;

			ListElement { text: "Просмотр"; icon: "tv.png"; }
			ListElement { text: "Настройки"; icon: "settings.png"; }
		}
	}

	MouseArea {
		id: innerMenuArea;
		anchors.fill: parent;
		hoverEnabled: true;
		visible: !mainMenuProto.active;

		onClicked: { mainMenuProto.active = true }
	}

	onActiveFocusChanged: {
		if (!this.activeFocus)
			mainMenuProto.active = false
	}

	expand: {
		this.active = true
		this.setFocus()
	}

	onCompleted: { this.active = true }

	Behavior on width { Animation { duration: 300; } }
}
