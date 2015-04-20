Item {
	property bool mute: false;
	anchors.top: videoPlayer.top;
	anchors.left: videoPlayer.left;
	visible: mute;

	Image {
		anchors.top: parent.top;
		anchors.left: parent.left;
		anchors.topMargin: 5;
		anchors.leftMargin: 5;
		source: "res/mute_bg.png";
		visible: videoPlayer.volume <= 0;
	}

	Image {
		anchors.top: parent.top;
		anchors.left: parent.left;
		source: "res/mute.png";
	}
}
