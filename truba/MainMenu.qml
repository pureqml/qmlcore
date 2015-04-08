ListView {
	id: mainMenuProto;
	signal optionChoosed;
	property bool active;
	height: 404;
	width: activeFocus ? 250 : 100;
	anchors.top: parent.top;
	anchors.left: parent.left;
	spacing: 1;
	opacity: active ? 1 : 0;
	model: ListModel {
		property string text;

		ListElement { text: "Каналы"; source: "res/menu/channels.png"; }
		ListElement { text: "Телегид"; source: "res/menu/epg.png"; }
		//ListElement { text: "Кино"; source: "res/menu/vod.png"; }
		//ListElement { text: "Настройки"; source: "res/menu/settings.png"; }
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
	onBackPressed:		{ this.active = false; }

	Behavior on width { Animation { duration: 250; } }
	Behavior on opacity { Animation { duration: 250; } }
}
