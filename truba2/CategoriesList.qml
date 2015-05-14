ListView {
	property bool active: false;
	height: parent.height;
	width: active ? 200 : 0;
	model: categoriesModel;
	clip: true;
	delegate: Rectangle {
		height: 40;
		width: parent.width;
		color: activeFocus ? colorTheme.activeBackgroundColor : colorTheme.backgroundColor;

		Text {
			anchors.left: parent.left;
			anchors.verticalCenter: parent.verticalCenter;
			text: model.text;
		}
	}

	toggle: { this.active = !this.active; }

	Behavior on width { Animation { duration: 300; } }
}
