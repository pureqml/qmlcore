Activity {
	id: settingsPanel;
	property Protocol protocol;
	anchors.fill: parent;
	visible: active;
	name: "settings";

	ProvidersModel	{ id: settingsProvidersModel; protocol: settingsPanel.protocol; }

	ListView {
		width: 600;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.horizontalCenter: parent.horizontalCenter;
		spasing: 1;
		clip: true;
		delegate: IconTextDelegate { width: parent.width; height: 100; }
		model: settingsProvidersModel;

		Behavior on width { Animation { duration: 300; } }
	}
}
