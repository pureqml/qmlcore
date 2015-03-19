BaseButton {
	height: 60;
	property string text;
	width: innerText.paintedWidth + height / 2;

	Text {
		id: innerText;
		anchors.fill: parent;
		verticalAlignment: Text.AlignVCenter;
		horizontalAlignment: Text.AlignHCenter;
		text: parent.text;
		font.pointSize: 16;
		color: "white";
		wrap: true;
	}
}
