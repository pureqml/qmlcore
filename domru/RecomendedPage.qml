Item {
	id: recomendedProto;
	signal recomendedItemChoosed;
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

	Image {
		id: recomendedVideoPreview;
		anchors.left: weatherPanel.right;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.leftMargin: 10;
		width: height;
		source: "res/preview1.png";
	}

	ListView {
		id: recomendedOptions;
		width: 200;
		anchors.left: recomendedVideoPreview.right;
		anchors.top: parent.top;
		anchors.bottom: parent.bottom;
		anchors.leftMargin: 10;
		handleNavigationKeys: false;
		spacing: 10;
		delegate: OptionsDelegate { width: parent.width; height: recomendedProto.height / 3; }
		model: ListModel {
			property string text;
			property string additopnalText;
			property string icon;

			ListElement { text: "Телевидение"; icon: "res/settings.png"; }
			ListElement { text: "ТВ гид"; icon: "res/settings.png"; }
		}

		onUpPressed: {
			if (this.currentIndex)
				this.currentIndex--;
			else
				event.accepted = false;
		}

		onDownPressed: {
			if (this.currentIndex < this.count - 1)
				this.currentIndex++;
			else
				event.accepted = false;
		}

		onSelectPressed: { recomendedProto.recomendedItemChoosed(this.model.get(this.currentIndex).text); }
	}

	Image {
		id: smallRecomendedAdPanel;
		height: parent.height - recomendedOptions.contentHeight - recomendedOptions.spacing;
		anchors.left: recomendedOptions.left;
		anchors.right: recomendedOptions.right;
		anchors.bottom: parent.bottom;
		anchors.topMargin: 10;
		source: "res/ad3.png";
	}

	Image {
		id: recomendedAdPanel;
		anchors.left: recomendedOptions.right;
		anchors.top: parent.top;
		anchors.leftMargin: 10;
		source: "res/ad1.png";
	}

	onActiveFocusChanged: {
		if (this.activeFocus)
			recomendedOptions.forceActiveFocus();
	}
}
