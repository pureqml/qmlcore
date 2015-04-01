Activity {
	id: settingsPanel;
	property Protocol protocol;
	anchors.fill: parent;
	visible: active;
	name: "settings";

	ProvidersModel	{ id: settingsProvidersModel; protocol: settingsPanel.protocol; showActivatedOnly: false; }

	ListView {
		width: 600;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.horizontalCenter: parent.horizontalCenter;
		spasing: 1;
		clip: true;
		model: settingsProvidersModel;
		delegate: BaseButton {
			width: parent.width;
			height: 100;
			clip: true;

			Image {
				id: providerIcon;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.left: parent.left;
				anchors.leftMargin: 10;
				source: model.icon;
			}

			Text {
				id: providerName;
				anchors.left: parent.left;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.leftMargin: 120;
				font.pointSize: 24;
				clip: true;
				text: model.text;
				color: colorTheme.focusedTextColor;
			}

			Image {
				id: checkedIcon;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.right: parent.right;
				anchors.rightMargin: 10;
				source: model.activated ? "res/checked.png" : "res/add.png";
			}
		}

		Behavior on width { Animation { duration: 300; } }
	}
}
