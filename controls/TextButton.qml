BaseButton {
	height: 60;
	property string text;
	width: innerText.width + height / 2;

	Text {
		id: innerText;
		anchors.centerIn: parent;
		text: parent.text;
		font.pointSize: 16;
		color: "white";
		wrap: true;
	}
}
