Activity {
	id: settingsPanel;
	property Protocol protocol;
	anchors.fill: parent;
	visible: active;
	name: "settings";

	ListView {
		width: 600;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.bottom: parent.bottom;
		spacing: 1;
		clip: true;
		model: providersModel;
		delegate: BaseButton {
			width: parent.width;
			height: 100;
			clip: true;

			Image {
				id: providerIcon;
				anchors.verticalCenter: parent.verticalCenter;
				anchors.left: parent.left;
				anchors.leftMargin: 10;
				source: model.source;
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
				source: model.authorized ? (model.enabled ? "res/checked.png" : "res/unchecked.png") : "res/add.png";
			}
		}

		process: {
			var idx = this.currentIndex;
			this.model.enable(idx);
			this._onRowsChanged(idx, idx + 1);
		}

		onClicked:			{ this.process(); }
		onSelectPressed:	{ this.process(); }

		Behavior on width { Animation { duration: 300; } }
	}
}
