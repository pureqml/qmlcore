ListView {
	property bool active: false;
	height: parent.height;
	width: active ? 300 : 0;
	model: categoriesModel;
	clip: true;
	contentFollowsCurrentItem: false;
	delegate: Rectangle {
		height: 40;
		width: parent.width;
		color: activeFocus ? colorTheme.activeBackgroundColor : colorTheme.backgroundColor;

		Text {
			anchors.left: parent.left;
			anchors.leftMargin: 20;
			anchors.verticalCenter: parent.verticalCenter;
			font.pointSize: 14;
			text: model.text;
		}
	}

	toggle: { this.active = !this.active; }

	setList(list): {
		for (var i = 0; i < this.count; ++i) {
			if (this.model.get(i).text == list) {
				this.currentIndex = i
				break;
			}
		}
	}

	Behavior on width { Animation { duration: 300; } }
}
