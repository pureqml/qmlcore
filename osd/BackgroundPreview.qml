Item {
	id: backgroundPreviewProto;
	property string preview: "";
	anchors.fill: parent;
	focus: false;

	Image {
		id: backgroundImage;
		anchors.fill: parent;
		fillMode: Image.Stretch;
	}

	Image {
		id: swapImage;
		anchors.fill: parent;
		fillMode: Image.Stretch;

		Behavior on opacity { Animation { id: hideSwapAnimation; duration: 300; } }
	}

	Rectangle {
		color: "#0009";
		anchors.fill: parent;
	}

	Timer {
		id: updatePreviewTimer;
		interval: 1000;

		onTriggered: {
			swapImage.source = backgroundImage.source
			swapImage.opacity = 1
			hideSwapAnimation.complete()
			backgroundImage.source = backgroundPreviewProto.preview
			backgroundPreviewProto.opacity = backgroundPreviewProto.preview ? 1.0 : 0.0
			swapImage.opacity = 0
		}
	}

	setPreview(preview): {
		this.preview = preview
		updatePreviewTimer.restart()
	}

	Behavior on opacity { Animation { id: hideSwapAnimation; duration: 300; } }
}
