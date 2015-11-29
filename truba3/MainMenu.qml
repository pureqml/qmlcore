Rectangle {
	id: mainMenu;
	signal isAlive;
	property int minSize: 60;
	property int maxSize: 160;
	height: activeFocus ? maxSize : minSize;
	anchors.top: safeArea.top;
	anchors.left: safeArea.left;
	anchors.right: safeArea.right;
	color: colorTheme.focusablePanelColor;
	focus: true;
	clip: true;

	//HighlightListView {
	ListView {
		id: innerMenuList;
		height: parent.maxSize;
		anchors.bottom: parent.bottom;
		anchors.left: parent.left;
		anchors.right: parent.right;
		orientation: ListView.Horizontal;
		delegate: MenuDelegate { }
		model: ListModel {
			property string text;

			ListElement { text: "Просмотр"; icon: "apps/ondatra/res/menu/tv.png"; }
			ListElement { text: "VOD"; icon: "apps/ondatra/res/menu/vod.png"; }
			ListElement { text: "Настройки"; icon: "apps/ondatra/res/menu/settings.png"; }
		}

		onCountChanged: {
			if (this.count)
				this.setFocus()
		}

		onCurrentIndexChanged: { mainMenu.isAlive(); }
	}

	Behavior on width { animation: Animation {  duration: 200; } }
	Behavior on height { animation: Animation {  duration: 200; } }
}
