Item {
	id: mainMenuProto;
	property bool active: activeFocus;
	property alias currentIndex: menuList.currentIndex;
	property width minWidth: 80;
	width: active ? renderer.width / 4.5 : minWidth;
	anchors.top: parent.top;
	anchors.left: parent.left;
	anchors.bottom: parent.bottom;

	Background { }

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
}
