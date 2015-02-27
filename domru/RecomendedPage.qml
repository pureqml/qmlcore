Item {
	id: recomendedProto;
	anchors.fill: parent;

	Rectangle {
		id: weatherPanel;
		anchors.left: parent.left;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		width: 200;
		color: "#000";
		opacity: 0.7;
		focus: false;
	}

	Rectangle {
		id: recomendedVideoPreview;
		anchors.left: weatherPanel.right;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.leftMargin: 10;
		width: height;
		color: "#faa";
	}

	ListView {
		id: recomendedOptions;
		width: 250;
		anchors.left: recomendedVideoPreview.right;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.leftMargin: 10;
		spacing: 0;
		delegate: OptionsDelegate { width: parent.width; height: recomendedProto.height / 3; }
		model: ListModel {
			property string text;
			property string additopnalText;
			property string icon;

			ListElement { text: "Телевидение"; icon: "res/settings.png"; }
			ListElement { text: "ТВ гид"; icon: "res/settings.png"; }
		}
	}

	Rectangle {
		id: smallRecomendedAdPanel;
		height: parent.height - recomendedOptions.contentHeight;
		anchors.left: recomendedOptions.left;
		anchors.right: recomendedOptions.right;
		anchors.bottom: parent.bottom;
		anchors.topMargin: 10;
		color: "#ff0";
		focus: false;
	}

	Rectangle {
		id: recomendedAdPanel;
		anchors.left: recomendedOptions.right;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.leftMargin: 10;
		width: 200;
		color: "#ff0";
		focus: false;
	}

	onActiveFocusChanged: {
		if (this.activeFocus)
			recomendedOptions.forceActiveFocus();
	}
}
