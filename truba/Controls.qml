Item {
	signal fullscreenToggled;
	signal listsToggled;
	property bool showListsButton: true;
	property bool showFullscreenButton: true;
	anchors.fill: renderer;

	MouseArea {
		anchors.fill: renderer;
		hoverEnabled: !parent.parent.hasAnyActiveChild;

		onMouseXChanged: {
			if (this.hoverEnabled)
				this.parent.show();
		}

		onMouseYChanged: {
			if (this.hoverEnabled)
				this.parent.show();
		}
	}

	RoundButton {
		id: listsButton;
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.leftMargin: 54;
		anchors.topMargin: 47;
		icon: "res/list.png";
		visible: parent.showListsButton;

		onToggled: { this.parent.listsToggled(); }
	}

	RoundButton {
		id: fullscreenButton;
		anchors.bottom: parent.bottom;
		anchors.right: parent.right;
		anchors.rightMargin: 54;
		anchors.bottomMargin: 47;
		icon: "res/fullscreen.png";
		visible: parent.showFullscreenButton;

		onToggled: { this.parent.fullscreenToggled(); }
	}

	Timer {
		id: hideControlsTimer;
		interval: 5000;	

		onTriggered: {
			fullscreenButton.visible = false;
			listsButton.visible = false;
		}
	}

	show: {
		fullscreenButton.visible = this.showFullscreenButton;
		listsButton.visible = this.showListsButton;
		hideControlsTimer.restart();
	}

	onVisibleChanged: {
		if (this.visible)
			this.show();
	}
}
